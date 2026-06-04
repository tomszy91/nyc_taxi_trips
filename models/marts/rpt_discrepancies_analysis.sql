with
trips as (
    select
        vendor_id,
        rate_code_id,
        payment_type,
        total_amount,
        calculated_total_amount,
        payment_discrepancy
    from
        {{ ref("fct_trips_enriched")}}
),

final as (
    select
        vendor_id,
        rate_code_id,
        payment_type,
        sum(
            case
                when total_amount = calculated_total_amount then 0 else 1
            end) as total_trips_with_discrepancy,
        count(*) as total_trips,
        round(sum(
            case
                when total_amount = calculated_total_amount then 0 else 1
            end) / count(*) * 100.0, 2) as trips_with_discrepancy_share,
        round(avg(total_amount),2) as avg_total_amount,
        round(avg(calculated_total_amount),2) as avg_calculated_total_amount,
        min(payment_discrepancy) as min_payment_discrepancy,
        max(payment_discrepancy) as max_payment_discrepancy,
        round(avg(payment_discrepancy),2) as avg_payment_discrepancy
    from trips
    group by 
        vendor_id,
        rate_code_id,
        payment_type
)

select * from final