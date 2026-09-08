from pathlib import Path

from src.common.sql_runner import run_layer

SQL_DIR = Path(__file__).parent / "sql"


def run() -> None:
    run_layer(SQL_DIR)


if __name__ == "__main__":
    run()
