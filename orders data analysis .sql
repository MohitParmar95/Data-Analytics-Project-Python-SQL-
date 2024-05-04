-- New script in localhost 2.
-- Date: May 2, 2024
-- Time: 12:24:25 PM

create database master;
use master;

select * from df_orders;

drop table df_orders;

create table df_orders(
order_id int primary key,
order_date date,
ship_mode varchar(20),
segment varchar(20),
country varchar(20),
city varchar(20),
state varchar(20),
postal_code varchar(20),
region varchar(20),
category varchar(20),
sub_category varchar(20),
product_id varchar(50),
quantity int,
discount decimal(7,2),
sale_price decimal(7,2),
profit decimal(7,2))

select * from df_orders;

-- find the top 10 revenue generating products
select product_id ,sum(sale_price) total_sale
from df_orders 
group by product_id 
order by total_sale desc limit 10;

-- top 5 highest selling products in each region
with cte as (
select region,product_id ,sum(sale_price) sales
from df_orders
group by product_id,region)
select * from (
select *,
row_number() over(partition by region order by sales desc) as rn 
from cte ) a
where rn <= 5;

-- find month over monthgrowth comparision for 2022 and 2023 sales, jan 2022 vs jan 2023
with cte as (
select year(order_date) years,month(order_date) months,sum(sale_price) sales
from df_orders
group by years,months
)
select months,
sum(case when years = 2022 then sales else 0  end) as sales_2022,
sum(case when years = 2023 then sales else 0  end) as sales_2023
from cte
group by months
order by months;

-- for each categry which month had highest sales
with cte as (
select category,order_date,sum(sale_price) as sales
from df_orders
group by category,order_date 
)
select * from(
select *,
row_number() over(partition by category order by sales desc) rn
from cte) a
where rn=1;

-- which sub category had highest growth by profit in 2023 compare to 2022
with cte as (
select sub_category,year(order_date) years,sum(sale_price) sales
from df_orders
group by years,sub_category
)
,cte2 as(
select sub_category,
sum(case when years = 2022 then sales else 0  end) as sales_2022,
sum(case when years = 2023 then sales else 0  end) as sales_2023
from cte
group by sub_category)
select * ,
((sales_2023 - sales_2022)*100 / sales_2022) as growth 
from cte2
order by growth desc
limit 1;


