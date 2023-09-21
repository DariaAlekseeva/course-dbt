{{
  config(
    materialized='table'
  )
}}

SELECT 
    u.user_id
    , u.first_name
    , u.last_name
    , u.email         as user_email
    , u.phone_number  as user_phone
    , u.created_at    as user_created_at
    , u.updated_at    as user_updated_at 
    , a.address       as user_address
    , a.zipcode       as user_zipcode
    , a.state         as user_state
    , a.country       as user_county

FROM {{ ref('stg_postgres__users') }} u
LEFT JOIN {{ ref('stg_postgres__addresses') }} a
ON u.address_id = a.address_id