{{
  config(
    materialized='table'
  )
}}

SELECT 
    o.order_id
    , o.user_id
    , o.created_at
    , o.order_cost
    , o.shipping_cost
    , o.order_total
    , o.tracking_id
    , o.shipping_service
    , o.estimated_delivery_at
    , o.delivered_at
    , o.status    
    , p.discount      as promo_discount
    , p.status        as promo_status
    , a.address       as order_address
    , a.zipcode       as order_zipcode
    , a.state         as order_state
    , a.country       as order_county

FROM {{ ref ('stg_postgres__orders') }} o
LEFT JOIN {{ ref ('stg_postgres__promos') }} p on o.promo_id = p.promo_id
LEFT JOIN {{ ref ('stg_postgres__addresses') }} a on o.promo_id = a.address_id
