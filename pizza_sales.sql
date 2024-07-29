/* to handle secure file error select @@secure_file_priv;
[mysqld]
 secure-file-priv=""
 */


drop database  if exists pizzasales;
create database pizzasales;



use pizzasales;
drop table if exists pizza_sales;
create table pizza_sales
( pizza_id int,
order_id int,
pizza_name_id  varchar(200),
quantity int ,
order_date varchar(50) ,
order_time varchar(50),
unit_price float,
total_price float,
pizza_size varchar(10),
pizza_category varchar(200),
pizza_ingredients varchar (300),
pizza_name varchar (200)
);


describe pizza_sales;

select  * from pizza_sales;

load data  infile 'C:/pizza.csv' into table pizza_sales
fields terminated by ','
lines terminated by '\r\n'
ignore 1 lines;
select  * from pizza_sales;


-- NOTE 
/*
issues encountered while importing data
1. secure file
2. then truncated rows, doesnt fit etc
, was error it was treating it as other row so replacing the field data by other sign but dont use , 
because the csv is comma seprated so it will take all values of each row as different field
*/


-- dropping table pizza_id it is simply S.No
alter table pizza_sales
drop column pizza_id;

-- Disabling only group by function

SET SESSION sql_mode = (SELECT REPLACE(@@sql_mode, 'ONLY_FULL_GROUP_BY', ''));

select  * ,count(pizza_size) as total_pizza from pizza_sales
group by pizza_size
;


-- -----------------------------------  QUERIES  ----------------------------------------------- --
-- 1. find Total Revenue Generated
select round(sum(total_price))as Total_Revenue from pizza_sales;



-- 2.  average order value (Hint-- divide total revenue by count of unique order id .. as some unique id having multiple pizza order )
select sum(total_price)/count(distinct(order_id))  as Average_Order_Value from pizza_sales;


-- 3. Total sum of pizza sold
select sum(quantity) as Total_pizza_sold from pizza_sales;

-- 4. Total Orders 
select count(distinct(order_id)) from pizza_sales;

-- 5. averge pizza per order
select sum(quantity)/count(distinct(order_id)) as Average_pizza_per_order from pizza_sales;


-- we can us cast(sum(quantity),decimal(10,2)) for showing values in decimal if we get result in roundoff


--  --------------------------------------------               --------------------------------------------------                             --------------------------------
--                                                       Finding Data which will be helpful in Visualization in Charts
--  --------------------------------------------               --------------------------------------------------                             --------------------------------

-- A. daily Pizza Order trend
 -- 'W' to get day of the data from order_Date column

select date_format(order_date,'%W') as order_day ,count(distinct(order_id)) as Total_orders from pizza_sales
group by date_format(order_date,'%W');

-- changing format from dd-mm-yyyy to yyyy-mm-dd
UPDATE pizza_sales
SET order_date = DATE_FORMAT(STR_TO_DATE(order_date, '%d/%m/%Y'), '%Y/%m/%d')
WHERE order_date IS NOT NULL;
select * from pizza_sales;
describe  pizza_Sales;
-- ---------------------------------------------
-- B. Hourly pizza order Trend
SELECT hour(order_time) AS order_hours, count(distinct(order_id)) as Total_orders from pizza_sales
group by hour(order_time)
order by Total_orders Desc;

select * from pizza_sales;

-- C. precentage of sales by pizza_category
select pizza_category,cast(sum(total_price) as decimal(10,2)) as total_Sales,cast(sum(total_price) *100/(select sum(total_price) from pizza_sales where month(order_Date)=12) as decimal(10,2)) as Percentage_of_Total_sales from pizza_sales 
where month(order_Date)=12
group by pizza_category;

-- used cast function to remove extra values after decimal like 
-- ^^ above query for december month sales by pizza category,, NOTE(also add where clause in sub query too


-- C. precentage of sales by pizza_size

select pizza_size ,cast(sum(total_price) as decimal(10,2)),sum(total_price)*100/(select sum(total_price) from pizza_sales where month(order_date)=12) as  Percentage_of_Total_sales from pizza_sales
where month(order_date)=12
group by pizza_Size;
-- ^^ above query for december month sales by pizza size,, NOTE(also add where clause in sub query too



-- D. how many pizza sold by pizza_category
select pizza_category,sum(quantity) from pizza_sales
group by pizza_category;


-- E. Top 5 best selling Pizza
select * from pizza_sales;

select pizza_name,sum(quantity) from pizza_sales
where month(order_date)=12
group by pizza_name
order by sum(quantity) desc
limit 5;




