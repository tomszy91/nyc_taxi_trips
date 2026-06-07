-- Tests that average_speed stays within physical bounds (0-100 mph) for recent records.
-- Nulls are excluded intentionally: average_speed is null for zero-distance or
-- zero-duration trips, which is correct model behaviour documented in the column description.
-- Singular test used instead of dbt_expectations generic test because {{ this }}
-- does not resolve correctly in generic test config for the dbt-duckdb adapter.

with recent as (
    select
        trip_id,
        average_speed
    from {{ ref('int_trips_flagged') }}
    where meter_on::date >= (
        select max(meter_on)::date - interval '35 day'
        from {{ ref('int_trips_flagged') }}
    )
      and average_speed is not null
)

select *
from recent
where average_speed < 0
   or average_speed > 100
