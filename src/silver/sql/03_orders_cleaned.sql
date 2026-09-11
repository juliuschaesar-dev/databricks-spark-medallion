CREATE TABLE IF NOT EXISTS {catalog}.{silver_schema}.orders_cleaned AS
SELECT
  order_id,
  CAST(order_date AS DATE)                 AS order_date,
  order_time,
  order_status,
  sales_channel,
  customer_id,
  payment_method,
  payment_status,
  currency,
  shipping_method,
  warehouse,
  CAST(delivery_days AS DOUBLE)            AS delivery_days,
  CAST(estimated_delivery_days AS DOUBLE)  AS estimated_delivery_days,
  delivery_status,
  return_status,
  return_reason,
  CAST(customer_rating AS DOUBLE)          AS customer_rating,
  review_sentiment,
  marketing_channel,
  campaign_name,
  coupon_code,
  CAST(loyalty_points_earned AS INT)       AS loyalty_points_earned,
  CAST(loyalty_points_redeemed AS INT)     AS loyalty_points_redeemed,
  CAST(quantity AS INT)                    AS quantity,
  CAST(gross_sales AS DOUBLE)              AS gross_sales,
  CAST(discount_amount AS DOUBLE)          AS discount_amount,
  CAST(tax_amount AS DOUBLE)               AS tax_amount,
  CAST(shipping_cost AS DOUBLE)            AS shipping_cost,
  CAST(net_sales AS DOUBLE)                AS net_sales,
  CAST(product_cost AS DOUBLE)             AS product_cost,
  CAST(profit AS DOUBLE)                   AS profit,
  CAST(profit_margin_percentage AS DOUBLE) AS profit_margin_percentage,
  CAST(customer_lifetime_value AS DOUBLE)  AS customer_lifetime_value,
  CAST(is_repeat_customer AS BOOLEAN)      AS is_repeat_customer,
  CAST(customer_order_count AS INT)        AS customer_order_count,
  current_timestamp()                      AS _cleaned_at,
  FALSE                                     AS _is_deleted,
  CAST(NULL AS TIMESTAMP)                   AS _deleted_at
FROM {catalog}.{bronze_schema}.raw_orders
WHERE 1 = 0;

-- Upsert latest-per-order from bronze; rows no longer present in bronze are soft-deleted
-- (flagged, not dropped) so silver keeps a full audit trail of what left the source.
MERGE WITH SCHEMA EVOLUTION INTO {catalog}.{silver_schema}.orders_cleaned AS target
USING (
  SELECT
    order_id,
    CAST(order_date AS DATE)                 AS order_date,
    order_time,
    order_status,
    sales_channel,
    customer_id,
    payment_method,
    payment_status,
    currency,
    shipping_method,
    warehouse,
    CAST(delivery_days AS DOUBLE)            AS delivery_days,
    CAST(estimated_delivery_days AS DOUBLE)  AS estimated_delivery_days,
    delivery_status,
    return_status,
    return_reason,
    CAST(customer_rating AS DOUBLE)          AS customer_rating,
    review_sentiment,
    marketing_channel,
    campaign_name,
    coupon_code,
    CAST(loyalty_points_earned AS INT)       AS loyalty_points_earned,
    CAST(loyalty_points_redeemed AS INT)     AS loyalty_points_redeemed,
    CAST(quantity AS INT)                    AS quantity,
    CAST(gross_sales AS DOUBLE)              AS gross_sales,
    CAST(discount_amount AS DOUBLE)          AS discount_amount,
    CAST(tax_amount AS DOUBLE)               AS tax_amount,
    CAST(shipping_cost AS DOUBLE)            AS shipping_cost,
    CAST(net_sales AS DOUBLE)                AS net_sales,
    CAST(product_cost AS DOUBLE)             AS product_cost,
    CAST(profit AS DOUBLE)                   AS profit,
    CAST(profit_margin_percentage AS DOUBLE) AS profit_margin_percentage,
    CAST(customer_lifetime_value AS DOUBLE)  AS customer_lifetime_value,
    CAST(is_repeat_customer AS BOOLEAN)      AS is_repeat_customer,
    CAST(customer_order_count AS INT)        AS customer_order_count,
    current_timestamp()                      AS _cleaned_at,
    FALSE                                     AS _is_deleted,
    CAST(NULL AS TIMESTAMP)                   AS _deleted_at
  FROM {catalog}.{bronze_schema}.raw_orders
  WHERE order_id IS NOT NULL
    AND customer_id IS NOT NULL
  QUALIFY ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY _ingested_at DESC) = 1
) AS source
ON target.order_id = source.order_id
WHEN MATCHED THEN UPDATE SET *
WHEN NOT MATCHED THEN INSERT *
WHEN NOT MATCHED BY SOURCE AND target._is_deleted = FALSE THEN
  UPDATE SET _is_deleted = TRUE, _deleted_at = current_timestamp();

COMMENT ON TABLE {catalog}.{silver_schema}.orders_cleaned IS 'Deduplicated, type-cast orders; soft-deleted rows kept and flagged via _is_deleted/_deleted_at. Grain: 1 row / order.';
