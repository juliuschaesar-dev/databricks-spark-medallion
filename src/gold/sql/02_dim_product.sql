CREATE OR REPLACE TABLE {catalog}.{gold_schema}.dim_product AS
SELECT
  product_id,
  product_name,
  product_category,
  product_subcategory,
  brand,
  supplier,
  unit_price,
  product_cost,
  product_rating
FROM {catalog}.{silver_schema}.products_cleaned;
