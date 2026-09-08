CREATE OR REPLACE TABLE {catalog}.{gold_schema}.dm_sales_summary_daily AS
SELECT
  order_date,
  sales_channel,
  COUNT(DISTINCT order_id)         AS total_orders,
  SUM(quantity)                    AS total_units_sold,
  SUM(gross_sales)                 AS total_gross_sales,
  SUM(discount_amount)             AS total_discount,
  SUM(net_sales)                   AS total_net_sales,
  SUM(profit)                      AS total_profit,
  ROUND(AVG(net_sales), 2)         AS avg_order_line_value
FROM {catalog}.{gold_schema}.fact_sales
GROUP BY order_date, sales_channel;
