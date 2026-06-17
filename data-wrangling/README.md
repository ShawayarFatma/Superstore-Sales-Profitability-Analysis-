# Data Wrangling

This folder contains the SQL script for comprehensive data cleaning and preparation of the Superstore dataset.

## Overview

The `Data_Wrangling.sql` script performs end-to-end data cleaning to ensure data quality and consistency before analysis. It handles:

- Column standardization
- Duplicate detection and removal
- Data validation
- Product ID consolidation
- Date format conversion
- Data quality checks

## Script Sections

### 1. Column Renaming & Standardization
Converts all column names from mixed case with spaces to camelCase for consistency:
- `Row ID` → `rowid`
- `Order Date` → `orderDate`
- `Order ID` → `orderId`
- And 18 more columns...

### 2. Duplicate Detection & Removal
```sql
with cte as
(
  select *,
  row_number() over (partition by orderid,orderdate,customerid,...) as row_num 
  from superstore_stage
)
select * from cte where row_num>1;
```
Identifies duplicate records based on order, customer, and product details, then removes them.

### 3. Data Validation Checks
Verifies data integrity across all columns:
- **Order IDs**: Ensures they follow US/CA prefix pattern
- **Customer Mapping**: Checks for 1-to-many customer-order relationships
- **Distinct Values**: Validates all categorical columns (segment, region, category, etc.)
- **Product IDs**: Identifies products with multiple IDs or IDs with multiple products

### 4. Data Cleaning Operations
- **Product Name Standardization**: Removes special characters using regex
- **Product ID Consolidation**: Corrects 29+ duplicate product ID issues
- **Trim Operations**: Removes leading/trailing spaces

### 5. Type Conversion
Converts date columns from VARCHAR to DATE format:
```sql
alter table superstore_stage  
alter column orderdate type date
using to_date(nullif(orderdate, ''), 'MM/DD/YYYY');
```

### 6. Final Validation
Performs business logic checks:
- Ensures ship dates are not before order dates
- Validates sales, quantity are positive values
- Checks discount values are non-negative
- Identifies null values in critical columns

## Output

Clean staging table `superstore_stage` with:
- ✅ No duplicates
- ✅ Standardized column names
- ✅ Consistent data types
- ✅ Validated data quality
- ✅ Unique product assignments
- ✅ Correct date formats

## Prerequisites

- PostgreSQL database with Superstore data loaded
- Access to create staging tables and modify columns

## Usage

1. Load the raw Superstore dataset into your database
2. Run this script in PostgreSQL
3. Verify the output by querying `superstore_stage`
4. Use the cleaned data for analysis

## Key Metrics Fixed

- **Duplicates Removed**: 1 record
- **Product IDs Corrected**: 29 instances
- **Date Format Conversions**: 2 columns
- **Column Renames**: 19 columns standardized

## Next Steps

After data wrangling, proceed to:
- `Business_Analysis.sql` - Analytical queries for insights
- Dashboard development
- Business recommendations
