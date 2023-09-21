# Analytics engineering with dbt
## Week 2 - Answers
***1. What is our user repeat rate? Repeat Rate = Users who purchased 2 or more times / users who purchased***
* 77% in we include only orders with status = 'delivered'

```
with orders_per_user as
(
select 
    user_id
    , count(order_id) orders_per_user
from stg_postgres__orders
where status = 'delivered'
group by all
)

, cte_per_user as
(
select 
    user_id
    , max(case when orders_per_user = 1 then 1 else 0 end) has_1_order
    , max(case when orders_per_user >= 2 then 1 else 0 end) has_2plus_orders
from orders_per_user
group by all
)

select 
sum(has_2plus_orders) / count(user_id) repeat_rate
from cte_per_user;
```

***2. What are good indicators of a user who will likely purchase again? What about indicators of users who are likely NOT to purchase again? If you had more data, what features would you want to look into to answer this question?***   

NOTE: This is a hypothetical question vs. something we can analyze in our Greenery data set. Think about what exploratory analysis you would do to approach this question.  

Indicators of users who are more likely to purchase:
* no issues with the order like delays or missing items
* no customer support contact regarding the quality of product or anything else
* visiting the page/app after the purchase in the following days/weeks
* viewing the products, start building the cart again
* high post order review
* if business has social media, resharing content of a business

Indicators of users who are NOT likely to repurchase:  
* issue with the order like delays or missing items
* any customer support contact
* not retuning to digital product (no page views or app opens)
* low port order rating 

***3. Explain the product mart models you added. Why did you organize the models in the way you did?***
I created 3 marts
* Product 
* Core
* Marketing

* Within *Products*, I also created intermidiate layer to first create `product_traffic` model and `sessions_orders` which then joined into a `fact_product_traffic_orders` model.
I also created a `fact_product_funnel` table for upcoming project.
* In *Core* I've got dim_users, dim_products and fact_orders as these are the key tables that the whole business may need.
* In *Marketing* I joined users with orders to be able to answer questions like what sort of customer place what kinds of orders.

***4. What assumptions are you making about each model? (i.e. why are you adding each test?)***
* I mostly tested for uniqueness and not being null and also added a check for positive value to number of orders and AOV in `fact_users_orders` model.

***5. Did you find any “bad” data as you added and ran tests on your models? How did you go about either cleaning the data in the dbt model or adjusting your assumptions/tests?***  
* No, all tests passed!

***6. Which products had their inventory change from week 1 to week 2?***
* All products that I see in the table were injected last week. No change was detected.

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
