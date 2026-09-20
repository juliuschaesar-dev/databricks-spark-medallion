CREATE TABLE IF NOT EXISTS {customers_cleaned} AS
SELECT
  customer_id,
  TRIM(customer_name)                       AS customer_name,
  CAST(customer_age AS INT)                 AS customer_age,
  gender,
  customer_segment,
  TRIM(customer_city)                       AS customer_city,
  customer_state,
  customer_country,
  region,
  customer_postal_code,
  CAST(customer_acquisition_cost AS DOUBLE) AS customer_acquisition_cost,
  current_timestamp()                       AS _cleaned_at,
  FALSE                                      AS _is_deleted,
  CAST(NULL AS TIMESTAMP)                    AS _deleted_at
FROM {raw_customers}
WHERE 1 = 0;

-- Upsert latest-per-customer from bronze; rows no longer present in bronze are soft-deleted
-- (flagged, not dropped) so silver keeps a full audit trail of what left the source.
MERGE WITH SCHEMA EVOLUTION INTO {customers_cleaned} AS target
USING (
  SELECT
    customer_id,
    TRIM(customer_name)                       AS customer_name,
    CAST(customer_age AS INT)                 AS customer_age,
    gender,
    customer_segment,
    TRIM(customer_city)                       AS customer_city,
    customer_state,
    customer_country,
    region,
    customer_postal_code,
    CAST(customer_acquisition_cost AS DOUBLE) AS customer_acquisition_cost,
    current_timestamp()                       AS _cleaned_at,
    FALSE                                      AS _is_deleted,
    CAST(NULL AS TIMESTAMP)                    AS _deleted_at
  FROM {raw_customers}
  WHERE customer_id IS NOT NULL
  QUALIFY ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY _ingested_at DESC) = 1
) AS source
ON target.customer_id = source.customer_id
WHEN MATCHED THEN UPDATE SET *
WHEN NOT MATCHED THEN INSERT *
WHEN NOT MATCHED BY SOURCE AND target._is_deleted = FALSE THEN
  UPDATE SET _is_deleted = TRUE, _deleted_at = current_timestamp();

COMMENT ON TABLE {customers_cleaned} IS 'Deduplicated, type-cast customers; soft-deleted rows kept and flagged via _is_deleted/_deleted_at. Grain: 1 row / customer.';
