# Databricks notebook source
# MAGIC %md
# MAGIC # Gold: star schema + datamarts
# MAGIC Used as the `gold` task of the `medallion_pipeline` Databricks Job (see `databricks.yml`),
# MAGIC which runs after the `silver` task succeeds.

# COMMAND ----------

import sys

sys.path.append("..")

# COMMAND ----------

from src.gold import run_gold

run_gold.run()
