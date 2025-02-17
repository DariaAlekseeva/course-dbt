# Analytics engineering with dbt
## Week 4 - Answers
1. Which products had their inventory change from week 3 to week 4?
```
select *
from inventory_snapshot
where date(dbt_valid_to) = '2023-10-07';
```
* These products has update in inventory.
<img width="442" alt="image" src="https://github.com/DariaAlekseeva/course-dbt/assets/9542478/c520594f-ff54-462c-868e-a8259fbe1126">

1.1. Now that we have 3 weeks of snapshot data, can you use the inventory changes to determine which products had the most fluctuations in inventory?  
   
```
select product_id
, name
, count(1) 
from inventory_snapshot
group by 1,2
```
   * These products changed the inventory 3 times. The rest of products only 1 time.
   <img width="594" alt="image" src="https://github.com/DariaAlekseeva/course-dbt/assets/9542478/bbd32da9-51a3-4299-8a22-112f4832a7db">

1.2. Did we have any items go out of stock in the last 3 weeks? 
```
select *
from inventory_snapshot
where inventory = 0;
```
* These items had inventory 0.

<img width="669" alt="image" src="https://github.com/DariaAlekseeva/course-dbt/assets/9542478/7ab4b707-fef9-4c24-991b-528dc8e16339">

2. How are our users moving through the product funnel? Which steps in the funnel have largest drop off points?
```
select 
date
, sum(is_page_view)
, sum(is_add_to_cart)
, sum(is_checkout)
, sum(is_add_to_cart) / NULLIFZERO(sum(is_page_view)) page_view_to_add_cart_rate
, sum(is_checkout) / NULLIFZERO(sum(is_add_to_cart)) add_to_cart_to_checkout_rate
from fact_product_funnel
group by all;
```
* `page_view_to_add_cart_rate` has higher rate (based on a few observed days) `add_to_cart_to_checkout_rate`. Surprisingly, on 2 days both rates have either no data or very small count of sessions. Would need to investigate that further. 
<img width="1265" alt="image" src="https://github.com/DariaAlekseeva/course-dbt/assets/9542478/e6824f0c-290e-4a5a-8e5c-d76be289f1ad">

3. `exposures.yml` file was created. [Product Funnel Dashboard](https://app.sigmacomputing.com/corise-dbt/workbook/Product-Funnel-Dashboard-2uAsf5gohuhIvDBu8TS91G/edit?:nodeId=7NBPNwEvKO) (v1) was created in Sigma.

<img width="1697" alt="image" src="https://github.com/DariaAlekseeva/course-dbt/assets/9542478/c6399cc2-8643-402f-9146-843c3659216c">

4. Production/Scheduled dbt Run Setup
Steps:
* Environment Setup: Set up a production environment separate from the development environment to ensure stability and reliability.
* Orchestration Tool: Select an orchestration tool like Apache Airflow, Prefect, or dbt Cloud to schedule and monitor dbt runs. These tools support scheduling, logging, and alerting, which are crucial for production jobs.
* Scheduling: Define a schedule for dbt runs based on your data update frequency. For daily updated data, schedule dbt jobs to run nightly, ensuring fresh and reliable data is available every morning.
* Metadata Logging: Capture and log metadata like run status, duration, and row count changes. This metadata is crucial for monitoring data pipeline health and debugging issues. Also we can monitor freshness of data. 
* Alerts & Monitoring: Set up alerting mechanisms for job failures or significant data changes and model tests using the logged metadata to quickly identify and resolve issues.

## Week 3 - Answers
1. What is our overall conversion rate?  
* Created `fact_daily_conversion` model to answer this question. However the relusts are a bit puzzling. Conversion is unlikely to over 1 for a given day. Would investigate this furter and add test to monitor the value.  
<img width="651" alt="image" src="https://github.com/DariaAlekseeva/course-dbt/assets/9542478/ff589717-d1db-48c8-97f2-a4a86e880477">


3. What is our conversion rate by product?
* Created `fact_daily_product_conversion` model to answer this question. Conversions by day by product look more accurate.

Conversion rate examples by day by product:  
<img width="926" alt="image" src="https://github.com/DariaAlekseeva/course-dbt/assets/9542478/54a72bce-1fb7-4111-bc3d-abec6a4e4760">


3. A question to think about: Why might certain products be converting at higher/lower rates than others? We don't actually have data to properly dig into this, but we can make some hypotheses. 
* The factors could be price, deals/promos, product reviews, product ranking on the page, has/doesn't have a photo, sponsored items etc.
4. I added a post hook to your project to apply grants to the role “reporting”. 
5. I created `event_processor` macros that iterates over events from a given table and column and creates a column per event with a boolean value that flags if user performed given action.
Then I applied it in my model `fact_product_funnel.sql`
6. I installed `dbt-expectations` package and used `dbt_expectations.expect_column_values_to_be_in_set` macro on `event_type` column from `stg_postgres__events` model to check that we get all required events.
7. Which products had their inventory change from week 2 to week 3?
* `4cda01b9-62e2-46c5-830f-b7f262a58fb1`	    Pothos
* `689fb64e-a4a2-45c5-b9f2-480c2155624d`	    Bamboo
* `55c6a062-5f4a-4a8b-a8e5-05ea5e6715a3`	    Philodendron
* `be49171b-9f72-4fc9-bf7a-9a52e259836b`	    Monstera
* `fb0e8be7-5ac4-4a76-a1fa-2cc4bf0b2d80`	    String of pearls
* `b66a7143-c18a-43bb-b5dc-06bb5d1d3160`	    ZZ Plant

  <img width="1723" alt="image" src="https://github.com/DariaAlekseeva/course-dbt/assets/9542478/c4cbbc1c-7b31-41ea-989e-922f5ef4279c">

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
