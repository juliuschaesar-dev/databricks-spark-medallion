CREATE OR REPLACE TABLE {dm_product_performance} AS
SELECT
  p.product_id,
  p.product_name,
  p.product_category,
  p.brand,
  COUNT(DISTINCT f.order_id)      AS total_orders,
  SUM(f.quantity)                 AS total_units_sold,
  SUM(f.net_sales)                AS total_net_sales,
  SUM(f.profit)                   AS total_profit,
  ROUND(AVG(p.product_rating), 2) AS avg_rating
FROM {fact_sales} f
INNER JOIN {dim_product} p
  ON f.product_id = p.product_id
GROUP BY p.product_id, p.product_name, p.product_category, p.brand;

COMMENT ON TABLE {dm_product_performance} IS 'Sales & profit by product. Grain: 1 row / product.';
