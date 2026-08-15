# Superstore Sales & Profitability Analysis SQL Script

## Overview
This SQL script provides comprehensive business analysis of superstore sales and profitability data. It includes exploratory data analysis (EDA), performance metrics, customer segmentation, and profitability drivers across multiple dimensions including categories, regions, segments, and customers.

## Purpose
The analysis is designed to answer critical business questions such as:
- What is the overall business performance?
- Which products and categories drive profitability?
- How do discounts impact profit margins?
- Who are the most valuable customers?
- What are regional and segment performance trends?
- How do monthly sales and profit trends evolve over time?

## Table of Contents
1. [Data Overview](#data-overview)
2. [Analysis Sections](#analysis-sections)
3. [Key Metrics](#key-metrics)
4. [Usage](#usage)
5. [Requirements](#requirements)

---

## Data Overview

### Source Table
- **Table Name:** `superstore_stage`
- **Key Columns:** 
  - `orderid`, `orderdate`, `customerid`, `customername`
  - `productname`, `category`, `subcategory`
  - `sales`, `profit`, `discount`, `quantity`
  - `region`, `segment`

---

## Analysis Sections

### 1. **Overall Business Performance**
```sql
-- Query: Overall business performance metrics
```
**Purpose:** Provides high-level KPIs including:
- Total sales and profit
- Total number of orders
- Overall profit margin

---

### 2. **Product-Level Analysis**

#### 2.1 Average Order Value (AOV)
Calculates the mean transaction value across all orders.

#### 2.2 Top 10 Products by Revenue
Ranks products by sales revenue with:
- Profit and sales metrics
- Profit margin for each product
- Sales rank and margin rank
- Identifies products with high revenue vs. high profitability

#### 2.3 Product Classification Matrix
Classifies products into four categories:
- **High Revenue High Margin:** Star products (invest & grow)
- **High Revenue Low Margin:** Problem products (optimize cost)
- **Low Revenue High Margin:** Niche products (consider expansion)
- **Low Revenue Low Margin:** Dogs (consider discontinuing)

---

### 3. **Category & Subcategory Analysis**

#### 3.1 Sales by Category
Shows:
- Total sales per category
- Percentage contribution to overall sales

#### 3.2 Profit by Category
Analyzes:
- Total profit per category
- Profit margin by category

#### 3.3 Profit Margin by Subcategory
Ranks subcategories by:
- Total sales, profit, and margin
- Orders by profitability (top 5 vs. bottom 5)

#### 3.4 Sales Rank vs. Profit Margin Rank Comparison
Identifies anomalies where:
- High-selling products have low margins
- Low-selling products have high margins
- Calculates rank gap to highlight misalignment

---

### 4. **Geographic & Segment Performance**

#### 4.1 Sales and Profit by Region
Analyzes performance across regions (e.g., East, West, South, Central)

#### 4.2 Sales and Profit by Segment
Breaks down performance by customer segments (e.g., Consumer, Corporate, Home Office)

#### 4.3 Region + Category Performance Matrix
Cross-tabular analysis showing how categories perform in each region

---

### 5. **Temporal Analysis**

#### 5.1 Monthly Sales Trend
Year-over-year comparison of monthly sales:
- Tracks sales patterns across 2014-2017
- Identifies seasonal trends and peaks

#### 5.2 Monthly Profit Trend
Year-over-year comparison of monthly profit:
- Reveals profit seasonality
- Highlights unprofitable periods

#### 5.3 Month-over-Month (MoM) Growth
Calculates percentage growth rates between consecutive months

---

### 6. **Customer Analysis**

#### 6.1 Top 10 Customers by Revenue
Shows:
- Customer ID and name
- Revenue and profit contribution
- Profit margin
- Percentage of total revenue (revenue concentration)

#### 6.2 Customer Contribution to Sales (Pareto Analysis)
Identifies:
- Number of customers needed to achieve 80% of sales
- Percentage of customer base required for 80% revenue

#### 6.3 Customer Contribution to Profit (Pareto Analysis)
Determines:
- Which customers drive 80% of profit
- Profit concentration metrics

#### 6.4 Top 25% Customers by Profit Margin
Segments high-margin customers with:
- Minimum revenue threshold (above average)
- Top quartile by margin ranking
- Identifies premium customer profile

#### 6.5 Loss-Making Customers
Identifies unprofitable customers:
- Negative profit transactions
- Loss margin percentage
- Helps target intervention efforts

---

### 7. **Discount Impact Analysis**

#### 7.1 Impact of Discount Level
Analyzes how discount percentage affects:
- Number of orders
- Total sales and profit
- Profit margin erosion

#### 7.2 Discount Buckets
Categorizes discounts into brackets:
- No discount (0%)
- Low discount (<10%)
- Medium discount (10-20%)
- Medium-High discount (20-30%)
- High discount (>30%)

Shows profitability by bucket to identify optimal discount strategy.

#### 7.3 Discount by Category & Subcategory
Breakdown of:
- Discount strategy by product category
- Profit impact at granular levels
- Identifies categories over-discounted

---

### 8. **Quantity & Volume Analysis**

#### 8.1 Quantity by Subcategory
Analyzes volume metrics:
- Total quantity sold
- Revenue per unit
- Profit per unit
- Identifies high-volume, low-margin products

#### 8.2 High Quantity Loss-Making Products
Flags products that:
- Generate losses
- Have above-average sales volume
- Need urgent intervention (pricing, cost reduction, or discontinuation)

---

## Key Metrics

| Metric | Formula | Use Case |
|--------|---------|----------|
| **Profit Margin** | (Profit / Sales) × 100 | Profitability assessment |
| **AOV** | Avg(Total Sales per Order) | Customer value indicator |
| **MoM Growth** | ((Current - Previous) / Previous) × 100 | Trend analysis |
| **Revenue Contribution** | (Category Sales / Total Sales) × 100 | Portfolio concentration |
| **Pareto (80/20)** | Count of customers for 80% revenue | Customer concentration |

---

## Usage

### Prerequisites
- PostgreSQL or compatible SQL database
- `superstore_stage` table populated with sales data
- Appropriate database permissions (SELECT)

### Running the Script
1. Connect to your database
2. Execute queries individually or in sections
3. Each query is independent and can be run separately
4. Results can be exported for visualization (Excel, BI tools, etc.)

### Recommended Tools
- **SQL IDE:** pgAdmin, DBeaver, SQL Workbench
- **Visualization:** Excel, Tableau, Power BI, Looker
- **Reporting:** Create dashboards using results

---

## Key Insights to Look For

### Performance Indicators
- ✅ Products with high sales but low margins (optimization opportunity)
- ✅ Loss-making customers (retention vs. exit decision)
- ✅ Seasonal patterns (inventory planning)
- ✅ High-discount impact on profitability (pricing strategy review)

### Strategic Recommendations
1. **Product Strategy:** Focus on high-margin products; review low-margin stars
2. **Discount Policy:** Evaluate aggressive discounting impact; set discount caps
3. **Customer Management:** Nurture top 20% customers; address unprofitable ones
4. **Inventory:** Align stock with seasonal demand patterns
5. **Regional Focus:** Invest in high-performing regions; debug underperformers

---

## Notes

- All calculations use 2 decimal places for currency and percentages
- Data spans 2014-2017
- Profit margin calculations: `(Profit × 100.0 / Sales)` to avoid integer division
- Window functions used for ranking and cumulative aggregations
- CTEs (Common Table Expressions) improve query readability for complex logic

---

## Author & Maintenance

- **Created by:** ShawayarFatma
- **Project:** Superstore Sales & Profitability Analysis
- **Repository:** [Superstore-Sales-Profitability-Analysis-](https://github.com/ShawayarFatma/Superstore-Sales-Profitability-Analysis-)

---
