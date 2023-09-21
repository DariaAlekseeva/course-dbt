{{
  config(
    materialized='table'
  )
}}

select 
    session_id
    , count(distinct order_id) order_count
from {{ ref('stg_postgres__events') }}
where order_id is not null
group by all