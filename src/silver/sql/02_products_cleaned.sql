CREATE OR REPLACE TABLE {catalog}.{silver_schema}.products_cleaned AS
SELECT
  product_id,
  TRIM(product_name)                AS product_name,
  product_category,
  product_subcategory,
  brand,
  supplier,
  CAST(unit_price AS DOUBLE)        AS unit_price,
  CAST(product_cost AS DOUBLE)      AS product_cost,
  CAST(product_rating AS DOUBLE)    AS product_rating,
  current_timestamp()                AS _cleaned_at
FROM (
  SELECT *,
         ROW_NUMBER() OVER (PARTITION BY product_id ORDER BY _ingested_at DESC) AS _rn
  FROM {catalog}.{bronze_schema}.raw_products
  WHERE product_id IS NOT NULL
)
WHERE _rn = 1;
