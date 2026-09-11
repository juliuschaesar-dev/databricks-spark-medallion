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
FROM {catalog}.{silver_schema}.customers_cleaned
WHERE _is_deleted = FALSE;

COMMENT ON TABLE {catalog}.{gold_schema}.dim_customer IS 'Customer dimension. Grain: 1 row / customer.';

ALTER TABLE {catalog}.{gold_schema}.dim_customer ALTER COLUMN customer_id SET NOT NULL;
ALTER TABLE {catalog}.{gold_schema}.dim_customer ADD CONSTRAINT pk_dim_customer PRIMARY KEY (customer_id);
