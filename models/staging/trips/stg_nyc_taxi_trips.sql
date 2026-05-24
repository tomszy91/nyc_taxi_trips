with source as (
    select * from {{ source('local_parquet_source', 'nyc_taxi_trips') }}
),

renamed as (
    select
        VendorID as vendor_id,
        tpep_pickup_datetime as meter_on,
        tpep_dropoff_datetime as meter_off,
        passenger_count as passenger_count,
        trip_distance as trip_distance,
        RatecodeID as rate_code_id,
        store_and_fwd_flag as stored_flag,
        PULocationID as meter_on_zone_id,
        DOLocationID as meter_off_zone_id,
        payment_type as payment_type,
        fare_amount as fare_amount,
        extra as extra_charges,
        mta_tax as tax_amount,
        tip_amount as tip_amount,
        tolls_amount as tolls_amount,
        improvement_surcharge as improvement_surcharge,
        total_amount as total_amount,
        congestion_surcharge as congestion_surcharge,
        Airport_fee as airport_fee,
        cbd_congestion_fee as cbd_congestion_fee
    from source
)

select * from renamed