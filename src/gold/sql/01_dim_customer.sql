CREATE OR REPLACE TABLE {catalog}.{gold_schema}.dim_customer AS
SELECT
  customer_id,
  customer_name,
  customer_age,
  gender,
  customer_segment,
  customer_city,
  customer_state,
  customer_country,
  region,
  customer_postal_code,
  customer_acquisition_cost
FROM {catalog}.{silver_schema}.customers_cleaned;
