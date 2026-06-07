-- Tests that is_suspicious and is_returned are never null for recent records.
-- "Recent" = last 35 days relative to the latest meter_on in the table.
-- Singular test used instead of generic not_null with config.where
-- because {{ this }} does not resolve correctly in generic test config
-- for the dbt-duckdb adapter.

with recent as (
    select
        trip_id,
        is_suspicious,
        is_returned
    from {{ ref('int_trips_flagged') }}
    where meter_on::date >= (
        select max(meter_on)::date - interval '35 day'
        from {{ ref('int_trips_flagged') }}
    )
)

select *
from recent
where is_suspicious is null
   or is_returned is null
