CREATE OR REPLACE TABLE {dm_return_analysis} AS
SELECT
  return_status,
  return_reason,
  COUNT(DISTINCT order_id) AS total_orders,
  SUM(net_sales)           AS total_net_sales,
  SUM(profit)              AS total_profit
FROM {fact_sales}
GROUP BY return_status, return_reason;

COMMENT ON TABLE {dm_return_analysis} IS 'Return/cancellation breakdown. Grain: 1 row / return_status+reason.';
