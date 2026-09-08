-- Run once by a metastore admin to bootstrap the Unity Catalog structure.
CREATE CATALOG IF NOT EXISTS databricks_medallion
  COMMENT 'Medallion architecture pipeline: e-commerce sales analytics';

CREATE SCHEMA IF NOT EXISTS databricks_medallion.bronze
  COMMENT 'Raw ingested data, schema-as-is plus audit columns';

CREATE SCHEMA IF NOT EXISTS databricks_medallion.silver
  COMMENT 'Cleaned, deduplicated, type-cast data';

CREATE SCHEMA IF NOT EXISTS databricks_medallion.gold
  COMMENT 'Business-ready, joined and aggregated data';

-- Volume used to land raw CSV files before bronze ingestion.
CREATE VOLUME IF NOT EXISTS databricks_medallion.bronze.landing
  COMMENT 'Landing zone for raw source CSV files';
