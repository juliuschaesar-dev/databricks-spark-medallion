CREATE OR REPLACE TABLE {catalog}.{gold_schema}.dm_marketing_channel_performance AS
SELECT
  o.marketing_channel,
  o.campaign_name,
  COUNT(DISTINCT o.order_id)       AS total_orders,
  SUM(oi.net_sales)                AS total_net_sales,
  SUM(oi.profit)                   AS total_profit,
  ROUND(AVG(o.customer_rating), 2) AS avg_customer_rating
FROM {catalog}.{silver_schema}.orders_cleaned o
INNER JOIN {catalog}.{silver_schema}.order_items_cleaned oi
  ON o.order_id = oi.order_id
GROUP BY o.marketing_channel, o.campaign_name;
