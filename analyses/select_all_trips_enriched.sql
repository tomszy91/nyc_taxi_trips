with trips as (
    select * from {{ ref("int_trips_enriched")}}
    )

select * from trips
    where
     vendor_id = 6
     and rate_code_id = 99
     and payment_type = 0