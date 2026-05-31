-- Load dim_date
INSERT INTO dim_date
SELECT
    CONVERT(INT, FORMAT(dt, 'yyyyMMdd'))                         AS date_key,
    dt                                                           AS full_date,
    YEAR(dt)                                                     AS year,
    DATEPART(quarter, dt)                                        AS quarter,
    MONTH(dt)                                                    AS month,
    DATENAME(month, dt)                                          AS month_name,
    DATEPART(week, dt)                                           AS week,
    DATEPART(weekday, dt)                                        AS day_of_week,
    CASE WHEN DATEPART(weekday, dt) IN (1,7) THEN 1 ELSE 0 END  AS is_weekend
FROM (
    SELECT DATEADD(day, number, CAST('2023-01-01' AS DATE)) AS dt
    FROM (
        SELECT TOP 365
            ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS number
        FROM sys.objects a
        CROSS JOIN sys.objects b
    ) AS numbers
) AS dates
WHERE dt <= '2023-12-31';


-- Load dim_product
CREATE EXTERNAL DATA SOURCE ds_silver_products
WITH (
    LOCATION = 'https://adlsretailpulse<initials>.dfs.core.windows.net/retaildata/curated/products/'
);

CREATE EXTERNAL FILE FORMAT fmt_parquet
WITH (FORMAT_TYPE = PARQUET);
 
CREATE EXTERNAL TABLE ext_products (
    product_id    INT,
    product_name  NVARCHAR(100),
    category      NVARCHAR(50),
    sub_category  NVARCHAR(50),
    cost_price    FLOAT,
    supplier      NVARCHAR(100),
    price_tier              NVARCHAR(50),
    suggested_retail_price  FLOAT,
    margin_pct              FLOAT
)
WITH (
    DATA_SOURCE  = ds_silver_products,
    LOCATION     = '*.parquet',
    FILE_FORMAT  = fmt_parquet
);
 
 
 
INSERT INTO dim_product (
    product_id,
    product_name,
    category,
    sub_category,
    supplier,
    cost_price
)
SELECT
    product_id,
    product_name,
    category,
    sub_category,
    supplier,
    CAST(cost_price AS DECIMAL(10,2))
FROM ext_products;
 
SELECT COUNT(*) FROM dim_product;
-- Expected: 500
 
SELECT TOP 5 * FROM dim_product ORDER BY product_id;
-- cost_price → numbers like 218.87
-- supplier   → text like 'Supplier_19'

-- Load dim_customer
CREATE EXTERNAL DATA SOURCE ds_silver_customers
WITH (
    LOCATION = 'https://adlsretailpulse<initials>.dfs.core.windows.net/retaildata/curated/customers/'
);

CREATE EXTERNAL TABLE ext_customers (
    customer_id    INT,
    first_name     NVARCHAR(100),
    city           NVARCHAR(50),
    age            INT,
    gender         NVARCHAR(10),
    loyalty_tier   NVARCHAR(20),
    signup_date    DATE,
    age_group      NVARCHAR(20),
    loyalty_score  INT,
    tenure_years   FLOAT,
    signup_year    INT
)
WITH (
    DATA_SOURCE  = ds_silver_customers,
    LOCATION     = '*.parquet',
    FILE_FORMAT  = fmt_parquet
);
 
 
INSERT INTO dim_customer (
    customer_id,
    first_name,
    city,
    age,
    age_group,
    gender,
    loyalty_tier,
    signup_date
)
SELECT
    customer_id,
    first_name,
    city,
    CAST(age AS TINYINT),
    age_group,
    LEFT(gender, 1),          -- CHAR(1) so take only first character M or F
    loyalty_tier,
    signup_date
FROM ext_customers;
 
 
SELECT COUNT(*) FROM dim_customer;
-- Expected: 50,000
 
SELECT TOP 5 * FROM dim_customer ORDER BY customer_id;