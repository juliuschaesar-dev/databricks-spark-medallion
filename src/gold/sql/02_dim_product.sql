CREATE OR REPLACE TABLE {dim_product} AS
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
FROM {products_cleaned}
WHERE _is_deleted = FALSE;

COMMENT ON TABLE {dim_product} IS 'Product dimension. Grain: 1 row / product.';

ALTER TABLE {dim_product} ALTER COLUMN product_id SET NOT NULL;
ALTER TABLE {dim_product} ADD CONSTRAINT pk_dim_product PRIMARY KEY (product_id);
