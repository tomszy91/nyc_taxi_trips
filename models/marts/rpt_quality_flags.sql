with
trips as (
    select
        date_trunc('month', meter_on) as report_year_month,
        vendor_id,
        vendor_name,        
        rate_code_id,
        rate_code_description,        
        payment_type,
        payment_type_description,        
        is_suspicious,
        is_returned
    from
        {{ ref("fct_trips_enriched")}}
),

flags_count as (
    select
        report_year_month,
        vendor_id,
        vendor_name,             
        rate_code_id,
        rate_code_description,           
        payment_type,
        payment_type_description,            
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
        report_year_month,
        vendor_id,
        vendor_name,             
        rate_code_id,
        rate_code_description,           
        payment_type,
        payment_type_description,          
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
    report_year_month,
    vendor_id,
    vendor_name,    
    rate_code_id,
    rate_code_description,
    payment_type,
    payment_type_description,    
    total_trips,
    total_suspicious_trips,
    suspicious_trips_share,
    total_returned_trips,
    returned_trips_share
from
    shares
)

select * from final