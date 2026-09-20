from dataclasses import dataclass

from databricks.sdk import WorkspaceClient
from pyspark.sql import DataFrame, SparkSession
from pyspark.sql import functions as F
from pyspark.sql.types import StringType, StructField, StructType

from src.common.config import SOURCE_VOLUME_PATH
from src.common.constants import RAW_CUSTOMERS, RAW_ORDER_ITEMS, RAW_ORDERS, RAW_PRODUCTS
from src.common.spark_session import get_spark


def _string_schema(*column_names: str) -> StructType:
    """All-STRING schema: bronze stays schema-as-is/untyped, silver does the CAST-ing."""
    return StructType([StructField(name, StringType(), True) for name in column_names])


@dataclass(frozen=True)
class BronzeFeed:
    source_file: str
    target_table: str
    schema: StructType


CUSTOMER_SCHEMA = _string_schema(
    "customer_id", "customer_name", "customer_age", "gender", "customer_segment",
    "customer_city", "customer_state", "customer_country", "region",
    "customer_postal_code", "customer_acquisition_cost",
)

PRODUCT_SCHEMA = _string_schema(
    "product_id", "product_name", "product_category", "product_subcategory",
    "brand", "supplier", "unit_price", "product_cost", "product_rating",
)

ORDER_SCHEMA = _string_schema(
    # customer_type (and the other customer_* fields below) are captured for schema-as-is
    # fidelity but intentionally not promoted past bronze: customer segmentation is owned by
    # customer_master.csv / customers_cleaned, not the orders feed.
    "order_id", "order_date", "order_time", "order_status", "sales_channel",
    "customer_id", "customer_name", "customer_age", "gender", "customer_segment",
    "customer_type", "customer_city", "customer_state", "customer_country", "region",
    "customer_postal_code", "payment_method", "payment_status", "currency",
    "shipping_method", "warehouse", "delivery_days", "estimated_delivery_days",
    "delivery_status", "return_status", "return_reason", "customer_rating",
    "review_sentiment", "customer_review", "marketing_channel", "campaign_name",
    "coupon_code", "loyalty_points_earned", "loyalty_points_redeemed", "quantity",
    "gross_sales", "discount_amount", "tax_amount", "shipping_cost", "net_sales",
    "product_cost", "profit", "profit_margin_percentage", "customer_lifetime_value",
    "is_repeat_customer", "customer_order_count",
)

ORDER_ITEM_SCHEMA = _string_schema(
    "order_id", "product_id", "quantity", "unit_price", "discount_percentage",
    "discount_amount", "gross_sales", "tax_amount", "shipping_cost", "net_sales",
    "product_cost", "profit",
)

FEEDS = [
    BronzeFeed("customer_master.csv", RAW_CUSTOMERS, CUSTOMER_SCHEMA),
    BronzeFeed("product_catalog.csv", RAW_PRODUCTS, PRODUCT_SCHEMA),
    BronzeFeed(
        "ecommerce_sales_customer_analytics_150k.csv",
        RAW_ORDERS,
        ORDER_SCHEMA,
    ),
    BronzeFeed("order_items.csv", RAW_ORDER_ITEMS, ORDER_ITEM_SCHEMA),
]


def _file_metadata(w: WorkspaceClient, remote_path: str) -> tuple[int, str]:
    meta = w.files.get_metadata(remote_path)
    return meta.content_length, meta.last_modified


def _already_ingested(spark: SparkSession, feed: BronzeFeed, size: int, modified: str) -> bool:
    """True if this exact file (by size + last-modified) was already appended."""
    if not spark.catalog.tableExists(feed.target_table):
        return False
    seen = (
        spark.table(feed.target_table)
        .filter(F.col("_source_file") == feed.source_file)
        .agg(
            F.max("_source_file_size").alias("size"),
            F.max("_source_file_modified_at").alias("modified"),
        )
        .collect()[0]
    )
    return seen["size"] == size and seen["modified"] == modified


def _read_csv(spark: SparkSession, path: str, schema: StructType) -> DataFrame:
    return (
        spark.read.option("header", True)
        .option("rescuedDataColumn", "_rescued_data")
        .schema(schema)
        .csv(path)
    )


def _with_audit_columns(df: DataFrame, feed: BronzeFeed, size: int, modified: str) -> DataFrame:
    return (
        df.withColumn("_source_file", F.lit(feed.source_file))
        .withColumn("_source_file_size", F.lit(size))
        .withColumn("_source_file_modified_at", F.lit(modified))
        .withColumn("_ingested_at", F.current_timestamp())
    )


def _warn_on_rescued_rows(df: DataFrame, feed: BronzeFeed) -> None:
    rescued_count = df.filter(F.col("_rescued_data").isNotNull()).count()
    if rescued_count:
        print(
            f"WARNING: {rescued_count} row(s) in {feed.source_file} had unexpected/malformed "
            f"columns, captured in {feed.target_table}._rescued_data instead of dropped silently."
        )


def ingest_feed(spark: SparkSession, w: WorkspaceClient, feed: BronzeFeed) -> None:
    remote_path = f"{SOURCE_VOLUME_PATH}/{feed.source_file}"
    size, modified = _file_metadata(w, remote_path)

    if _already_ingested(spark, feed, size, modified):
        print(f"Skipping {feed.source_file}: unchanged since last ingest")
        return

    df = _with_audit_columns(_read_csv(spark, remote_path, feed.schema), feed, size, modified)
    _warn_on_rescued_rows(df, feed)
    df.write.format("delta").mode("append").saveAsTable(feed.target_table)
    print(f"Ingested {feed.source_file} -> {feed.target_table}")


def run() -> None:
    spark = get_spark()
    w = WorkspaceClient()
    for feed in FEEDS:
        ingest_feed(spark, w, feed)


if __name__ == "__main__":
    run()
