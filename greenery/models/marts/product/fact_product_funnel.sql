{{
  config(
    materialized='table'
  )
}}


select 
date(created_at)                                                  as date
, user_id
, max(case when event_type = 'page_view' then 1 else 0 end)       as is_page_view
, max(case when event_type = 'add_to_cart' then 1 else 0 end)     as is_add_to_cart
, max(case when event_type = 'checkout' then 1 else 0 end)        as is_checkout
, max(case when event_type = 'package_shipped' then 1 else 0 end) as is_package_shipped
from {{ ref ('stg_postgres__events') }}
group by all