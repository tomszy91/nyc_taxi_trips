with trips as (
    select * from {{ref("fct_trips_enriched")}}
)

select * from trips where vendor_id = 2 and rate_code_id = 1 and payment_type = 4