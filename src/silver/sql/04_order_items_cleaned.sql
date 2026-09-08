CREATE OR REPLACE TABLE {catalog}.{silver_schema}.order_items_cleaned AS
SELECT
  order_id,
  product_id,
  CAST(quantity AS INT)                    AS quantity,
  CAST(unit_price AS DOUBLE)                AS unit_price,
  CAST(discount_percentage AS DOUBLE)      AS discount_percentage,
  CAST(discount_amount AS DOUBLE)          AS discount_amount,
  CAST(gross_sales AS DOUBLE)              AS gross_sales,
  CAST(tax_amount AS DOUBLE)               AS tax_amount,
  CAST(shipping_cost AS DOUBLE)            AS shipping_cost,
  CAST(net_sales AS DOUBLE)                AS net_sales,
  CAST(product_cost AS DOUBLE)             AS product_cost,
  CAST(profit AS DOUBLE)                   AS profit,
  current_timestamp()                      AS _cleaned_at
FROM {catalog}.{bronze_schema}.raw_order_items
WHERE order_id IS NOT NULL
  AND product_id IS NOT NULL;
