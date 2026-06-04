with
trips as (
    select * from {{ ref("int_trips_enriched")}}
    ),
final as (
select
    meter_on::date as date,
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
from trips
group by meter_on::date, pickup_borough
)

select * from final