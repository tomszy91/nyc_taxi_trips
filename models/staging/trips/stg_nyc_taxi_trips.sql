with source as (
    select * from {{ source('local_parquet_source', 'nyc_taxi_trips') }}
),

renamed as (
    select
        md5(concat_ws('-', 
            coalesce(VendorID::string, ''), 
            coalesce(tpep_pickup_datetime::string, ''), 
            coalesce(tpep_dropoff_datetime::string, ''), 
            coalesce(PULocationID::string, ''), 
            coalesce(DOLocationID::string, ''), 
            coalesce(total_amount::string, '')
        )) as trip_id,
        cast(VendorID as smallint) vendor_id,
        cast(tpep_pickup_datetime as timestamp) as meter_on,
        cast(tpep_dropoff_datetime as timestamp) as meter_off,
        cast(passenger_count as smallint) as passenger_count,
        cast(trip_distance as decimal(8,2)) as trip_distance,
        cast(RatecodeID as smallint) as rate_code_id,
        cast(store_and_fwd_flag as char(1)) as stored_flag,
        cast(PULocationID as smallint) as meter_on_zone_id,
        cast(DOLocationID as smallint) as meter_off_zone_id,
        cast(payment_type as smallint) as payment_type,
        cast(fare_amount as decimal(8,2)) as fare_amount,
        cast(extra as decimal(8,2)) as extra_charges,
        cast(mta_tax as decimal(8,2)) as tax_amount,
        cast(tip_amount as decimal(8,2)) as tip_amount,
        cast(tolls_amount as decimal(8,2)) as tolls_amount,
        cast(improvement_surcharge as decimal(8,2)) as improvement_surcharge,
        cast(congestion_surcharge as decimal(8,2)) as congestion_surcharge,
        cast(Airport_fee as decimal(8,2)) as airport_fee,
        cast(cbd_congestion_fee as decimal(8,2)) as cbd_congestion_fee,
        cast(total_amount as decimal(8,2)) as total_amount
    from source
)

select * from renamed