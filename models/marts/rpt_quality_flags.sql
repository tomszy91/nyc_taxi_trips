with
trips as (
    select
        vendor_id,
        rate_code_id,
        payment_type,
        is_suspicious,
        is_returned
    from
        {{ ref("fct_trips_enriched")}}
),

flags_count as (
    select
        vendor_id,
        rate_code_id,
        payment_type,
        count(*) as total_trips,
        
        sum(
            case
                when is_suspicious is true then 1 else 0
            end) as total_suspicious_trips,

        sum(
            case
                when is_returned is true then 1 else 0
            end) as total_returned_trips

    from trips
    group by 
        vendor_id,
        rate_code_id,
        payment_type
),

shares as (
    select
        *,
        round((total_suspicious_trips / total_trips) * 100, 2) as suspicious_trips_share,
        round((total_returned_trips / total_trips) * 100, 2) as returned_trips_share
    from flags_count
),
final as (
select
    vendor_id,
    rate_code_id,
    payment_type,
    total_trips,
    total_suspicious_trips,
    suspicious_trips_share,
    total_returned_trips,
    returned_trips_share
from
    shares
)

select * from final