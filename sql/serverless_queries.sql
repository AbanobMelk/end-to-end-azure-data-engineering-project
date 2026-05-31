-- Revenue by Region 
SELECT
    region,
    SUM(total_amount)   AS total_revenue,
    COUNT(*)            AS transaction_count,
    AVG(total_amount)   AS avg_basket_size
FROM
    OPENROWSET(
        BULK 'https://adlsretailpulse<initials>.dfs.core.windows.net/retaildata/curated/sales/**',
        FORMAT = 'PARQUET'
    ) AS sales
GROUP BY region
ORDER BY total_revenue DESC;

-- Expected: 5 rows (Cairo, Alexandria, Giza, Luxor, Aswan) with revenue figures



-- Create External Table
CREATE DATABASE retaildb;
USE retaildb;

CREATE EXTERNAL DATA SOURCE ds_silver
WITH (LOCATION = 'https://adlsretailpulse<initials>.dfs.core.windows.net/retaildata/curated/');

CREATE EXTERNAL FILE FORMAT fmt_parquet
WITH (FORMAT_TYPE = PARQUET);

CREATE EXTERNAL TABLE silver_sales
WITH (DATA_SOURCE = ds_silver, LOCATION = 'sales/', FILE_FORMAT = fmt_parquet)
AS SELECT * FROM OPENROWSET(BULK 'sales/**', DATA_SOURCE = 'ds_silver',FORMAT = 'PARQUET') AS t;

SELECT TOP 5 * FROM silver_sales;   -- verify external table works
