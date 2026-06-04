# Modern Data Stack - nyc_taxi_trips (dbt + DuckDB)

[![Python](https://img.shields.io/badge/Python-3.12-blue.svg)](https://www.python.org/)
[![dbt](https://img.shields.io/badge/dbt-1.10-orange.svg)](https://www.getdbt.com/)
[![DuckDB](https://img.shields.io/badge/duckdb-1.4.4-%23FFF000.svg)](https://duckdb.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A dbt portfolio project built on NYC Taxi & Limousine Commission (TLC) Yellow Taxi trip data. The pipeline transforms raw Parquet files into analytics-ready mart tables designed for direct consumption in Power BI or any other BI tool.

**Stack:** dbt 1.10 · DuckDB · local Parquet + CSV sources

---

## Business context

The project simulates an analytics engineering task for a taxi fleet operations team. Raw trip data from vendor systems arrives as monthly Parquet dumps. The goal is to deliver clean, documented, tested models that answer the following business questions without any further transformation in the BI layer:

- What is daily and weekly revenue by pickup borough?
- Which hours and days of the week generate the most revenue?
- Where do financial discrepancies between reported and calculated fares come from, and are they vendor-specific?
- What share of trips carry data quality flags (suspicious activity, charge reversals)?

---

## Data sources

| Source                      | Format             | Description                                                           |
| --------------------------- | ------------------ | --------------------------------------------------------------------- |
| `yellow_tripdata_*.parquet` | Parquet (wildcard) | Raw trip fact records published monthly by NYC TLC                    |
| `taxi_zone_lookup.csv`      | CSV                | Reference table mapping LocationID to borough, zone, and service zone |

Raw data: [NYC TLC Trip Record Data](https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page)

---

## Project structure

```bash
models/
  staging/
    trips/
      stg_nyc_taxi_trips.sql                    -- rename, cast, no logic
      int_trips_calculated_total.sql            -- recalculate total from components, derive discrepancy
      int_trips_cleaned.sql                     -- remove physical outliers (speed, distance, time)
      int_trips_flagged.sql                     -- flag suspicious trips, charge reversals, add duration/speed
    zones/
      stg_nyc_taxi_zones.sql                    -- rename, cast
      int_zones_enriched.sql                    -- handle LocationID 264/265, add zone_status flag
  marts/
    fct_trips_enriched.sql                      -- join trips with zones, main fact table
    agg_daily_totals_by_pickup_borough.sql
    agg_weekly_totals_by_pickup_borough.sql
    agg_totals_by_hour.sql
    agg_totals_by_weekday.sql
    rpt_discrepancies_analysis.sql
    rpt_quality_flags.sql

macros/
  tests/
    not_negative.sql                  -- custom test: rejects negative values
    not_before_date.sql               -- custom test: rejects timestamps before 1970-01-01

tests/
  calculated_total_is_correct.sql     -- singular test: validates total recalculation logic
```

## Lineage

![image](png/lineage.png)

---

## Key design decisions

**Staging is rename-and-cast only.** No logic, no flags, no derived columns. This makes it trivial to swap the source format or add a new data provider without touching downstream models.

**Intermediate layer is split by responsibility.** Each `int_` model has one job: `int_trips_calculated_total` recalculates totals, `int_trips_cleaned` removes physical outliers, `int_trips_flagged` adds quality flags. Splitting them keeps the lineage readable and makes it possible to test each transformation step independently.

**Zone edge cases are handled in `int_zones_enriched`, not in the fact model.** LocationIDs 264 and 265 have special meaning in the TLC data dictionary (Unknown and Outside of NYC). The hardcoded mapping lives in one place; `fct_trips_enriched` does a clean join with no knowledge of those IDs.

**Suspicious trips and charge reversals are flagged, not removed.** The columns `is_suspisious` and `is_returned` are boolean flags. The decision on whether to filter them sits with the business user in PBI, not in the pipeline. Both open decisions are documented inline in the YAML.

**`payment_discrepancy` is an explicit column, not a filter.** The difference between `total_amount` (vendor-reported) and `calculated_total_amount` (sum of components) is surfaced for every trip and aggregated in `rpt_discrepancies_analysis`. This makes vendor-specific logging defects visible rather than silently absorbed.

---

## Mart tables for Power BI

All mart tables are materialized as `table`. They are ready to load directly into Power BI with no additional transformation needed.

| Model                                 | Grain                             | Primary use                             |
| ------------------------------------- | --------------------------------- | --------------------------------------- |
| `fct_trips_enriched`                  | One row per trip                  | Base fact table; slice by any dimension |
| `agg_daily_totals_by_pickup_borough`  | Date x Borough                    | Daily revenue trend by area             |
| `agg_weekly_totals_by_pickup_borough` | ISO Year-Week x Borough           | Weekly revenue trend by area            |
| `agg_totals_by_hour`                  | Hour of day (0-23)                | Peak hour analysis                      |
| `agg_totals_by_weekday`               | ISO day of week (1=Mon, 7=Sun)    | Weekday vs weekend patterns             |
| `rpt_discrepancies_analysis`          | Vendor x Rate code x Payment type | Data quality audit                      |
| `rpt_quality_flags`                   | Vendor x Rate code x Payment type | Data quality audit                      |

---

## Data quality and testing

**Custom macros:**

- `not_negative` -- fails if any value in the column is below zero
- `not_before_date` -- fails if any timestamp predates 1970-01-01

**Packages used:**

- `dbt-labs/codegen` -- schema YAML generation during development
- `metaplane/dbt_expectations` -- extended column-level expectations (value ranges, column pair comparisons)

**Test coverage includes:**

- Source not_null and accepted_values on all key columns
- Referential integrity between trip zone IDs and the zone lookup table
- Row count parity between intermediate models (`equal_rowcount`)
- Physical bounds on `trip_distance` and `average_speed`
- Temporal ordering (`meter_off > meter_on`) enforced at model level
- Singular test validating the `calculated_total_amount` formula

---

## Known limitations and open items

**Incremental loading is not yet implemented.** All models currently rebuild in full on every `dbt run`. For production use with multi-month data, `fct_trips_enriched` and the aggregation marts should be converted to `materialized = 'incremental'` with an appropriate `unique_key`. This is the next planned development step.

**`is_returned` flags both records in a charge/reversal pair.** The current implementation marks both the original charge and its reversal as `is_returned = true`. The correct treatment (deduplicate vs. keep both) is a pending business decision. See inline comment in `int_trips_flagged.sql`.

---

## Setup

**Requirements:** dbt-duckdb, dbt 1.10+

```bash
# Install packages
dbt deps

# Place source files
# Parquet:  ./data/yellow_tripdata_*.parquet
# CSV:      ./data/taxi_zone_lookup.csv

# Run
dbt run

# Test
dbt test

# Generate docs
dbt docs generate && dbt docs serve
```

Configure `profiles.yml` for the `nyc_taxi_trips` profile pointing to `./dev.duckdb`.
