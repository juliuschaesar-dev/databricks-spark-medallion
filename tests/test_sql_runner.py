from pathlib import Path

from src.common.sql_runner import run_sql_file


class FakeSpark:
    def __init__(self):
        self.executed = []

    def sql(self, statement: str) -> None:
        self.executed.append(statement)


def test_run_sql_file_substitutes_placeholders_and_splits_statements(tmp_path: Path):
    sql_file = tmp_path / "example.sql"
    sql_file.write_text(
        "CREATE TABLE {catalog}.{silver_schema}.t1 AS SELECT 1;\n"
        "CREATE TABLE {catalog}.{gold_schema}.t2 AS SELECT 2;"
    )

    spark = FakeSpark()
    run_sql_file(spark, sql_file)

    assert len(spark.executed) == 2
    assert "databricks_medallion.silver.t1" in spark.executed[0]
    assert "databricks_medallion.gold.t2" in spark.executed[1]
    assert "{" not in spark.executed[0]


def test_run_sql_file_ignores_semicolons_inside_string_literals(tmp_path: Path):
    sql_file = tmp_path / "example.sql"
    sql_file.write_text(
        "CREATE TABLE {catalog}.{silver_schema}.t1 AS SELECT 'a;b', 'it''s; fine';\n"
        "CREATE TABLE {catalog}.{gold_schema}.t2 AS SELECT 2;"
    )

    spark = FakeSpark()
    run_sql_file(spark, sql_file)

    assert len(spark.executed) == 2
    assert spark.executed[0].endswith("SELECT 'a;b', 'it''s; fine'")
    assert "databricks_medallion.gold.t2" in spark.executed[1]


def test_run_sql_file_ignores_semicolons_inside_line_comments(tmp_path: Path):
    sql_file = tmp_path / "example.sql"
    sql_file.write_text(
        "-- a comment; with a semicolon in it\n"
        "CREATE TABLE {catalog}.{silver_schema}.t1 AS SELECT 1;\n"
        "CREATE TABLE {catalog}.{gold_schema}.t2 AS SELECT 2;"
    )

    spark = FakeSpark()
    run_sql_file(spark, sql_file)

    assert len(spark.executed) == 2
    assert "databricks_medallion.silver.t1" in spark.executed[0]
    assert "databricks_medallion.gold.t2" in spark.executed[1]
