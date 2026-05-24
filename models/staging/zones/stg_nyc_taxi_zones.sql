with source as (
        select * from {{ source('local_csv_source', 'taxi_zone_lookup') }}
  ),
  renamed as (
      select
        cast(locationid as smallint) as location_id,
        cast(borough as varchar) as borough,
        cast(zone as varchar) as zone,
        cast(service_zone as varchar) as service_zone
      from source
  )
  select * from renamed
    