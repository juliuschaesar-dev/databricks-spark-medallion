# Databricks Medallion

Medallion Architecture pipeline (Bronze → Silver → Gold) on Databricks, built with Spark SQL,
Delta Lake, and Unity Catalog. Source data is an e-commerce sales dataset (orders, order items,
customers, products).

## Architecture

<img src="docs/pipeline-architecture.svg" width="100%" alt="Pipeline architecture: CSV source, Bronze, Silver, Gold star schema, Gold datamart, Unity Catalog, CI/Docker">

Unity Catalog layout:

```
databricks_medallion
├── bronze  (raw_orders, raw_order_items, raw_customers, raw_products)
├── silver  (orders_cleaned, order_items_cleaned, customers_cleaned, products_cleaned)
└── gold    (fact_sales, dim_customer, dim_product,
             dm_sales_summary_daily, dm_product_performance,
             dm_customer_rfm, dm_sales_by_region, dm_return_analysis,
             dm_marketing_channel_performance)
```

Gold layer has two kinds of tables:
- **Star schema** (no prefix) — `dim_customer`, `dim_product`, `fact_sales`
- **Datamart** (`dm_` prefix) — aggregated, analytics/BI-ready tables built on top of the star schema

| Table | Grain | Purpose |
|---|---|---|
| `dim_customer` | 1 row / customer | customer dimension |
| `dim_product` | 1 row / product | product dimension |
| `fact_sales` | 1 row / order line item | core sales fact |
| `dm_sales_summary_daily` | 1 row / day / channel | daily sales rollup |
| `dm_product_performance` | 1 row / product | sales & profit by product |
| `dm_customer_rfm` | 1 row / customer | Recency/Frequency/Monetary segmentation |
| `dm_sales_by_region` | 1 row / region+country+state | geographic sales performance |
| `dm_return_analysis` | 1 row / return_status+reason | return/cancellation breakdown |
| `dm_marketing_channel_performance` | 1 row / channel+campaign | marketing effectiveness |

## Repo structure

```
databricks-medallion/
├── notebooks/            Databricks notebook(s) to run/orchestrate the pipeline
├── src/
│   ├── common/           shared config + SQL runner
│   ├── bronze/           CSV → Delta ingestion (Python)
│   ├── silver/           cleaning/dedup transforms (SQL)
│   └── gold/             joins + aggregations (SQL)
├── uc_setup/             one-time catalog/schema/grant bootstrap
├── tests/                pytest unit tests (no cluster required)
├── data_source/          raw source CSVs
└── .github/workflows/    CI (builds the Docker image, runs pytest inside it, on push/PR)
```

## Prerequisites

- A Databricks workspace with Unity Catalog enabled (Free Edition works — serverless SQL
  warehouse + a default Unity Catalog metastore are included).
- A personal access token: workspace **Settings → Developer → Access tokens → Generate new token**.
- A SQL Warehouse HTTP path: **SQL Warehouses → (your warehouse) → Connection details**.

## Setup

1. Copy `.env.example` to `.env` and fill in your workspace values:
   ```
   DATABRICKS_HOST=https://<your-workspace>.cloud.databricks.com
   DATABRICKS_TOKEN=<personal-access-token>
   DATABRICKS_HTTP_PATH=/sql/1.0/warehouses/<warehouse-id>
   ```

2. Install dependencies:
   ```
   pip install -r requirements.txt
   ```

3. Bootstrap Unity Catalog (once, as a metastore admin):
   ```
   python -m uc_setup.run_uc_setup
   ```

4. Upload the CSVs under `data_source/` to the landing Volume
   (`/Volumes/databricks_medallion/bronze/landing` by default — see `SOURCE_VOLUME_PATH` in `.env`).

5. Run the pipeline (bronze → silver → gold), either:
   - locally/CI, calling each stage's `run()`:
     ```
     python -m src.bronze.ingest
     python -m src.silver.run_silver
     python -m src.gold.run_gold
     ```
   - or import [notebooks/00_run_pipeline.py](notebooks/00_run_pipeline.py) into a Databricks
     Workspace and run it (or attach it to a Databricks Job).

## Testing

```
pytest -v
```

Tests are schema/logic checks (SQL placeholder substitution, config, source CSV columns) that
run without a live Spark cluster, so they're safe to run in CI.

## Docker

A [Dockerfile](Dockerfile) is provided for a consistent local dev/test environment (Python +
JVM for pyspark), without needing Java installed on your machine:

```
docker build -t databricks-medallion .
docker run --rm databricks-medallion
```

This runs the test suite (same checks as `pytest -v`) inside the container.

Note: this container is for local development/testing only — it does not connect to your
Databricks workspace. The bronze/silver/gold pipeline itself (`src/bronze/ingest.py`,
`src/silver/run_silver.py`, `src/gold/run_gold.py`) is meant to run on Databricks (as a notebook
or Job), where a Spark session and Unity Catalog are already available.
