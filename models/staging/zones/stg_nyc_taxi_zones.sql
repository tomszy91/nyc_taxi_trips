with source as (
        select * from {{ source('local_csv_source', 'taxi_zone_lookup') }}
  ),
  renamed as (
      select
        locationid as location_id,
        borough as borough,
        zone as zone,
        service_zone as service_zone
      from source
  )
  select * from renamed
    