"""Central configuration, sourced from environment variables (.env for local dev)."""
import os

from dotenv import load_dotenv

load_dotenv()


def _env(key: str, default: str | None = None) -> str:
    value = os.environ.get(key, default)
    if value is None:
        raise EnvironmentError(f"Missing required environment variable: {key}")
    return value


CATALOG = _env("UC_CATALOG", "databricks_medallion")
BRONZE_SCHEMA = _env("UC_BRONZE_SCHEMA", "bronze")
SILVER_SCHEMA = _env("UC_SILVER_SCHEMA", "silver")
GOLD_SCHEMA = _env("UC_GOLD_SCHEMA", "gold")
SOURCE_VOLUME_PATH = _env(
    "SOURCE_VOLUME_PATH", f"/Volumes/{CATALOG}/{BRONZE_SCHEMA}/landing"
)


def table(schema: str, name: str) -> str:
    """Fully-qualified three-level Unity Catalog table name."""
    return f"{CATALOG}.{schema}.{name}"
