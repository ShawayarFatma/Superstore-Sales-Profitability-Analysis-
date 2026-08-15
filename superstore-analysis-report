# Superstore Sales & Profitability Analysis — Full Report

**Tools:** PostgreSQL | **Dataset:** Superstore (`superstore_stage`) — Orders, Sales, Profit, Discount, Customer, Region, 2014–2017

This report documents the full SQL-based exploratory analysis behind the project, organized by business question. Each section includes the query, the result, and the business insight it produced.

---

## 1. Business Overview

### Q1. Total Business Performance

```sql
select sum(sales) as total_sales, sum(profit) as total_profit,
       count(distinct orderid) as total_no_of_orders,
       round((sum(profit)*100.0/sum(sales))::numeric,2) as profit_margin
from superstore_stage;
```

| total_sales | total_profit | total_no_of_orders | profit_margin |
|---|---|---|---|
| 2,296,938.80 | 286,409.06 | 5,009 | 12.47% |

**Insight:** The business is profitable overall, but a 12.47% margin against $2.29M in sales signals real inefficiency in pricing, discounting, or cost structure — enough to warrant deeper category and product-level investigation.

### Q2. Average Order Value (AOV)

```sql
with cte as (
  select orderid, sum(sales) as total_sales
  from superstore_stage
  group by orderid
)
select round(avg(total_sales)::numeric,2) as aov from cte;
```

| average_order_value |
|---|
| 458.56 |

**Insight:** AOV was calculated at the order level (not row level) to correctly account for multi-product orders. $458.56 is relatively low, suggesting cross-sell and upsell opportunity — particularly toward higher-margin categories.

---

## 2. Revenue Analysis

### Q3–Q4. Sales by Category & % Contribution

```sql
select category, sum(sales) as total_sales,
       round((sum(sales)*100.0/sum(sum(sales)) over())::numeric,2) as sales_contribution
from superstore_stage
group by category;
```

| category | total_sales | sales_contribution |
|---|---|---|
| Furniture | 741,717.94 | 32.29% |
| Office Supplies | 719,048.30 | 31.30% |
| Technology | 836,155.40 | 36.40% |

**Insight:** Technology leads revenue generation, but the three categories are closely balanced — a diversified revenue base rather than dependence on one segment. This balance made the profitability gap found in Section 3 more significant, not less.

### Q5. Top 10 Products by Revenue

```sql
select productname, sum(profit) as profit, sum(sales) as sales,
       round((sum(profit)*100.0/sum(sales))::numeric,2) as profit_margin,
       rank() over (order by sum(sales) desc) as sales_rank,
       rank() over (order by sum(profit)*1.0/sum(sales) desc) as margin_rank
from superstore_stage
group by 1
order by sales desc
limit 10;
```

**Insight:** Among the top 10 revenue-generating products, profitability varies sharply. Cisco TelePresence generates $22,638 in sales at a **-8% margin** — high revenue does not guarantee profitability, and revenue growth alone can mask margin leakage.

---

## 3. Profitability Analysis

### Q6. Profit & Profit Margin by Category

```sql
select category, sum(profit) as total_profit,
       round((sum(profit)*100.0/sum(sales))::numeric,2) as profit_margin
from superstore_stage
group by 1;
```

| category | total_profit | profit_margin |
|---|---|---|
| Furniture | 18,463.34 | **2.49%** |
| Office Supplies | 122,490.76 | 17.04% |
| Technology | 145,454.97 | 17.40% |

**Insight:** Furniture contributes nearly as much revenue as Technology and Office Supplies but returns almost none of it as profit — the single clearest inefficiency in the business.

### Q7. Profit Margin by Sub-category

```sql
select subcategory, sum(sales) as total_sales, sum(profit) as total_profit,
       round((sum(profit)*100.0/sum(sales))::numeric,2) as profit_margin
from superstore_stage
group by 1
order by 4 desc;
```

| subcategory | total_sales | total_profit | profit_margin |
|---|---|---|---|
| Labels | 12,486.31 | 5,546.26 | 44.42% |
| Paper | 78,479.21 | 34,053.62 | 43.39% |
| Envelopes | 16,476.40 | 6,964.18 | 42.27% |
| Copiers | 149,528.02 | 55,617.82 | 37.20% |
| Fasteners | 3,024.28 | 949.52 | 31.40% |
| Accessories | 167,380.22 | 41,936.64 | 25.05% |
| Art | 27,118.77 | 6,527.78 | 24.07% |
| Appliances | 107,532.13 | 18,138.00 | 16.87% |
| Binders | 203,412.97 | 30,221.74 | 14.86% |
| Furnishings | 91,705.30 | 13,059.15 | 14.24% |
| Phones | 330,006.72 | 44,515.72 | 13.49% |
| Storage | 223,843.72 | 21,278.82 | 9.51% |
| Chairs | 328,167.75 | 26,602.24 | 8.11% |
| Machines | 189,238.55 | 3,384.76 | 1.79% |
| Supplies | 46,673.54 | -1,189.10 | -2.55% |
| Bookcases | 114,879.99 | -3,472.55 | -3.02% |
| **Tables** | 206,965.58 | **-17,725.48** | **-8.56%** |

