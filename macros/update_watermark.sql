{% macro update_watermark(table_name) %}
    delete from nyc_taxi_trips.raw._metadata_watermarks where table_name = '{{ table_name }}';
    insert into nyc_taxi_trips.raw._metadata_watermarks (table_name, last_meter_on)
    values ('{{ table_name }}', (select max(meter_on) from {{ this }}))
{% endmacro %}