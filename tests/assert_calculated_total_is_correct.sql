-- Tests that calculated_total_amount matches the sum of individual fare components.
-- Scoped to the last day of data to keep runtime short on large incremental tables.
-- Singular test used instead of config.where with {{ this }} because that pattern
-- does not resolve correctly for the dbt-duckdb adapter.

with recent as (
    select
        trip_id,
        calculated_total_amount,
        (
            coalesce(fare_amount, 0)
            + coalesce(extra_charges, 0)
            + coalesce(tax_amount, 0)
            + coalesce(tip_amount, 0)
            + coalesce(tolls_amount, 0)
            + coalesce(improvement_surcharge, 0)
            + coalesce(congestion_surcharge, 0)
            + coalesce(airport_fee, 0)
            + coalesce(cbd_congestion_fee, 0)
        )::decimal(8,2) as expected_total_amount
    from {{ ref('int_trips_calculated_total') }}
    where meter_on::date >= (
        select max(meter_on)::date - interval '1 day'
        from {{ ref('int_trips_calculated_total') }}
    )
)

select *
from recent
where calculated_total_amount != expected_total_amount
