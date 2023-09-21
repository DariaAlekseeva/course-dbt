{{
  config(
    materialized='table'
  )
}}

SELECT 
    u.user_id
    , count(o.order_id)                                             as count_orders
    , count(case when o.promo_id is not null then o.promo_id end)   as count_promo_orders
    , date(min(o.created_at))                                       as first_order_date
    , date(max(o.created_at))                                       as last_order_date
    , round(avg(o.order_total),2)                                   as aov
FROM {{ ref ('stg_postgres__users') }} u 
LEFT JOIN {{ ref ('stg_postgres__orders') }} o 
ON u.user_id = o.user_id
WHERE o.status = 'delivered'
group by all