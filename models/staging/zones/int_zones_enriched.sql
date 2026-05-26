with source as (
        select * from {{ ref("stg_nyc_taxi_zones") }}
  ),
  enriched as (
      select
        location_id,

        case
            when location_id = 264 then 'Unknown'
            when location_id = 265 then 'Outside of NYC'
            else borough
        end as borough,
        
        case
            when location_id = 264 then 'Unknown'
            when location_id = 265 then 'Outside of NYC'
            else zone
        end as zone,

        case
            when location_id = 264 then 'Unknown'       
            when location_id = 265 then 'Outside of NYC'
            else service_zone
        end as service_zone,
    
        case
            when location_id = 264 then 'Zone unknown' 
            when location_id = 265 then 'Zone outside NYC'
            else 'Zone inside NYC'
        end as zone_status

      from source
  )
  
  select * from enriched
    