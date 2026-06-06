{{
    config(
        materialized='incremental',
        unique_key = 'trip_id',
        incremental_strategy = 'merge'
    )}}

with
trips as (
    select *
    from {{ ref('int_trips_flagged') }}
    {% if is_incremental() %}
    where meter_on::date >= (select (max(meter_on) - interval 1 day) from {{ this }}) 
    {% endif %}
),

zones as (
    select * from {{ ref("int_zones_enriched")}}
),

-- join trips with zones to make human readable pickup, dropoff zones
trips_zones as (
    select
        t.* REPLACE (
            case
                when t.payment_type = 0 then 99
                else t.rate_code_id
            end as rate_code_id
        ),
        coalesce(z1.borough, 'No zone match') as pickup_borough,
        coalesce(z1.zone, 'No zone match') as pickup_zone,
        coalesce(z1.service_zone, 'No zone match') as pickup_service_zone,
        
        coalesce(z2.borough, 'No zone match') as dropoff_borough,
        coalesce(z2.zone, 'No zone match') as dropoff_zone,
        coalesce(z2.service_zone, 'No zone match') as dropoff_service_zone,

        coalesce(z1.zone_status, 'No zone match') as pickup_zone_status,
        coalesce(z2.zone_status, 'No zone match') as dropoff_zone_status
        
    from
        trips as t
            left join zones as z1 on t.meter_on_zone_id = z1.location_id
            left join zones as z2 on t.meter_off_zone_id = z2.location_id

)

select * from trips_zones