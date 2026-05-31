-- dim_date 
CREATE TABLE dim_date (
    date_key    INT NOT NULL,
    full_date   DATE,
    year        SMALLINT,
    quarter     TINYINT,
    month       TINYINT,
    month_name  NVARCHAR(10),
    week        TINYINT,
    day_of_week TINYINT,
    is_weekend  BIT
) WITH (DISTRIBUTION = REPLICATE, CLUSTERED COLUMNSTORE INDEX);

-- dim_product
CREATE TABLE dim_product (
    product_key  INT IDENTITY(1,1),
    product_id   INT,
    product_name NVARCHAR(100),
    category     NVARCHAR(50),
    sub_category NVARCHAR(50),
    supplier     NVARCHAR(100),
    cost_price   DECIMAL(10,2)
) WITH (DISTRIBUTION = REPLICATE, CLUSTERED COLUMNSTORE INDEX);

-- dim_customer 
CREATE TABLE dim_customer (
    customer_key  INT IDENTITY(1,1),
    customer_id   INT,
    first_name    NVARCHAR(100),
    city          NVARCHAR(50),
    age           TINYINT,
    age_group     NVARCHAR(20),
    gender        CHAR(1),
    loyalty_tier  NVARCHAR(20),
    signup_date   DATE
) WITH (DISTRIBUTION = HASH(customer_id), CLUSTERED COLUMNSTORE INDEX);

-- fact_sales
CREATE TABLE fact_sales (
    sale_key        BIGINT IDENTITY(1,1),
    transaction_id  NVARCHAR(36),
    date_key        INT,
    product_key     INT,
    customer_key    INT,
    store_id        INT,
    region          NVARCHAR(50),
    quantity        INT,
    unit_price      DECIMAL(10,2),
    discount_pct    DECIMAL(5,2),
    total_amount    DECIMAL(12,2),
    payment_method  NVARCHAR(20)
) WITH (DISTRIBUTION = HASH(customer_key), CLUSTERED COLUMNSTORE INDEX);
