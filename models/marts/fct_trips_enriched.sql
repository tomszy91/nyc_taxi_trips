{{
    config(
        materialized = 'incremental',
        unique_key = 'trip_id',
        incremental_strategy = 'delete+insert'
    )}}

with
trips as (
    -- replacing nulls with 99 when payment type is Flex Fare. With thus payment, rate code is unknown.
    select * REPLACE (case
            when payment_type = 0 then 99
            else rate_code_id
        end as rate_code_id),
        meter_off - meter_on as duration_time,
        case when (trip_distance = 0) or (meter_off = meter_on) then null else round(trip_distance::numeric / (datediff('second', meter_on, meter_off) / 3600::numeric),2) end as average_speed
    from {{ ref('int_trips_flagged') }}
    {% if is_incremental() %}
    where meter_on::date >= (select (max(meter_on) - interval '35 day') from {{ this }}) 
    {% endif %}
),

zones as (
    select * from {{ ref("int_zones_enriched")}}
),

payment_types as (
    select * from {{ ref("dim_payment_type")}}
),

rate_codes as (
    select * from {{ ref("dim_ratecode")}}
),

flags as (
    select * from {{ ref("dim_store_and_fwd_flag")}}
),

vendors as (
    select * from {{ ref("dim_vendor")}}
),

descriptions as (
    select trips.*,
    coalesce(payment_types.description, 'No match') as payment_type_description,
    coalesce(rate_codes.description, 'No match') as rate_code_description,
    coalesce(flags.description, 'No match') as stored_flag_description,
    coalesce(vendors.description, 'No match') as vendor_name
    from trips
        left join payment_types on trips.payment_type = payment_types.id
        left join rate_codes on trips.rate_code_id = rate_codes.id
        left join flags on trips.stored_flag = flags.flag
        left join vendors on trips.vendor_id = vendors.id                
),


-- join trips with zones to make human readable pickup, dropoff zones
zones_join as (
    select
        d.*,
        coalesce(z1.borough, 'No zone match') as pickup_borough,
        coalesce(z1.zone, 'No zone match') as pickup_zone,
        coalesce(z1.service_zone, 'No zone match') as pickup_service_zone,
        
        coalesce(z2.borough, 'No zone match') as dropoff_borough,
        coalesce(z2.zone, 'No zone match') as dropoff_zone,
        coalesce(z2.service_zone, 'No zone match') as dropoff_service_zone,

        coalesce(z1.zone_status, 'No zone match') as pickup_zone_status,
        coalesce(z2.zone_status, 'No zone match') as dropoff_zone_status
        
    from
        descriptions as d
            left join zones as z1 on d.meter_on_zone_id = z1.location_id
            left join zones as z2 on d.meter_off_zone_id = z2.location_id

),

final as (
    select
        -- identifiaction
        trip_id,
        vendor_id,
        vendor_name,
        meter_on,
        meter_off,
        duration_time,
        trip_distance,
        average_speed,
        passenger_count,
        -- zones
        meter_on_zone_id,      
        pickup_borough,
        pickup_zone,
        pickup_service_zone,
        pickup_zone_status,
        meter_off_zone_id,
        dropoff_borough,
        dropoff_zone,
        dropoff_service_zone,
        dropoff_zone_status,
        -- financials
        rate_code_id,
        rate_code_description,
        payment_type,
        payment_type_description,
        fare_amount,
        extra_charges,
        tax_amount,
        tip_amount,
        tolls_amount,
        improvement_surcharge,
        congestion_surcharge,
        airport_fee,
        cbd_congestion_fee,
        total_amount,
        calculated_total_amount,
        -- quality
        payment_discrepancy,
        is_suspicious,
        is_returned,
        stored_flag,
        stored_flag_description
    from zones_join
)

select * from final