CREATE OR REPLACE TABLE {catalog}.{silver_schema}.customers_cleaned AS
SELECT
  customer_id,
  TRIM(customer_name)                       AS customer_name,
  customer_age,
  gender,
  customer_segment,
  TRIM(customer_city)                       AS customer_city,
  customer_state,
  customer_country,
  region,
  customer_postal_code,
  CAST(customer_acquisition_cost AS DOUBLE) AS customer_acquisition_cost,
  current_timestamp()                       AS _cleaned_at
FROM {catalog}.{bronze_schema}.raw_customers
WHERE customer_id IS NOT NULL
QUALIFY ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY _ingested_at DESC) = 1;
