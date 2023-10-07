{{
  config(
    materialized='table'
  )
}}


select 
date(created_at)                                                  as date
, user_id
{{ event_processor('stg_postgres__events', 'event_type') }}
from {{ ref ('stg_postgres__events') }}
group by all