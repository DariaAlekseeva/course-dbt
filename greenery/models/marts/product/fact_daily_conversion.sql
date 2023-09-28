{{
  config(
    materialized='table'
  )
}}


select 
date
, sum(session_count)                    as session_count
, sum(order_count)                      as order_count
, sum(order_count) / sum(session_count) as daily_conversion
from {{ ref ('fact_product_traffic_orders') }}
group by all

