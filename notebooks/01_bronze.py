# Databricks notebook source
# MAGIC %md
# MAGIC # Bronze: CSV -> Delta ingestion
# MAGIC Used as the `bronze` task of the `medallion_pipeline` Databricks Job (see `databricks.yml`).

# COMMAND ----------

import sys

sys.path.append("..")

# COMMAND ----------

from src.bronze import ingest

ingest.run()
