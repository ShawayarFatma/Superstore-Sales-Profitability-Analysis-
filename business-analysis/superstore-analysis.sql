select * from superstore_stage order by rowid limit 10;

--overall business performance
select sum(sales) as total_sales, sum(profit) as total_profit, count(distinct orderid) as total_no_of_orders,
round((sum(profit)*100.0/sum(sales))::numeric,2) as profit_margin from superstore_stage;

--average order value
with cte as 
(
select orderid, sum(sales) as total_sales from superstore_stage
group by orderid
)
select round(avg(total_sales)::numeric,2) as aov from cte;

--sales by category and sales % contribution by category
SELECT 
  category,
  SUM(sales) AS total_sales,
  round((SUM(sales) * 100.0 / SUM(SUM(sales)) OVER ())::numeric,2) AS sales_contribution
FROM superstore_stage
GROUP BY category;

--top 10 products by revenue
select productname,sum(profit) as profit, sum(sales) as sales, round((sum(profit)*100.0/sum(sales))::numeric,2) as profit_margin,
RANK() OVER (ORDER BY SUM(sales) DESC) AS sales_rank,
  RANK() OVER (ORDER BY SUM(profit)*1.0/SUM(sales) DESC) AS margin_rank
from superstore_stage group by 1 order by 5 limit 10;

--profit and profit margin by category
select category, sum(profit) as total_profit,
round((sum(profit)*100.0/sum(sales))::numeric,2) as profit_margin 
from superstore_stage
group by 1;

--profit margin by sub category
select subcategory, sum(sales) as total_sales, sum(profit) as total_profit,
round((sum(profit)*100.0/sum(sales))::numeric,2) as profit_margin 
from superstore_stage
group by 1 order by 4 desc;

--top 5 and bottom 5 subcategory by profit margin
with cte as
(
select subcategory, sum(profit) as profit, sum(sales) as sales, round((sum(profit)*100.0/sum(sales))::numeric,2) as profit_margin
from superstore_stage ss group by 1
)
select 'top 5' as top_performers,*
from 
(select * from cte order by profit_margin desc limit 5) top5
 union all
select 'bottom 5' as worst_performers,* 
from 
(select * from cte order by profit_margin asc limit 5) bottom5;

--compare sales rank vs profit margin rank
select productname, sum(profit) as profit, sum(sales) as sales, round((sum(profit)*100.0/sum(sales))::numeric,2) as profit_margin,
dense_rank() over (order by sum(sales) desc) as sales_rank,
dense_rank() over (order by (sum(profit)*100.0/sum(sales)) desc) as margin_rank,
abs(
  dense_rank() over (order by sum(sales) desc) -
  dense_rank() over (order by (sum(profit)*100.0/sum(sales)) desc)
) as rank_gap
from superstore_stage group by 1
order by 7 desc;

--products classification based on revenue and profit margin
with cte as
(
select productname,sum(profit) as profit, sum(sales) as sales, round((sum(profit)*100.0/sum(sales))::numeric,2) as profit_margin
from superstore_stage group by 1
), 
cte2 as
(
select avg(sales) as avgsales, avg(profit_margin) as avgprofitmargin from cte
)
select cte.*,
case 
	when cte.sales>=avgsales and cte.profit_margin>=avgprofitmargin then 'high revenue high margin'
	when cte.sales>=avgsales and cte.profit_margin<avgprofitmargin then 'high revenue low margin'
	when cte.sales<avgsales and cte.profit_margin>=avgprofitmargin then 'low revenue high margin'
	else 'low revenue low margin'
end as product_classification
from cte cross join cte2
order by cte.sales desc, cte.profit_margin desc;

--sales and profit by region
select region, sum(sales) as total_sales, sum(profit) as total_profit,
round((sum(profit)*100.0/sum(sales))::numeric,2) as profit_margin 
from superstore_stage
group by 1
order by total_sales desc, profit_margin desc;

--sales and profit by segment
select segment, sum(sales) as total_sales, sum(profit) as total_profit,
round((sum(profit)*100.0/sum(sales))::numeric,2) as profit_margin 
from superstore_stage
group by 1
order by total_sales desc, profit_margin desc;

--region + category performance
select region, category, sum(sales) as total_sales, sum(profit) as total_profit,
round((sum(profit)*100.0/sum(sales))::numeric,2) as profit_margin 
from superstore_stage
group by 1,2
order by 1,3 desc;

--monthly sales trend
select extract('month' from orderdate) as months,
sum(case when extract('year' from orderdate)=2014 then sales end) as year_2014,
sum(case when extract('year' from orderdate)=2015 then sales end) as year_2015,
sum(case when extract('year' from orderdate)=2016 then sales end) as year_2016,
sum(case when extract('year' from orderdate)=2017 then sales end) as year_2017
from superstore_stage
group by 1
order by 1;

--monthly profit trent
select extract('month' from orderdate) as months,
sum(case when extract('year' from orderdate)=2014 then profit end) as year_2014,
sum(case when extract('year' from orderdate)=2015 then profit end) as year_2015,
sum(case when extract('year' from orderdate)=2016 then profit end) as year_2016,
sum(case when extract('year' from orderdate)=2017 then profit end) as year_2017
from superstore_stage
group by 1
order by 1;

