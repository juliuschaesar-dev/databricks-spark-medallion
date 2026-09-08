CREATE OR REPLACE TABLE {catalog}.{gold_schema}.dm_return_analysis AS
SELECT
  return_status,
  return_reason,
  COUNT(DISTINCT order_id) AS total_orders,
  SUM(net_sales)           AS total_net_sales,
  SUM(profit)              AS total_profit
FROM {catalog}.{gold_schema}.fact_sales
GROUP BY return_status, return_reason;
