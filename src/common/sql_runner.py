"""Executes a .sql file against Spark, substituting {catalog}/{bronze_schema}/etc. placeholders."""
from pathlib import Path

from pyspark.sql import SparkSession

from src.common.constants import SQL_PLACEHOLDERS
from src.common.spark_session import get_spark


def _split_statements(sql_text: str) -> list[str]:
    """Splits on ';', ignoring one inside a single-quoted string (with '' escaping) or a
    '--' line comment."""
    statements = []
    current = []
    in_string = False
    in_comment = False
    i = 0
    while i < len(sql_text):
        char = sql_text[i]
        if in_comment:
            current.append(char)
            if char == "\n":
                in_comment = False
        elif char == "'":
            if in_string and sql_text[i : i + 2] == "''":
                current.append("''")
                i += 2
                continue
            in_string = not in_string
            current.append(char)
        elif not in_string and sql_text[i : i + 2] == "--":
            in_comment = True
            current.append(char)
        elif char == ";" and not in_string:
            statements.append("".join(current))
            current = []
        else:
            current.append(char)
        i += 1
    statements.append("".join(current))
    return [s.strip() for s in statements if s.strip()]


def run_sql_file(spark: SparkSession, path: Path) -> None:
    sql_text = path.read_text().format(**SQL_PLACEHOLDERS)
    for statement in _split_statements(sql_text):
        spark.sql(statement)


def run_sql_dir(spark: SparkSession, directory: Path) -> None:
    """Runs every .sql file in `directory`, in filename (lexical) order."""
    for sql_file in sorted(directory.glob("*.sql")):
        run_sql_file(spark, sql_file)


def run_layer(sql_dir: Path) -> None:
    """Gets a Spark session and runs every .sql file in `sql_dir`, in order."""
    run_sql_dir(get_spark(), sql_dir)


def run_layer_module(module_file: str) -> None:
    """Convenience for a `run_X.py` layer module (e.g. src/silver/run_silver.py): runs every
    .sql file in the `sql/` directory next to it. Pass the module's own `__file__`."""
    run_layer(Path(module_file).parent / "sql")
