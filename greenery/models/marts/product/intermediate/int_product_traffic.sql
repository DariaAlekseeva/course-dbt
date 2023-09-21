{{
  config(
    materialized='table'
  )
}}

select 
    date(created_at) date
    , product_id
    , page_url
    , session_id
    , user_id
from {{ ref('stg_postgres__events') }}
where event_type = 'page_view' and product_id is not null
