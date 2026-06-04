select
    calculated_total_amount,
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
    ) as expected_total_amount
from {{ ref("int_trips_calculated_total") }}
where calculated_total_amount != expected_total_amount