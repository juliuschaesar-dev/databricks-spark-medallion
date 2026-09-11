# Databricks notebook source
# MAGIC %md
# MAGIC # Medallion Pipeline Orchestrator (manual, single-notebook run)
# MAGIC Runs bronze ingestion, then silver cleaning, then gold aggregation, in order, all in one
# MAGIC notebook run/cluster session. Import this file into a Databricks Workspace to run the whole
# MAGIC pipeline by hand.
# MAGIC
# MAGIC For scheduled/production runs, use the `medallion_pipeline` Databricks Job defined in
# MAGIC `databricks.yml` instead — it runs `01_bronze.py` -> `02_silver.py` -> `03_gold.py` as
# MAGIC separate tasks with a dependency graph, so a failure in one stage (e.g. gold) can be
# MAGIC retried on its own from the Jobs UI without re-running bronze/silver.

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
