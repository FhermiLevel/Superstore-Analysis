# SuperStore Sales Analytics & Business Intelligence Project

## Project Overview

This project presents an end-to-end Business Intelligence and Data Analytics workflow performed on the SuperStore dataset using **Python, MySQL, and Power BI**.

The objective of the project was to transform raw transactional retail data into actionable business insights through:

* Data Cleaning
* Data Transformation
* Feature Engineering
* Exploratory Data Analysis (EDA)
* SQL Analytics
* KPI Development
* Interactive Dashboard Visualization

The final deliverable was an executive-style interactive Power BI dashboard designed to analyze:

* Sales Performance
* Profitability Trends
* Customer Behavior
* Shipping Efficiency
* Regional Performance
* Product Performance

---

# Tools & Technologies Used

| Tool      | Purpose                       |
| --------- | ----------------------------- |
| Python    | Data Cleaning & Preprocessing |
| Pandas    | Data Manipulation             |
| NumPy     | Numerical Operations          |
| MySQL     | Data Querying & Analysis      |
| Power BI  | Dashboard Development         |
| DAX       | KPI & Calculated Measures     |
| Excel/CSV | Source Dataset                |

---

# Project Workflow

The project followed a complete data analytics lifecycle:

```text
Data Collection
       ↓
Data Cleaning (Python)
       ↓
Data Validation & Transformation
       ↓
Feature Engineering
       ↓
SQL Analysis (MySQL)
       ↓
Data Modeling
       ↓
Power BI Dashboard Development
       ↓
Business Insight Generation
```

---

# Data Cleaning & Preprocessing (Python)

The raw dataset initially contained:

* Duplicate records
* Missing values
* Invalid shipment durations
* Data entry inconsistencies

## Cleaning Activities Performed

###  Duplicate Removal

Duplicate rows were identified and removed using Python and SQL techniques.

###  Missing Value Handling

Null values were inspected and handled appropriately based on business logic.

###  Invalid Shipment Duration Correction

Rows with negative shipment durations were identified and removed.

Example:

```python
df['Ship_Duration'] = (df['Ship_Date'] - df['Order_Date']).dt.days

df = df[df['Ship_Duration'] >= 0]
```

###  Data Entry Error Corrections

Incorrect entries and formatting inconsistencies were corrected during preprocessing.

###  Dataset Reduction

After cleaning:

* Initial Rows: **9,996**
* Final Rows: **8,213**

This improved overall data quality and analytical reliability.

---

#   Feature Engineering

Several new analytical features were created to improve business insights and dashboard interactivity.

## Engineered Features

| Feature          | Purpose                          |
| ---------------- | -------------------------------- |
| Weekday          | Analyze sales trends by weekdays |
| Month            | Monthly trend analysis           |
| Quarter          | Quarterly business performance   |
| Year             | Year-over-year analysis          |
| Days_to_Ship     | Shipping efficiency analysis     |
| Profit_Margin(%) | Profitability analysis           |

Example:

```python
df['Month'] = df['Order_Date'].dt.month_name()
df['Quarter'] = df['Order_Date'].dt.quarter
df['Weekday'] = df['Order_Date'].dt.day_name()

df['Profit_Margin'] = (df['Profit'] / df['Sales']) * 100
```

---

# SQL Data Analysis (MySQL)

SQL was used extensively for:

* Business analysis
* KPI generation
* Trend analysis
* Customer analytics
* Revenue analysis

---

# Database Validation Queries

## Number of Columns

```sql
SELECT COUNT(*) AS numb_of_columns
FROM information_schema.columns
WHERE TABLE_NAME = 'superstore'
AND table_schema = 'superstore';
```

## Number of Rows

```sql
SELECT COUNT(*) AS Num_of_rows
FROM superstore;
```

---

#  Duplicate Removal Using SQL

```sql
WITH dup AS (
SELECT Row_ID,
       ROW_NUMBER() OVER (
       PARTITION BY Order_ID, Order_Date, Ship_Date,
       Ship_Mode, Customer_ID, Customer_Name,
       Segment, Country, City, State,
       Postal_Code, Region, Product_ID,
       Category, Sub_Category, Sales,
       Quantity, Discount, Profit
       ORDER BY Row_ID) AS rn
FROM superstore
)

DELETE FROM superstore
WHERE ROW_ID IN (
SELECT ROW_ID
FROM dup
WHERE rn >= 2
);
```

---

# 📈 Key Business Analysis Queries

---

##  Total Revenue

```sql
SELECT ROUND(SUM(Sales),0) AS Total_Revenue
FROM superstore;
```

### Insight:

Generated total business revenue across all transactions.

---

##  Revenue Growth Over Time

### Monthly Revenue Growth

