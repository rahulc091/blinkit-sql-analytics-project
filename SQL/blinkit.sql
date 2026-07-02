create table if not exists bk_sales (
	product_id serial primary key,
	product_name varchar(100),
	category varchar(100),
	brand varchar(100),
	price numeric(5,2),
	discount_pct numeric(5,2),
	final_price	numeric(5,2),
	rating numeric(3,2),
	num_reviews int,
	delivery_time_min int,
	city varchar(100),
	seller varchar(100),
	stock int,
	sold_quantity int,
	profit_margin_pct numeric(5,2),
	is_organic boolean,
	packaging_type varchar(50),
	weight_g int,
	shelf_life_days int,
	reorder_level int,
	demand_index int,
	date_added date,
	expiry_date date,
	offer_type text,
	delivery_status text
);

drop table bk_sales;

select * from bk_sales;

copy bk_sales(product_id, product_name, category, brand, price, discount_pct, final_price, rating, num_reviews, delivery_time_min, city, seller, stock,
sold_quantity, profit_margin_pct, is_organic, packaging_type, weight_g, shelf_life_days, reorder_level, demand_index, date_added, expiry_date, offer_type, delivery_status)
from 'C:\Users\Public\Documents\blinkit_dataset.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');

select * from bk_sales
limit 5;

/*
1. Which products contribute the most to overall sales volume and revenue? 
*/
select product_name, category, sum(sold_quantity) as sales_volume,
sum(final_price * sold_quantity) as revenue from bk_sales
group by product_name, category
order by revenue desc
limit 3;

/*
2. Within the highest-revenue category, which products are the top revenue contributors? 
*/

select product_name, category, sum(sold_quantity) as sales_volume,
sum(final_price * sold_quantity) as revenue
from bk_sales
where category = (
    select category
    from bk_sales
    group by category
    ordder by sum(final_price * sold_quantity) desc
    limit 1
)
group by product_name, category
order by revenue desc
limit 5;

/*
3. How does average delivery time vary across cities? 
*/

select city, round(avg(delivery_time_min), 2) as avg_delivery_time from bk_sales
group by city
order by avg_delivery_time asc;

/*
4. How do the highest-revenue categories compare in terms of profit margins and delivery performance?
*/

select category, sum(final_price * sold_quantity) as revenue,
	round(avg(profit_margin_pct), 2) as profit_margin_pct,
	round(avg(delivery_time_min), 2) as avg_delivery_time,
	round(avg(rating), 2) as avg_rating
from bk_sales
group by category
order by revenue desc
limit 3;

/*
5. How do customer ratings vary among the most heavily discounted products? 
*/

select product_name, discount_pct, rating
from bk_sales
order by discount_pct desc
limit 5;

/*
6. What relationship exists between delivery performance and customer satisfaction? 
*/
select delivery_status, round(avg(delivery_time_min), 2) as avg_del_time,
round(avg(rating), 2) as avg_rating
from bk_sales
group by delivery_status;

/*
7. What is the shelf-life profile of organic products, and which products are most susceptible to early expiration?
*/

select round(avg(shelf_life_days), 2) as avg_shelf_life from bk_sales
where is_organic;
/*
	Where, total_rows: 13000;
	   	   unique_products: 12617;
           Difference: 383 (~3%)
*/

select product_name, shelf_life_days
from bk_sales
where is_organic
order by shelf_life_days asc
limit 5;

/*
8. Does shelf life appear to influence inventory reordering requirements? 
*/

select
	case
		when shelf_life_days < 100 then 'Short'
        when shelf_life_days < 300 then 'Medium'
        else 'Long'
    end as shelf_life_group,
    round(avg(reorder_level),2) as avg_reorder_level
from bk_sales
where is_organic
group by shelf_life_group;

/*
9. How do demand levels and stock availability vary across cities? 
*/

select city, round(avg(demand_index), 2) as avg_demand_index,
round(avg(stock), 2) as avg_stock,
round(avg(stock) - avg(demand_index),2) as stock_gap from bk_sales
group by city
order by avg_demand_index desc;

/*
10. How do promotional offers impact sales volume and revenue generation? 
*/
select offer_type, sum(sold_quantity) as total_sold_qty,
sum(final_price * sold_quantity) as total_revenue
from bk_sales
group by offer_type
order by total_sold_qty desc;