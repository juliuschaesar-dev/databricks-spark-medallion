CREATE OR REPLACE TABLE {catalog}.{gold_schema}.dm_marketing_channel_performance AS
SELECT
  marketing_channel,
  campaign_name,
  COUNT(DISTINCT order_id)       AS total_orders,
  SUM(net_sales)                 AS total_net_sales,
  SUM(profit)                    AS total_profit,
  ROUND(AVG(customer_rating), 2) AS avg_customer_rating
FROM {catalog}.{gold_schema}.fact_sales
GROUP BY marketing_channel, campaign_name;

COMMENT ON TABLE {catalog}.{gold_schema}.dm_marketing_channel_performance IS 'Marketing effectiveness. Grain: 1 row / channel+campaign.';
