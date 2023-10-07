{{
  config(
    materialized='table'
  )
}}


select 
date
, sum(is_page_view) page_view_count
, sum(is_add_to_cart) add_to_cart_count
, sum(is_checkout) checkout_count
, sum(is_add_to_cart) / NULLIFZERO(sum(is_page_view)) page_view_to_add_cart_rate
, sum(is_checkout) / NULLIFZERO(sum(is_add_to_cart)) add_to_cart_to_checkout_rate
from {{ ref ('fact_product_user_activity') }}
group by 1