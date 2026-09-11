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
FROM {catalog}.{silver_schema}.products_cleaned
WHERE _is_deleted = FALSE;

COMMENT ON TABLE {catalog}.{gold_schema}.dim_product IS 'Product dimension. Grain: 1 row / product.';

ALTER TABLE {catalog}.{gold_schema}.dim_product ALTER COLUMN product_id SET NOT NULL;
ALTER TABLE {catalog}.{gold_schema}.dim_product ADD CONSTRAINT pk_dim_product PRIMARY KEY (product_id);