```sql
SELECT DISTINCT MONTH(order_date) AS Months,
ROUND(SUM(Sales),0) AS sales_amount,

LAG(ROUND(SUM(Sales),0))
OVER (ORDER BY MONTH(order_date)) AS previous_months,

ROUND(
(
SUM(Sales) -
LAG(ROUND(SUM(Sales),0))
OVER (ORDER BY MONTH(order_date))
)
/
LAG(ROUND(SUM(Sales),0))
OVER (ORDER BY MONTH(order_date))
* 100,0
) AS mom_percent

FROM superstore
GROUP BY months
ORDER BY months;
```

### Insight:

Analyzed Month-over-Month sales growth trends.

---

##  Average Revenue Per Order

```sql
SELECT ROUND(AVG(Sales),2) AS avg_order_value
FROM superstore;
```

### Insight:

Measured average customer spending per order.

---

##  Top Performing Products

```sql
SELECT Product_ID,
ROUND(SUM(Sales),2) AS Sales_per_product,
Category,
Sub_Category

FROM superstore
GROUP BY 1,3,4
ORDER BY 2 DESC
LIMIT 10;
```

### Insight:

Identified highest revenue-generating products.

---

## Sales by Product Category

```sql
SELECT Category,
ROUND(SUM(Sales),0) AS Sales_per_category
FROM superstore
GROUP BY 1
ORDER BY 2 DESC;
```

### Insight:

Compared category-level business performance.

---

## Customer Acquisition Analysis

```sql
SELECT YEAR(order_date) AS Years,
COUNT(DISTINCT Customer_Name) AS N_customers
FROM superstore
GROUP BY 1;
```

### Insight:

Tracked customer acquisition trends over time.

---

## Customer Retention Rate

```sql
SELECT
COUNT(DISTINCT o1.Customer_ID) /
(
SELECT COUNT(DISTINCT Customer_ID)
FROM superstore
) * 100 AS customer_retention_rate

FROM superstore o1

WHERE o1.Customer_ID IN (
SELECT o2.Customer_ID
FROM superstore o2
GROUP BY o2.Customer_ID
HAVING COUNT(o2.Order_ID) > 1
);
```

### Insight:

Measured percentage of repeat customers.

---

## Shipping Performance Analysis

```sql
SELECT Ship_Mode,
ROUND(AVG(DATEDIFF(Ship_Date, Order_Date)),0) AS avg_days

FROM superstore
GROUP BY Ship_Mode
ORDER BY avg_days;
```

### Insight:

Evaluated shipping efficiency across shipment modes.

---

# Power BI Dashboard Development

Interactive dashboards were developed in Power BI to support executive-level business reporting.

## Dashboard Features

### KPI Cards

* Total Sales
* Total Profit
* Profit Margin (%)
* Total Orders
* Total Customers
* Average Shipping Days

### Interactive Filters

* Month
* Year
* Region
* Segment

### Visualizations Included

* Sales by Category & Sub-category
* Profit Margin by Category
* Regional Sales Performance Map
* Monthly Profit Trends
* Sales by Segment
* Top Customers
* Top Products
* Shipping Mode Analysis

---

# 📌 Key Business Insights

## Revenue & Profitability

* Total Sales exceeded **$1.93M**
* Total Profit exceeded **$506K**
* Overall Profit Margin reached **26.23%**

---

## Shipping Analysis

* Standard Class shipping had the highest delivery duration.
* Faster shipping modes improved customer fulfillment performance.

---

## Product & Category Insights

* Technology products generated significant sales contribution.
* Office Supplies showed strong profit margins.

---

## Regional Analysis

* Certain regions consistently outperformed others in profitability.
* Geographic trends revealed high-performing business zones.

---

## Customer Insights

* Repeat customer behavior significantly contributed to revenue generation.
* Top customers generated substantial portions of total sales.

---

# Business Value of the Project

This project demonstrates practical expertise in:

* Data Cleaning
* SQL Analytics
* Data Modeling
* KPI Development
* Business Intelligence
* Feature Engineering
* Dashboard Storytelling
* Exploratory Data Analysis
* Executive Reporting

The project simulates a real-world analytics workflow used by modern data analysts and BI professionals to support strategic business decision-making.

---

# Skills Demonstrated

## Technical Skills

* Python
* Pandas
* MySQL
* Power BI
* DAX
* SQL Window Functions
* Data Visualization

## Analytical Skills

* Data Cleaning
* Data Transformation
* Business Analysis
* KPI Reporting
* Trend Analysis
* Customer Analytics
* Sales Analytics

---

# Conclusion

This project successfully transformed raw retail transaction data into a business intelligence solution capable of supporting operational and strategic decision-making.

By integrating Python, MySQL, and Power BI into a unified analytics workflow, the project demonstrates the importance of combining:

* Data Engineering
* Data Analytics
* Visualization
* Storytelling

to generate actionable business insights.

---

# 📧 Contact

For collaborations, analytics opportunities, or feedback:

**LinkedIn:** [www.linkedin.com/in/olalekan-oluwadare-628356237]
**Email:** [olalekanoluwadare20@gmail.com]

---
