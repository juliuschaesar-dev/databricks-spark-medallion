from src.common.config import CATALOG, table


def test_table_builds_three_level_name():
    assert table("silver", "orders_cleaned") == f"{CATALOG}.silver.orders_cleaned"
