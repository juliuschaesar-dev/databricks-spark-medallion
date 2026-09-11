-- RFM (Recency / Frequency / Monetary) segmentation, one row per customer.
CREATE OR REPLACE TABLE {catalog}.{gold_schema}.dm_customer_rfm AS
WITH customer_orders AS (
  SELECT customer_id, order_id, order_date, net_sales
  FROM {catalog}.{gold_schema}.fact_sales
),
agg AS (
  SELECT
    customer_id,
    MAX(order_date)          AS last_order_date,
    COUNT(DISTINCT order_id) AS frequency,
    SUM(net_sales)           AS monetary
  FROM customer_orders
  GROUP BY customer_id
),
dataset_bounds AS (
  SELECT MAX(order_date) AS max_order_date FROM customer_orders
)
SELECT
  a.customer_id,
  a.last_order_date,
  DATEDIFF(b.max_order_date, a.last_order_date) AS recency_days,
  a.frequency,
  a.monetary
FROM agg a
CROSS JOIN dataset_bounds b;

COMMENT ON TABLE {catalog}.{gold_schema}.dm_customer_rfm IS 'Recency/Frequency/Monetary segmentation. Grain: 1 row / customer.';
