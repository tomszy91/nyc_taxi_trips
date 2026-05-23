with source as (
        select * from {{ source('local_parquet_source', 'nyc_taxi_trips') }}
  ),
  renamed as (
      select
          *

      from source
  )
  select * from renamed
    