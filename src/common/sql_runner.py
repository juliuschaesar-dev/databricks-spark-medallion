"""Executes a .sql file against Spark, substituting {catalog}/{bronze_schema}/etc. placeholders."""
from pathlib import Path

from pyspark.sql import SparkSession

from src.common.config import BRONZE_SCHEMA, CATALOG, GOLD_SCHEMA, SILVER_SCHEMA
from src.common.spark_session import get_spark


def run_sql_file(spark: SparkSession, path: Path) -> None:
    sql_text = path.read_text().format(
        catalog=CATALOG,
        bronze_schema=BRONZE_SCHEMA,
        silver_schema=SILVER_SCHEMA,
        gold_schema=GOLD_SCHEMA,
    )
    for statement in filter(None, (s.strip() for s in sql_text.split(";"))):
        spark.sql(statement)


def run_sql_dir(spark: SparkSession, directory: Path) -> None:
    """Runs every .sql file in `directory`, in filename (lexical) order."""
    for sql_file in sorted(directory.glob("*.sql")):
        run_sql_file(spark, sql_file)


def run_layer(sql_dir: Path) -> None:
    """Gets a Spark session and runs every .sql file in `sql_dir`, in order."""
    run_sql_dir(get_spark(), sql_dir)
