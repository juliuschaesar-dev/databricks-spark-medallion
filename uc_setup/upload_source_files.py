"""Uploads the local CSVs under data_source/ to the Unity Catalog landing volume.

Run once (or whenever the source CSVs change) after uc_setup.run_uc_setup has created
the volume, and before src.bronze.ingest runs.
"""
from pathlib import Path

from databricks.sdk import WorkspaceClient

from src.bronze.ingest import FEEDS
from src.common.config import SOURCE_VOLUME_PATH

DATA_DIR = Path(__file__).parent.parent / "data_source"


def run() -> None:
    w = WorkspaceClient()
    for feed in FEEDS:
        local_path = DATA_DIR / feed.source_file
        remote_path = f"{SOURCE_VOLUME_PATH}/{feed.source_file}"
        with open(local_path, "rb") as f:
            w.files.upload(remote_path, f, overwrite=True)
        print(f"Uploaded {feed.source_file} -> {remote_path}")


if __name__ == "__main__":
    run()
