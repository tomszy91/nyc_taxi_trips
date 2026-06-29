{{
    config(
        materialized = 'incremental',
        unique_key = 'trip_id',
        incremental_strategy = 'delete+insert'
    )
}}

with source as (
    select * from {{ ref('int_trips_calculated_total') }}
    {% if is_incremental() %}
    where meter_on::date >= (select (max(meter_on) - interval '35 day') from {{ this }}) 
    {% endif %}
),

-- remove outliers
filtered_outliers as (
    select
        *
    from
        source
    where
        -- end time earlier than start time
        meter_on < meter_off

        -- maximum distance 500 miles
        and trip_distance > 0 and trip_distance < 500
        
        -- average speed lower than 100 mph
        and trip_distance::numeric / (datediff('second', meter_on, meter_off) / 3600::numeric) < 100
),
-- may be non-deterministic when there are two identical trip_distance values
deduplicated as (
    select 
        *,
        row_number() over (
            partition by trip_id
            order by trip_distance desc
        ) as rn
    from filtered_outliers
),
final as (
    select
        * exclude (rn)
    from deduplicated
    where rn = 1
)

select * from final