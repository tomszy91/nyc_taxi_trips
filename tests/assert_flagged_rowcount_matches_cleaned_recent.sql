-- Tests that checks rows in two tables from the last 35 days. dbt.utiltools equalsrow used before scanned entire tables, which -- was time and cost-consuming and redundand.
-- Scoped to the last day of data to keep runtime short on large incremental tables.

with cleaned as (
    select count(*) as n
    from {{ ref('int_trips_cleaned') }}
    where meter_on::date >= (
        select max(meter_on)::date - interval '35 day'
        from {{ ref('int_trips_cleaned') }}
    )
),
flagged as (
    select count(*) as n
    from {{ ref('int_trips_flagged') }}
    where meter_on::date >= (
        select max(meter_on)::date - interval '35 day'
        from {{ ref('int_trips_flagged') }}
    )
)
select *
from cleaned cross join flagged
where cleaned.n != flagged.n