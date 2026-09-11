"""Returns a Spark session: the native one when running inside Databricks
(notebook/job), otherwise a Databricks Connect session to the workspace
configured via DATABRICKS_HOST/DATABRICKS_TOKEN in .env."""
import os

from pyspark.sql import SparkSession


def get_spark() -> SparkSession:
    if "DATABRICKS_RUNTIME_VERSION" in os.environ:
        return SparkSession.builder.getOrCreate()

    from databricks.connect import DatabricksSession

    return DatabricksSession.builder.serverless(True).getOrCreate()
