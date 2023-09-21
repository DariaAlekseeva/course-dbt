{{
  config(
    materialized='table'
  )
}}


select 
      pt.date
    , pt.product_id
    , pt.page_url
    , count(distinct pt.session_id) session_count
    , count(pt.session_id) page_view_count
    , count(distinct pt.user_id) user_count
    , sum(order_count) order_count
    
from {{ ref('int_product_traffic') }} pt
left join {{ ref('int_session_orders') }} so on pt.session_id = so.session_id
group by all