**Insight:** High-margin sub-categories (Labels, Paper, Envelopes) contribute relatively little revenue, while high-revenue sub-categories (Tables, Chairs) operate at very low or negative margins. Revenue is concentrated in low-margin products while high-margin products stay underutilized.

### Q8. Top 5 & Bottom 5 Sub-categories by Profit Margin

```sql
with cte as (
  select subcategory, sum(profit) as profit, sum(sales) as sales,
         round((sum(profit)*100.0/sum(sales))::numeric,2) as profit_margin
  from superstore_stage group by 1
)
select 'top 5' as tier, * from (select * from cte order by profit_margin desc limit 5) t
union all
select 'bottom 5' as tier, * from (select * from cte order by profit_margin asc limit 5) b;
```

**Insight:** Top performers by margin (Labels, Paper, Envelopes — 40%+) are low in revenue: a growth opportunity via targeted marketing. Bottom performers (Tables, Bookcases) are loss-making despite high revenue: a pricing/discount emergency. Chairs sit in between — high revenue ($328K) at low margin (~8%), representing the lowest-effort improvement opportunity in the dataset.

---

## 4. Revenue vs. Profitability Comparison

### Q9. Sales Rank vs. Profit Margin Rank

```sql
select productname, sum(profit) as profit, sum(sales) as sales,
       round((sum(profit)*100.0/sum(sales))::numeric,2) as profit_margin,
       dense_rank() over (order by sum(sales) desc) as sales_rank,
       dense_rank() over (order by (sum(profit)*100.0/sum(sales)) desc) as margin_rank,
       abs(dense_rank() over (order by sum(sales) desc)
         - dense_rank() over (order by (sum(profit)*100.0/sum(sales)) desc)) as rank_gap
from superstore_stage
group by 1
order by rank_gap desc;
```

**Insight:** Products with 45%+ margins frequently rank outside the top 500 by sales. The `rank_gap` metric quantifies this mismatch directly — confirming that revenue and profitability leaders are largely different products.

### Q10. Product Classification (Revenue × Margin Quadrants)

```sql
with cte as (
  select productname, sum(profit) as profit, sum(sales) as sales,
         round((sum(profit)*100.0/sum(sales))::numeric,2) as profit_margin
  from superstore_stage group by 1
),
cte2 as (
  select avg(sales) as avgsales, avg(profit_margin) as avgprofitmargin from cte
)
select cte.*,
  case
    when sales>=avgsales and profit_margin>=avgprofitmargin then 'high revenue high margin'
    when sales>=avgsales and profit_margin<avgprofitmargin then 'high revenue low margin'
    when sales<avgsales and profit_margin>=avgprofitmargin then 'low revenue high margin'
    else 'low revenue low margin'
  end as classification
from cte cross join cte2
order by sales desc;
```

**Insight:** Four clear segments emerged. **High Revenue + High Margin** (e.g., Canon imageCLASS 2200) are the strongest performers. **High Revenue + Low Margin** (e.g., Cisco TelePresence) are priority candidates for pricing/discount review. **Low Revenue + High Margin** products are growth opportunities via bundling and promotion. **Low Revenue + Low Margin** products should be reconsidered entirely.

---

## 5. Regional & Segment Analysis

### Q11. Sales & Profit by Region

```sql
select region, sum(sales) as total_sales, sum(profit) as total_profit,
       round((sum(profit)*100.0/sum(sales))::numeric,2) as profit_margin
from superstore_stage
group by 1
order by total_sales desc;
```

| region | total_sales | total_profit | profit_margin |
|---|---|---|---|
| West | 725,458.20 | 108,418.41 | **14.94%** |
| East | 678,499.60 | 91,534.89 | 13.49% |
| Central | 501,240.34 | 39,706.41 | **7.92%** |
| South | 391,721.44 | 46,749.41 | 11.93% |

**Insight:** West leads on every metric. Central generates over $500K in sales but converts it poorly (7.92% margin) — a pricing/cost-structure concern. South has the lowest sales but a healthy margin, making it a volume-growth opportunity rather than a margin problem.

### Q12. Sales & Profit by Segment

```sql
select segment, sum(sales) as total_sales, sum(profit) as total_profit,
       round((sum(profit)*100.0/sum(sales))::numeric,2) as profit_margin
from superstore_stage
group by 1
order by total_sales desc;
```

