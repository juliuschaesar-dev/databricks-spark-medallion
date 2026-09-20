CREATE OR REPLACE TABLE {dm_sales_by_region} AS
SELECT
  c.region,
  c.customer_country,
  c.customer_state,
  COUNT(DISTINCT f.order_id) AS total_orders,
  SUM(f.quantity)            AS total_units_sold,
  SUM(f.net_sales)           AS total_net_sales,
  SUM(f.profit)              AS total_profit
FROM {fact_sales} f
INNER JOIN {dim_customer} c
  ON f.customer_id = c.customer_id
GROUP BY c.region, c.customer_country, c.customer_state;

COMMENT ON TABLE {dm_sales_by_region} IS 'Geographic sales performance. Grain: 1 row / region+country+state.';
