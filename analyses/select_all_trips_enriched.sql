with trips as (
    select * from {{ ref("int_trips_enriched")}}
    )

select * from trips