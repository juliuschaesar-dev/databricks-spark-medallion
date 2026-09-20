# Databricks notebook source
# MAGIC %md
# MAGIC # Silver: cleaning / dedup
# MAGIC Used as the `silver` task of the `medallion_pipeline` Databricks Job (see `databricks.yml`),
# MAGIC which runs after the `bronze` task succeeds.

# COMMAND ----------

import sys

sys.path.append("..")

# COMMAND ----------

from src.silver import run_silver

run_silver.run()
