from dataclasses import dataclass

from pyspark.sql import DataFrame, SparkSession
from pyspark.sql import functions as F

from src.common.config import BRONZE_SCHEMA, SOURCE_VOLUME_PATH, table
from src.common.spark_session import get_spark


@dataclass(frozen=True)
class BronzeFeed:
    source_file: str
    target_table: str


FEEDS = [
    BronzeFeed("customer_master.csv", table(BRONZE_SCHEMA, "raw_customers")),
    BronzeFeed("product_catalog.csv", table(BRONZE_SCHEMA, "raw_products")),
    BronzeFeed(
        "ecommerce_sales_customer_analytics_150k.csv", table(BRONZE_SCHEMA, "raw_orders")
    ),
    BronzeFeed("order_items.csv", table(BRONZE_SCHEMA, "raw_order_items")),
]


def _read_csv(spark: SparkSession, path: str) -> DataFrame:
    return spark.read.option("header", True).option("inferSchema", True).csv(path)


def _with_audit_columns(df: DataFrame, source_file: str) -> DataFrame:
    return df.withColumn("_source_file", F.lit(source_file)).withColumn(
        "_ingested_at", F.current_timestamp()
    )


def ingest_feed(spark: SparkSession, feed: BronzeFeed) -> None:
    df = _with_audit_columns(
        _read_csv(spark, f"{SOURCE_VOLUME_PATH}/{feed.source_file}"), feed.source_file
    )
    (
        df.write.format("delta")
        .mode("overwrite")
        .option("overwriteSchema", "true")
        .saveAsTable(feed.target_table)
    )


def run() -> None:
    spark = get_spark()
    for feed in FEEDS:
        ingest_feed(spark, feed)


if __name__ == "__main__":
    run()