--month over month growth
with cte as
(
select date_trunc('month', orderdate) as months,
sum(sales) as total_sales
from superstore_stage
group by 1 order by 1
)
select months, total_sales as curr_sales,
lag(total_sales) over (order by months) as prev_sales,
round(((total_sales-(lag(total_sales) over (order by months)))*100.0
/lag(total_sales) over (order by months))::numeric,2) as mom_growth_perc
from cte;

--top 10 customer by revenue
select customerid, customername, sum(sales) as revenue, sum(profit) as profit,
round((sum(profit)*100.0/sum(sales))::numeric,2) as margin,
round((sum(sales)*100.0/sum(sum(sales)) over())::numeric,2) as revenue_contribution
from superstore_stage
group by 1,2 
order by 3 desc 
limit 10;

--customer contribution towards sales
with cte as 
(
	select customerid, sum(sales) as total_sales
	from superstore_stage
	group by 1
),
ranked as 
(
	select *, 
	row_number() over(order by total_sales desc, customerid) as num,
	sum(total_sales) over(order by total_sales desc, customerid) as cummulative_sales,
	sum(total_sales) over() as overall_sales
	from cte
),
cumm as 
(
	select customerid, total_sales, num, cummulative_sales, overall_sales,
	cummulative_sales*100.0/overall_sales as cumm_perc 
	from ranked order by 2 desc
)
select min(num) as customer_for_80pct, max(num) as total_customer,
round((min(num)*100.0/max(num))::numeric,2) as pct_customer
from cumm where cumm_perc>=80;

--customer contibution towards profit
with cte as 
(
	select customerid, sum(profit) as total_profit
	from superstore_stage
	group by 1
),
ranked as 
(
	select *, 
	row_number() over(order by total_profit desc, customerid) as num,
	sum(total_profit) over(order by total_profit desc, customerid) as cummulative_profit,
	sum(total_profit) over() as overall_profit
	from cte
)
select customerid, total_profit, num, cummulative_profit, overall_profit,
	cummulative_profit*100.0/overall_profit as cumm_perc 
	from ranked order by 2 desc;

select min(num) as customer_for_80pct, max(num) as total_customer,
round((min(num)*100.0/max(num))::numeric,2) as pct_customer
from cumm where cumm_perc>=80;

--top 25% customer by profit margin
with cte as 
(
	select customerid, customername, sum(sales) revenue, sum(profit) as profit,
	round((sum(profit)*100.0/sum(sales))::numeric,2) as margin
	from superstore_stage
	group by 1,2
),
filtered as
(
	select *,
	ntile(4) over (order by margin desc, revenue desc, customerid) as margin_bucket
	from cte where revenue >= 
				(select avg(revenue) from cte)
)
select customerid, customername, revenue, profit, margin
from filtered where margin_bucket=1
order by margin desc, revenue desc;

--loss making customers
select customerid, customername, sum(sales) as total_sales, sum(profit) as loss,
round((sum(profit)*100.0/sum(sales))::numeric,2) as loss_margin
from superstore_stage 
group by 1,2
having sum(profit)<0
order by total_sales desc, loss_margin desc;

-------impact of discount on profit----------

--impact of discount level
select discount, count(distinct orderid) as total_orders,
sum(sales) as total_sales,
sum(profit) as total_profit,
round((sum(profit)*100.0/sum(sales))::numeric,2) as profit_margin
from superstore_stage ss 
group by 1
order by 1;					ERRD 

--dicount buckets
with cte as 
(
	select *, round(discount::numeric,2) as dis
	from superstore_stage ss 
)
select 
case 
	when dis=0 then 'no discount'
	when dis>0 and dis<=0.10 then 'low discount(<10%)'
	when dis>0.10 and dis<=0.20 then 'medium discount(10-20%)'
	when dis>0.20 and dis<=0.30 then 'medium high discount(20-30%)'
	else 'high disount(>30%)'
end as discount_bracket,
count(distinct orderid) as total_orders,
sum(sales) as total_sales,
sum(profit) as total_profit,
round((sum(profit)*100.0/sum(sales))::numeric,2) as profit_margin
from cte 
group by 1;

--dicount by category
select category, discount, sum(sales) as total_sales,
sum(profit) as total_profit,
round((sum(profit)*100.0/sum(sales))::numeric,2) as profit_margin
from superstore_stage ss 
group by 1,2
order by 1,2;

--discount by subcategory
select subcategory, discount, sum(sales) as total_sales,
sum(profit) as total_profit,
round((sum(profit)*100.0/sum(sales))::numeric,2) as profit_margin
from superstore_stage ss 
group by 1,2
order by 2,1;

--------quantity vs sales, profit and margin-----------

--quantity by subctegory
select subcategory, sum(quantity) sold, sum(sales) as revenue,
sum(profit) as total_profit,
round((sum(profit)*100.0/sum(sales))::numeric,2) as profit_margin,
round((sum(sales)/sum(quantity))::numeric,2) as revenue_per_unit,
round((sum(profit)/sum(quantity))::numeric,2) as profit_per_unit
from superstore_stage ss 
group by 1
order by 2 desc;

--high quantity lossing making products
select productname, sum(quantity) as product_quantity,
sum(sales) as revenue, sum(profit) as total_profit,
round((sum(profit)*100.0/sum(sales))::numeric,2) as profit_margin
from superstore_stage ss 
group by 1
having sum(profit)<0 and
sum(quantity) >= (select avg(totalpd) as avg_pq
					 from 
					 (select sum(quantity) as totalpd from superstore_stage group by productname) q
				 )
order by 2 desc;












































