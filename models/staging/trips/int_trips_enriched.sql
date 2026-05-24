with
trips as (
    select * from {{ ref('int_trips_flagged') }}
),

zones as (
    select * from {{ ref("stg_nyc_taxi_zones")}}
),

-- join trips with zones to make human readable pickup, dropoff zones
trips_zones as (
    select
        t.*,
        z1.borough as pickup_borough,
        z1.zone as pickup_zone,
        z1.service_zone as pickup_service_zone,
        z2.borough as dropoff_borough,
        z2.zone as dropoff_zone,
        z2.service_zone as dropoff_service_zone
    from
        trips as t
            left join zones as z1 on t.meter_on_zone_id = z1.location_id
            left join zones as z2 on t.meter_off_zone_id = z2.location_id
)

select * from trips_zones