"""Fully-qualified table name constants, shared by every script and SQL template so a
table is named in exactly one place instead of being hardcoded per file.
"""
from src.common.config import BRONZE_SCHEMA, GOLD_SCHEMA, SILVER_SCHEMA, table

# Bronze: raw, untyped ingest of the source CSVs
RAW_CUSTOMERS = table(BRONZE_SCHEMA, "raw_customers")
RAW_PRODUCTS = table(BRONZE_SCHEMA, "raw_products")
RAW_ORDERS = table(BRONZE_SCHEMA, "raw_orders")
RAW_ORDER_ITEMS = table(BRONZE_SCHEMA, "raw_order_items")

# Silver: deduplicated, type-cast, soft-deleted
CUSTOMERS_CLEANED = table(SILVER_SCHEMA, "customers_cleaned")
PRODUCTS_CLEANED = table(SILVER_SCHEMA, "products_cleaned")
ORDERS_CLEANED = table(SILVER_SCHEMA, "orders_cleaned")
ORDER_ITEMS_CLEANED = table(SILVER_SCHEMA, "order_items_cleaned")

# Gold: star schema
DIM_CUSTOMER = table(GOLD_SCHEMA, "dim_customer")
DIM_PRODUCT = table(GOLD_SCHEMA, "dim_product")
FACT_SALES = table(GOLD_SCHEMA, "fact_sales")

# Gold: datamarts
DM_SALES_SUMMARY_DAILY = table(GOLD_SCHEMA, "dm_sales_summary_daily")
DM_PRODUCT_PERFORMANCE = table(GOLD_SCHEMA, "dm_product_performance")
DM_CUSTOMER_RFM = table(GOLD_SCHEMA, "dm_customer_rfm")
DM_SALES_BY_REGION = table(GOLD_SCHEMA, "dm_sales_by_region")
DM_RETURN_ANALYSIS = table(GOLD_SCHEMA, "dm_return_analysis")
DM_MARKETING_CHANNEL_PERFORMANCE = table(GOLD_SCHEMA, "dm_marketing_channel_performance")

# Keyed by bare table name, so .sql templates can write e.g. {raw_customers} instead of
# hardcoding {catalog}.{bronze_schema}.raw_customers. Consumed by src/common/sql_runner.py.
SQL_PLACEHOLDERS = {
    "raw_customers": RAW_CUSTOMERS,
    "raw_products": RAW_PRODUCTS,
    "raw_orders": RAW_ORDERS,
    "raw_order_items": RAW_ORDER_ITEMS,
    "customers_cleaned": CUSTOMERS_CLEANED,
    "products_cleaned": PRODUCTS_CLEANED,
    "orders_cleaned": ORDERS_CLEANED,
    "order_items_cleaned": ORDER_ITEMS_CLEANED,
    "dim_customer": DIM_CUSTOMER,
    "dim_product": DIM_PRODUCT,
    "fact_sales": FACT_SALES,
    "dm_sales_summary_daily": DM_SALES_SUMMARY_DAILY,
    "dm_product_performance": DM_PRODUCT_PERFORMANCE,
    "dm_customer_rfm": DM_CUSTOMER_RFM,
    "dm_sales_by_region": DM_SALES_BY_REGION,
    "dm_return_analysis": DM_RETURN_ANALYSIS,
    "dm_marketing_channel_performance": DM_MARKETING_CHANNEL_PERFORMANCE,
}
