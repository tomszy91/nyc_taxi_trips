with source as (
        select * from {{ source('local_csv_source', 'taxi_zone_lookup') }}
  ),
  renamed as (
      select
          *

      from source
  )
  select * from renamed
    