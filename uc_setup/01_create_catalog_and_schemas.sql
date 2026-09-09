-- Run once by a metastore admin to bootstrap the Unity Catalog structure.
CREATE CATALOG IF NOT EXISTS {catalog}
  COMMENT 'Medallion architecture pipeline: e-commerce sales analytics';

CREATE SCHEMA IF NOT EXISTS {catalog}.{bronze_schema}
  COMMENT 'Raw ingested data, schema-as-is plus audit columns';

CREATE SCHEMA IF NOT EXISTS {catalog}.{silver_schema}
  COMMENT 'Cleaned, deduplicated, type-cast data';

CREATE SCHEMA IF NOT EXISTS {catalog}.{gold_schema}
  COMMENT 'Business-ready, joined and aggregated data';

-- Volume used to land raw CSV files before bronze ingestion.
CREATE VOLUME IF NOT EXISTS {catalog}.{bronze_schema}.landing
  COMMENT 'Landing zone for raw source CSV files';
