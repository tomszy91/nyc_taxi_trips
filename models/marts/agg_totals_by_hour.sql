with

trips as (
    select * from {{ ref("fct_trips_enriched")}}
),

day_hour as (
    select
     *,
     extract(hour from meter_on) as hour
    from trips
),
final as (
select
    hour,
    sum(fare_amount) as total_fare_amount,
    sum(extra_charges) as total_extra_charges,
    sum(tax_amount) as total_tax_amount,
    sum(tip_amount) as total_tip_amount,
    sum(tolls_amount) as total_tolls_amount,
    sum(improvement_surcharge) as total_improvement_surcharge,
    sum(congestion_surcharge) as total_congestion_surcharge,
    sum(airport_fee) as total_airport_fee,
    sum(cbd_congestion_fee) as total_cbd_congestion_fee,
    sum(total_amount) as total_amount,
    sum(calculated_total_amount) as total_calculated_total_amount,
    sum(payment_discrepancy) as total_payment_discrepancy
from day_hour
group by hour)

select * from final