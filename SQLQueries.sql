/* --------------------
   Case Study Solutions
   --------------------*/

1. What is the total amount each customer spent at the restaurant?
  
select s.customer_id,sum(m.price) as total_amount_spent
from dannys_diner.sales s
left join dannys_diner.menu m
on s.product_id = m.product_id
group by 1;


-- 2. How many days has each customer visited the restaurant?

select customer_id, count(distinct order_date) as no_of_days_visited
from dannys_diner.sales 
group by 1;

-- 3. What was the first item from the menu purchased by each customer?

with first_order as (
select row_number() over (partition by customer_id order by order_date) as rn,
product_name,customer_id
from dannys_diner.sales s
left join dannys_diner.menu m
on s.product_id = m.product_id)

select customer_id,product_name from first_order 
where rn = 1;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

with most_purchased as (
select product_name,
count(s.product_id) as cnt
from dannys_diner.sales s
left join dannys_diner.menu m
on s.product_id = m.product_id
group by 1)

select product_name,cnt from
(
select *, row_number() over (partition by 1 order by cnt desc) as rn 
from most_purchased
)a where rn = 1;

-- 5. Which item was the most popular for each customer?

with prod as
(
select customer_id,product_name,
count(product_name) as cnt_prod
from dannys_diner.sales s
left join dannys_diner.menu m
on s.product_id = m.product_id
group by 1, 2)

select customer_id, product_name from(
select row_number() over (partition by customer_id 
  order by cnt_prod desc) as rnk, 
customer_id,product_name ,cnt_prod
from prod)a
where rnk = 1;


-- 6. Which item was purchased first by the customer after they became a member?

with orders as
(select s.customer_id,product_name,order_date
from dannys_diner.sales s
left join dannys_diner.menu m
on s.product_id = m.product_id
left join dannys_diner.members mb
on s.customer_id = mb.customer_id
where order_date > join_date)

select customer_id, product_name 
from (
select customer_id, product_name,
row_number() over (partition by customer_id order by order_date) rn
from orders)a  where rn = 1
 
 
-- 7. Which item was purchased just before the customer became a member?
 
with orders as(
select s.customer_id,product_name,order_date,m.product_id
from dannys_diner.sales s
left join dannys_diner.menu m
on s.product_id = m.product_id
left join dannys_diner.members mb
on s.customer_id = mb.customer_id
where order_date < join_date)

select customer_id, product_name, order_date,rn
from (
select customer_id, product_name,order_date,
row_number() over (partition by customer_id order by order_date desc) rn
from orders)a  where rn = 1;


-- 8. What is the total items and amount spent for each member before they became a member?

with orders as(
select s.customer_id,product_name,order_date,m.product_id,
  price
from dannys_diner.sales s
left join dannys_diner.menu m
on s.product_id = m.product_id
left join dannys_diner.members mb
on s.customer_id = mb.customer_id
where order_date < join_date)

select customer_id,count(product_id),sum(price)
from (
select customer_id, product_id,price
from orders)a
group by 1;


-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

with orders as(
select s.customer_id,product_name,order_date,m.product_id,
price
from dannys_diner.sales s
left join dannys_diner.menu m
on s.product_id = m.product_id
left join dannys_diner.members mb
on s.customer_id = mb.customer_id
)

select customer_id,sum(points) from (
select *,
case when product_name like 'sushi' then (price * 2 * 10) 
else (price * 10) end as points from orders
)a
group by 1;


-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, 
not just sushi - how many points do customer A and B have at the end of January?

with orders as(
select s.customer_id,product_name,order_date,m.product_id,
join_date,price
from dannys_diner.sales s
left join dannys_diner.menu m
on s.product_id = m.product_id
left join dannys_diner.members mb
on s.customer_id = mb.customer_id
)

select customer_id,sum(points) from (
select *,
(price * 2 * 10) as points from orders
where order_date between join_date and  (join_date + 7)
)a
group by 1;
