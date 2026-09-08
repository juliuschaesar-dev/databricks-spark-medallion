# Databricks notebook source
# MAGIC %md
# MAGIC # Medallion Pipeline Orchestrator
# MAGIC Runs bronze ingestion, then silver cleaning, then gold aggregation, in order.
# MAGIC Import this file into a Databricks Workspace as a notebook, or attach it directly
# MAGIC as the notebook task of a Databricks Job.

# COMMAND ----------

from src.bronze import ingest as bronze
from src.gold import run_gold as gold
from src.silver import run_silver as silver

# COMMAND ----------

bronze.run()

# COMMAND ----------

silver.run()

# COMMAND ----------

gold.run()
