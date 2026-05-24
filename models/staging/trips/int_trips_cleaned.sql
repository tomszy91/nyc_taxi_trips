with source as (
    select * from {{ ref('stg_nyc_taxi_trips') }}
),

-- remove outliers
cleaned as (
    select
        *
    from
        source
    where
        -- end time later then start time
        meter_on < meter_off

        -- maximum distance 500 miles
        and trip_distance > 0 and trip_distance < 500
        
        -- average speed lower than 100 mph
        and trip_distance::numeric / (datediff('second', meter_on, meter_off) / 3600::numeric) < 100
)

select * from cleaned