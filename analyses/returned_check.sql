with trips as (
    select * from {{ source('motherduck', 'yellow_tripdata') }}
)

select * from trips order by tpep_pickup_datetime desc limit 5