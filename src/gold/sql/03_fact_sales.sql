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
  o.marketing_channel,
  o.campaign_name,
  o.customer_rating,
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
  ON oi.order_id = o.order_id
WHERE oi._is_deleted = FALSE
  AND o._is_deleted = FALSE;

COMMENT ON TABLE {catalog}.{gold_schema}.fact_sales IS 'Core sales fact. Grain: 1 row / order line item.';

ALTER TABLE {catalog}.{gold_schema}.fact_sales ALTER COLUMN order_id SET NOT NULL;
ALTER TABLE {catalog}.{gold_schema}.fact_sales ALTER COLUMN customer_id SET NOT NULL;
ALTER TABLE {catalog}.{gold_schema}.fact_sales ALTER COLUMN product_id SET NOT NULL;
ALTER TABLE {catalog}.{gold_schema}.fact_sales
  ADD CONSTRAINT fk_fact_sales_customer FOREIGN KEY (customer_id) REFERENCES {catalog}.{gold_schema}.dim_customer;
ALTER TABLE {catalog}.{gold_schema}.fact_sales
  ADD CONSTRAINT fk_fact_sales_product FOREIGN KEY (product_id) REFERENCES {catalog}.{gold_schema}.dim_product;
