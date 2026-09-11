CREATE TABLE IF NOT EXISTS {catalog}.{silver_schema}.order_items_cleaned AS
SELECT
  order_id,
  product_id,
  CAST(quantity AS INT)               AS quantity,
  CAST(unit_price AS DOUBLE)          AS unit_price,
  CAST(discount_percentage AS DOUBLE) AS discount_percentage,
  CAST(discount_amount AS DOUBLE)     AS discount_amount,
  CAST(gross_sales AS DOUBLE)         AS gross_sales,
  CAST(tax_amount AS DOUBLE)          AS tax_amount,
  CAST(shipping_cost AS DOUBLE)       AS shipping_cost,
  CAST(net_sales AS DOUBLE)           AS net_sales,
  CAST(product_cost AS DOUBLE)        AS product_cost,
  CAST(profit AS DOUBLE)              AS profit,
  current_timestamp()                 AS _cleaned_at,
  FALSE                                AS _is_deleted,
  CAST(NULL AS TIMESTAMP)              AS _deleted_at
FROM {catalog}.{bronze_schema}.raw_order_items
WHERE 1 = 0;

-- Upsert latest-per-line-item (order_id + product_id) from bronze; rows no longer present in
-- bronze are soft-deleted (flagged, not dropped) so silver keeps a full audit trail.
MERGE WITH SCHEMA EVOLUTION INTO {catalog}.{silver_schema}.order_items_cleaned AS target
USING (
  SELECT
    order_id,
    product_id,
    CAST(quantity AS INT)               AS quantity,
    CAST(unit_price AS DOUBLE)          AS unit_price,
    CAST(discount_percentage AS DOUBLE) AS discount_percentage,
    CAST(discount_amount AS DOUBLE)     AS discount_amount,
    CAST(gross_sales AS DOUBLE)         AS gross_sales,
    CAST(tax_amount AS DOUBLE)          AS tax_amount,
    CAST(shipping_cost AS DOUBLE)       AS shipping_cost,
    CAST(net_sales AS DOUBLE)           AS net_sales,
    CAST(product_cost AS DOUBLE)        AS product_cost,
    CAST(profit AS DOUBLE)              AS profit,
    current_timestamp()                 AS _cleaned_at,
    FALSE                                AS _is_deleted,
    CAST(NULL AS TIMESTAMP)              AS _deleted_at
  FROM {catalog}.{bronze_schema}.raw_order_items
  WHERE order_id IS NOT NULL
    AND product_id IS NOT NULL
  QUALIFY ROW_NUMBER() OVER (PARTITION BY order_id, product_id ORDER BY _ingested_at DESC) = 1
) AS source
ON target.order_id = source.order_id AND target.product_id = source.product_id
WHEN MATCHED THEN UPDATE SET *
WHEN NOT MATCHED THEN INSERT *
WHEN NOT MATCHED BY SOURCE AND target._is_deleted = FALSE THEN
  UPDATE SET _is_deleted = TRUE, _deleted_at = current_timestamp();

COMMENT ON TABLE {catalog}.{silver_schema}.order_items_cleaned IS 'Deduplicated, type-cast order line items; soft-deleted rows kept and flagged via _is_deleted/_deleted_at. Grain: 1 row / order line item.';
