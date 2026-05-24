with source as (
    select * from {{ ref('stg_nyc_taxi_trips') }}
),

-- flagging charged but returned fare
returned_fare as (
    select
        vendor_id, meter_on, meter_off, meter_on_zone_id, meter_off_zone_id,
        sum(fare_amount) as fare_sum,
        sum(total_amount) as total_sum
    from
        source
    group by
        vendor_id, meter_on, meter_off, meter_on_zone_id, meter_off_zone_id
    having
        count(fare_amount) = 2 and sum(fare_amount) = 0
),

-- flagging trips that might be suspicious: 0 passengers, 0 distance, 0 fare
suspicious_trip as (
    select
        *,
        case
            -- is null is ok, as it is linked with Flex Fare trip
            when ((passenger_count = 0)) then true

            -- trips without distance or negative distance
            when ((trip_distance is null) or (trip_distance <= 0)) then true
            
            -- zero fare but payment code is not 'no charge'
            when ((fare_amount = 0 or fare_amount is null) and payment_type <> 3 ) then true
            
            else false
            end as is_suspisious
    from source
),

-- adding returned fare flag to main table
enriched as (
    select
        s.*,
        case when r.vendor_id is not null then true else false end as is_returned
    from suspicious_trip as s left join returned_fare as r on
        s.vendor_id = r.vendor_id
        and s.meter_on = r.meter_on
        and s.meter_off = r.meter_off
        and s.meter_on_zone_id = r.meter_on_zone_id
        and s.meter_off_zone_id = r.meter_off_zone_id
)

select * from enriched