-- Grain: one row per order line item.
CREATE OR REPLACE TABLE {catalog}.{gold_schema}.fact_sales AS
SELECT
  oi.order_id,
  oi.product_id,
  o.customer_id,
  o.order_date,
  o.order_status,
  o.sales_channel,
  o.payment_method,
  o.delivery_status,
  o.return_status,
  o.return_reason,
  oi.quantity,
  oi.unit_price,
  oi.discount_percentage,
  oi.discount_amount,
  oi.gross_sales,
  oi.tax_amount,
  oi.shipping_cost,
  oi.net_sales,
  oi.product_cost,
  oi.profit
FROM {catalog}.{silver_schema}.order_items_cleaned oi
INNER JOIN {catalog}.{silver_schema}.orders_cleaned o
  ON oi.order_id = o.order_id;
