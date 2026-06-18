"""One-shot batch snapshot: Postgres → Parquet (bronze layer).

This is the "fast path" demo wiring. Real production uses the streaming track
(Debezium → Kafka → consumer → Iceberg), but for a deterministic demo + dbt
build, snapshotting the source tables to Parquet is far simpler and produces
the same downstream artifacts.

Output layout (mirrors Iceberg-style partitions for future migration):
    warehouse/bronze/users/data.parquet
    warehouse/bronze/orgs/data.parquet
    warehouse/bronze/subscriptions/data.parquet
    warehouse/bronze/events/data.parquet
"""

from __future__ import annotations

import os
import sys
from pathlib import Path

import duckdb


WAREHOUSE = Path(os.environ.get("LAKEHOUSEIT_WAREHOUSE", "/warehouse"))
PG_HOST = os.environ.get("POSTGRES_HOST", "postgres")
PG_PORT = os.environ.get("POSTGRES_PORT", "5432")
PG_USER = os.environ.get("POSTGRES_USER", "postgres")
PG_PASSWORD = os.environ.get("POSTGRES_PASSWORD", "lakehouseit")
PG_DB = os.environ.get("POSTGRES_DB", "appdb")

TABLES = ("users", "orgs", "subscriptions", "events")


def main() -> None:
    bronze = WAREHOUSE / "bronze"
    bronze.mkdir(parents=True, exist_ok=True)

    con = duckdb.connect(":memory:")
    con.execute("INSTALL postgres; LOAD postgres;")
    con.execute(
        f"ATTACH 'postgresql://{PG_USER}:{PG_PASSWORD}@{PG_HOST}:{PG_PORT}/{PG_DB}' AS src (TYPE postgres, READ_ONLY)"
    )

    for table in TABLES:
        target_dir = bronze / table
        target_dir.mkdir(exist_ok=True)
        target_file = target_dir / "data.parquet"
        print(f"→ snapshotting src.public.{table} → {target_file}")
        con.execute(
            f"COPY (SELECT * FROM src.public.{table}) TO '{target_file}' (FORMAT PARQUET, COMPRESSION ZSTD)"
        )

    counts = []
    for table in TABLES:
        n = con.execute(f"SELECT COUNT(*) FROM read_parquet('{bronze / table / 'data.parquet'}')").fetchone()[0]
        counts.append((table, n))

    print("\n✓ bronze snapshot complete:")
    for table, n in counts:
        print(f"    {table}: {n:,} rows")


if __name__ == "__main__":
    try:
        main()
    except Exception as exc:  # noqa: BLE001
        print(f"snapshot failed: {exc}", file=sys.stderr)
        sys.exit(1)
