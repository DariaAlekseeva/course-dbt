# Analytics engineering with dbt

## Week 1 - Answers

How many users do we have? 
* 130 users
```
select 
  count(user_id)
, count(distinct user_id) 
from stg_postgres__users
```
On average, how many orders do we receive per hour?
* 7.5 orders per hour
```
with orders_per_hour as
(
select 
    date_trunc('hour', created_at) hour
    , count(order_id) count_orders_per_hour
    from stg_postgres__orders
group by 1
)
select 
avg(count_orders_per_hour) avg_orders_per_hour
from orders_per_hour
```
 On average, how long does an order take from being placed to being delivered?
* 93.4 hours

```
with created_to_delivered_hours as
(
select 
    order_id
    , created_at
    , delivered_at
    , datediff('hour', created_at, delivered_at) created_to_delivered_hours
    from stg_postgres__orders
where delivered_at is not null
)
select 
avg(created_to_delivered_hours) avg_created_to_delivered_hours
from created_to_delivered_hours
```

How many users have only made one purchase? Two purchases? Three+ purchases?  
Note: you should consider a purchase to be a single order. In other words, if a user places one order for 3 products, they are considered to have made 1 purchase.
* 1	  25
* 2	  28
* 3+	71
```
with orders_per_user as 
(
select 
    u.user_id
    , count(order_id) orders_per_user
from stg_postgres__orders o
join stg_postgres__users u on o.user_id = u.user_id
group by 1
)
select 
    case when orders_per_user >= 3 then 3 else orders_per_user end orders_per_user
    , count(user_id)
from orders_per_user
group by 1
order by 1
```


On average, how many unique sessions do we have per hour?
* 16.3
```
with hourly_sessions as
(
select 
    date_trunc('hour', created_at) created_at_hour
    , count(distinct session_id) unique_sessions
from stg_postgres__events
group by 1
) 
select
    avg(unique_sessions)
from hourly_sessions
```







## License
GPL-3.0