| segment | total_sales | total_profit | profit_margin |
|---|---|---|---|
| Consumer | 1,161,405.10 | 134,119.36 | 11.55% |
| Corporate | 706,148.20 | 91,979.18 | 13.03% |
| Home Office | 429,371.78 | 60,310.77 | **14.05%** |

**Insight:** Consumer drives the most volume but the lowest margin. Home Office is the most efficient segment per dollar of revenue, despite the smallest volume — a case for targeted volume growth rather than pricing changes.

### Q13. Region + Category Performance

```sql
select region, category, sum(sales) as total_sales, sum(profit) as total_profit,
       round((sum(profit)*100.0/sum(sales))::numeric,2) as profit_margin
from superstore_stage
group by 1, 2
order by 1, 3 desc;
```

**Insight:** Furniture is weak in *every* region, including a negative margin in Central (-1.75%) — confirming this is a category-level issue, not a regional anomaly. Separately, Central Office Supplies underperforms (5.32% margin) despite sales volume similar to Central Technology (19.77% margin) — a region-specific pricing or discounting issue worth investigating on its own.

---

## 6. Time-Based Analysis

### Q14. Monthly Sales Trend

```sql
select extract('month' from orderdate) as month,
       sum(case when extract('year' from orderdate)=2014 then sales end) as y2014,
       sum(case when extract('year' from orderdate)=2015 then sales end) as y2015,
       sum(case when extract('year' from orderdate)=2016 then sales end) as y2016,
       sum(case when extract('year' from orderdate)=2017 then sales end) as y2017
from superstore_stage
group by 1
order by 1;
```

**Insight:** September, November, and December consistently post the strongest sales (November 2017 peaked at ~$118K), while February is consistently the weakest month across all four years. This is actionable for inventory and promotional planning ahead of Q4.

### Q15. Monthly Profit Trend

**Insight:** Q4 is generally the most profitable period, but the *weakest* month varies year to year (July 2014, January 2015, August 2016, April 2017) — profit seasonality is less consistent than sales seasonality, meaning discounting and cost structure move somewhat independently of demand.

### Q16. Month-over-Month Growth

```sql
with cte as (
  select date_trunc('month', orderdate) as month, sum(sales) as total_sales
  from superstore_stage
  group by 1 order by 1
)
select month, total_sales as curr_sales,
       lag(total_sales) over (order by month) as prev_sales,
       round(((total_sales - lag(total_sales) over (order by month)) * 100.0
         / lag(total_sales) over (order by month))::numeric,2) as mom_growth_pct
from cte;
```

**Insight:** Growth is highly volatile — sharp rebounds in March, September, and November, with recurring slowdowns in January–February. Confirms the seasonal pattern is a recurring structural feature, not noise.

---

## 7. Customer Analysis

### Q17. Top 10 Customers by Revenue

```sql
select customerid, customername, sum(sales) as revenue, sum(profit) as profit,
       round((sum(profit)*100.0/sum(sales))::numeric,2) as margin,
       round((sum(sales)*100.0/sum(sum(sales)) over())::numeric,2) as revenue_contribution
from superstore_stage
group by 1,2
order by 3 desc
limit 10;
```

| customer | revenue | profit | margin |
|---|---|---|---|
| Sean Miller | 25,043.05 | -1,980.74 | **-7.91%** |
| Tamara Chand | 19,052.22 | 8,981.32 | 47.14% |
| Raymond Buch | 15,117.34 | 6,976.10 | 46.15% |

**Insight:** The top 10 customers contribute only ~6.7% of total revenue — a diversified, low-dependency customer base. But the single highest-revenue customer, Sean Miller, is actually **loss-making**. Customer value has to be judged by margin, not sales volume alone.

### Q18. Customer Contribution (Pareto Analysis)

```sql
-- towards sales
with cte as (
  select customerid, sum(sales) as total_sales from superstore_stage group by 1
),
ranked as (
  select *, row_number() over(order by total_sales desc, customerid) as num,
         sum(total_sales) over(order by total_sales desc, customerid) as cumulative_sales,
         sum(total_sales) over() as overall_sales
  from cte
)
select min(num) as customers_for_80pct, max(num) as total_customers,
       round((min(num)*100.0/max(num))::numeric,2) as pct_customers
from ranked
where cumulative_sales*100.0/overall_sales >= 80;
```

| customers_for_80pct | total_customers | pct_customers |
|---|---|---|
| 396 | 793 | **49.94%** |

The equivalent query run on profit instead of sales showed **~20% of customers generate 80% of profit.**

