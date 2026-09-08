import csv
from pathlib import Path

DATA_DIR = Path(__file__).parent.parent / "data source"

EXPECTED_COLUMNS = {
    "customer_master.csv": {"customer_id", "customer_name", "customer_segment"},
    "product_catalog.csv": {"product_id", "product_name", "unit_price"},
    "ecommerce_sales_customer_analytics_150k.csv": {"order_id", "customer_id", "order_date"},
    "order_items.csv": {"order_id", "product_id", "quantity"},
}


def _header(file_name: str) -> set[str]:
    with open(DATA_DIR / file_name, newline="", encoding="utf-8") as f:
        return set(next(csv.reader(f)))


def test_expected_source_columns_present():
    for file_name, expected in EXPECTED_COLUMNS.items():
        header = _header(file_name)
        missing = expected - header
        assert not missing, f"{file_name} is missing columns: {missing}"
