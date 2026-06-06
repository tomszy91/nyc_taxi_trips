with trips as (
    select * from {{ref("fct_trips_enriched")}}
)

select count(*) from trips