-- Tests that trip_id for recent records.
-- "Recent" = last 35 days relative to the latest meter_on in the table.
-- Singular test used instead of generic unique with config.where
-- because {{ this }} does not resolve correctly in generic test config
-- for the dbt-duckdb adapter.

with recent as (
    select trip_id
    from {{ ref('int_trips_cleaned') }}
    where meter_on::date >= (
        select max(meter_on)::date - interval '35 day'
        from {{ ref('int_trips_cleaned') }}
    )
),
duplicates as (
    select trip_id, count(*) as n
    from recent
    group by trip_id
    having count(*) > 1
)
select * from duplicates