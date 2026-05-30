with cte1 as (
    select * from {{ source('local_parquet_source', 'nyc_taxi_trips') }}
)

select * from cte1
    where ratecodeid = 99