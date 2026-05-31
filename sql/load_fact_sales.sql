INSERT INTO fact_sales
SELECT
    s.transaction_id,
    CONVERT(INT, FORMAT(s.transaction_date, 'yyyyMMdd')) AS date_key,
    p.product_key,
    c.customer_key,
    s.store_id,
    s.region,
    s.quantity,
    s.unit_price,
    s.discount_pct,
    s.total_amount,
    s.payment_method
FROM OPENROWSET(BULK '...',FORMAT='PARQUET') AS s   -- silver sales
LEFT JOIN dim_product  p ON s.product_id  = p.product_id
LEFT JOIN dim_customer c ON s.customer_id = c.customer_id;

-- Verify row counts
SELECT 'fact_sales' tbl, COUNT(*) n FROM fact_sales
UNION ALL SELECT 'dim_date', COUNT(*) FROM dim_date
UNION ALL SELECT 'dim_product', COUNT(*) FROM dim_product
UNION ALL SELECT 'dim_customer', COUNT(*) FROM dim_customer;
-- Expected: fact_sales ~500k | dim_date 365 | dim_product 500 | dim_customer 50,000
