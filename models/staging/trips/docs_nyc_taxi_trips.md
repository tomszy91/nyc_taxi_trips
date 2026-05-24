{% docs vendorid %}

A code indicating the TPEP provider that provided the record.

| vendor id | vendor name                       |
|-----------|-----------------------------------|
| 1         | Creative Mobile Technologies, LLC |
| 2         | Curb Mobility, LLC                |
| 6         | Myle Technologies Inc             |
| 7         | Helix                             |

{% enddocs %}


{% docs ratecodeid %}

The final rate code in effect at the end of the trip.

| ratecodeid | ratecodeid description |
|------------|------------------------|
| 1          | Standard rate          |
| 2          | JFK                    |
| 3          | Newark                 |
| 4          | Nassau or Westchester  |
| 5          | Negotiated fare        |
| 6          | Group ride             |
| 99         | Null/unknown           |

{% enddocs %}

{% docs store_and_fwd_flag %}

This flag indicates whether the trip record was held in vehicle memory before sending to the vendor, aka “store and forward,” because the vehicle did not have a connection to the server.

| store_and_fwd_flag | store_and_fwd_flag description |
|--------------------|--------------------------------|
| Y                  | store and forward trip         |
| N                  | not a store and forward trip   |

{% enddocs %}

{% docs payment_type %}

A numeric code signifying how the passenger paid for the trip.

| payment_type | payment type description |
|--------------|--------------------------|
| 0            | Flex Fare trip           |
| 1            | Credit card              |
| 2            | Cash                     |
| 3            | Nassau or Westchester    |
| 4            | Negotiated fare          |
| 5            | Unknown                  |
| 6            | Voided trip              |

{% enddocs %}