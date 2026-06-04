with

trips as (
    select * from {{ ref("int_trips_enriched")}}
),

year_week as (
    select
     *,
     extract (year from meter_on) * 100 + extract (week from meter_on) as year_week
    from trips
),

final as (
select
    year_week,
    pickup_borough,
    sum(fare_amount) as total_fare_amount,
    sum(extra_charges) as total_extra_charges,
    sum(tax_amount) as total_tax_amount,
    sum(tip_amount) as total_tip_amount,
    sum(tolls_amount) as total_tolls_amount,
    sum(improvement_surcharge) as total_improvement_surcharge,
    sum(congestion_surcharge) as total_congestion_surcharge,
    sum(airport_fee) as total_airport_fee,
    sum(cbd_congestion_fee) as_cbd_congestion_fee,
    sum(total_amount) as total_amount,
    sum(calculated_total_amount) as total_calculated_total_amount,
    sum(payment_discrepancy) as total_payment_discrepancy
from year_week
group by year_week, pickup_borough)

select * from final