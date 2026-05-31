-- Q1: Monthly revenue trend
SELECT d.year, d.month_name, SUM(f.total_amount) AS revenue
FROM fact_sales f JOIN dim_date d ON f.date_key = d.date_key
GROUP BY d.year, d.month_name, d.month ORDER BY d.month;

-- Q2: Top 10 product categories by revenue
SELECT p.category, p.sub_category, SUM(f.total_amount) AS revenue
FROM fact_sales f JOIN dim_product p ON f.product_key = p.product_key
GROUP BY p.category, p.sub_category ORDER BY revenue DESC;

-- Q3: Revenue per loyalty tier
SELECT c.loyalty_tier, COUNT(DISTINCT f.transaction_id) AS txns,
       SUM(f.total_amount) AS revenue, AVG(f.total_amount) AS avg_spend
FROM fact_sales f JOIN dim_customer c ON f.customer_key = c.customer_key
GROUP BY c.loyalty_tier ORDER BY revenue DESC;