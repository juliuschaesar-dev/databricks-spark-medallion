CREATE TABLE IF NOT EXISTS {catalog}.{silver_schema}.products_cleaned AS
SELECT
  product_id,
  TRIM(product_name)             AS product_name,
  product_category,
  product_subcategory,
  brand,
  supplier,
  CAST(unit_price AS DOUBLE)     AS unit_price,
  CAST(product_cost AS DOUBLE)   AS product_cost,
  CAST(product_rating AS DOUBLE) AS product_rating,
  current_timestamp()            AS _cleaned_at,
  FALSE                           AS _is_deleted,
  CAST(NULL AS TIMESTAMP)         AS _deleted_at
FROM {catalog}.{bronze_schema}.raw_products
WHERE 1 = 0;

-- Upsert latest-per-product from bronze; rows no longer present in bronze are soft-deleted
-- (flagged, not dropped) so silver keeps a full audit trail of what left the source.
MERGE WITH SCHEMA EVOLUTION INTO {catalog}.{silver_schema}.products_cleaned AS target
USING (
  SELECT
    product_id,
    TRIM(product_name)             AS product_name,
    product_category,
    product_subcategory,
    brand,
    supplier,
    CAST(unit_price AS DOUBLE)     AS unit_price,
    CAST(product_cost AS DOUBLE)   AS product_cost,
    CAST(product_rating AS DOUBLE) AS product_rating,
    current_timestamp()            AS _cleaned_at,
    FALSE                           AS _is_deleted,
    CAST(NULL AS TIMESTAMP)         AS _deleted_at
  FROM {catalog}.{bronze_schema}.raw_products
  WHERE product_id IS NOT NULL
  QUALIFY ROW_NUMBER() OVER (PARTITION BY product_id ORDER BY _ingested_at DESC) = 1
) AS source
ON target.product_id = source.product_id
WHEN MATCHED THEN UPDATE SET *
WHEN NOT MATCHED THEN INSERT *
WHEN NOT MATCHED BY SOURCE AND target._is_deleted = FALSE THEN
  UPDATE SET _is_deleted = TRUE, _deleted_at = current_timestamp();

COMMENT ON TABLE {catalog}.{silver_schema}.products_cleaned IS 'Deduplicated, type-cast products; soft-deleted rows kept and flagged via _is_deleted/_deleted_at. Grain: 1 row / product.';