**Insight:** Revenue does not follow the traditional 80/20 rule — it takes ~50% of customers to reach 80% of sales, a broad and low-risk revenue base. Profit, however, follows Pareto almost exactly: **20% of customers generate 80% of profit.** These are two different customer groups, which has direct implications for where retention investment should go.

### Q19. Top 25% Revenue Customers with Highest Profit Margins

**Insight:** The top-quartile customers by profit margin also carry above-average revenue, combining volume and profitability — the business's clearest highest-value customer segment, distinct from simply "highest revenue."

### Q20a. Loss-Making Customers

```sql
select customerid, customername, sum(sales) as total_sales, sum(profit) as loss,
       round((sum(profit)*100.0/sum(sales))::numeric,2) as loss_margin
from superstore_stage
group by 1,2
having sum(profit) < 0
order by total_sales desc, loss_margin desc;
```

**Insight:** Multiple high-revenue customers are loss-making (Sean Miller -7.91%, Grant Thornton -43.94%). High sales volume does not guarantee profitability — these accounts warrant individual review of discount history and product mix.

---

## 8. Advanced Business Insights

### Q20b. Impact of Discount Level on Profit

```sql
select discount, count(distinct orderid) as total_orders,
       sum(sales) as total_sales, sum(profit) as total_profit,
       round((sum(profit)*100.0/sum(sales))::numeric,2) as profit_margin
from superstore_stage
group by 1
order by 1;
```

| discount | orders | sales | profit | margin |
|---|---|---|---|---|
| 0% | 2,644 | 1,087,906.80 | 320,987.50 | **29.51%** |
| 10–20% | 2,436 | 792,154.80 | 91,756.38 | 11.58% |
| 30% | 211 | 102,945.28 | -10,357.22 | -10.06% |
| 80% | 250 | 16,963.77 | -30,539.04 | **-180.03%** |

**Insight:** The relationship is strongly negative and non-linear. Orders remain profitable up to ~20% discount; every threshold beyond that accelerates losses, bottoming out at -180% margin at 80% discount. High-discount orders (>30%) generated $259K in revenue but **collectively lost $125K** — a direct, quantifiable case for capping discount authority.

### Discount Impact by Category

**Insight:** All categories decline with discount, but at different rates. Technology tolerates discounts best (loss-making only past ~30%). Furniture — already the weakest-margin category — turns loss-making at just **20% discount**, confirming discount policy should be category-specific rather than uniform.

### Q20c. Quantity vs. Sales, Profit, and Margin

```sql
select subcategory, sum(quantity) as units_sold, sum(sales) as revenue,
       sum(profit) as total_profit,
       round((sum(profit)*100.0/sum(sales))::numeric,2) as profit_margin,
       round((sum(profit)/sum(quantity))::numeric,2) as profit_per_unit
from superstore_stage
group by 1
order by 2 desc;
```

| subcategory | units sold | revenue | profit | margin | profit/unit |
|---|---|---|---|---|---|
| Binders | 5,974 | 203,412.97 | 30,221.74 | 14.86% | $5.06 |
| Copiers | 234 | 149,528.02 | 55,617.82 | 37.20% | **$237.68** |
| Tables | 1,241 | 206,965.58 | -17,725.48 | -8.56% | **-$14.28** |

**Insight:** Sales volume is not a reliable proxy for profitability. Binders sell the most units but return a mediocre margin; Copiers sell relatively few units but generate the highest profit per unit in the dataset ($237.68). Tables generate meaningful revenue but *lose* money per unit sold — meaning more sales volume actively makes the problem worse, not better.

### High-Quantity, Loss-Making Products

```sql
select productname, sum(quantity) as product_quantity, sum(sales) as revenue,
       sum(profit) as total_profit,
       round((sum(profit)*100.0/sum(sales))::numeric,2) as profit_margin
from superstore_stage
group by 1
having sum(profit) < 0
  and sum(quantity) >= (
    select avg(totalpd) from (
      select sum(quantity) as totalpd from superstore_stage group by productname
    ) q
  )
order by 2 desc;
```

**Insight:** Several products sell at above-average volume while losing money — these matter more than low-volume loss-makers because losses scale directly with sales volume. Even modest margin improvements here produce a meaningful profit lift given the volume involved.

---

## Final Business Recommendations

See [`business-recommendations.md`](./business-recommendations.md) for the full prioritized recommendations with expected impact.

**Summary:**
1. Cap discounts at 20% — recovers most of the $125K currently lost to over-discounted orders
2. Launch a Furniture profitability program targeting Tables and Bookcases specifically
3. Protect and grow the 20% of customers generating 80% of profit
4. Increase visibility of high-margin, underleveraged products (Labels, Paper, Copiers)
5. Investigate high-revenue, loss-making products and customers individually
