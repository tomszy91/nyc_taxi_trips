with
trips as (
    select * from {{ ref('stg_nyc_taxi_trips') }}
),

calculated_total as (
    select
    *,
    (
        coalesce(fare_amount,0) 									
        + coalesce(extra_charges,0)
        + coalesce(tax_amount,0)
        + coalesce(tip_amount,0)
        + coalesce(tolls_amount,0)
        + coalesce(improvement_surcharge,0)
        + coalesce(congestion_surcharge,0)
        + coalesce(airport_fee,0)
        + coalesce(cbd_congestion_fee,0)
    ) as calculated_total_amount
    from trips
    ),

difference as (
    select
        *,
        total_amount - calculated_total_amount as payment_discrepancy
    from calculated_total
)

select * from difference
