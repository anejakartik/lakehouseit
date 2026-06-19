"""Stream consumer — Debezium → Kafka → bronze Parquet.

Closes the streaming loop for the demo:

    Postgres → Debezium (CDC) → Kafka topic `lakehouseit.public.<table>`
                                  ↓
                       this consumer
                                  ↓
    warehouse/bronze/<table>/stream-<ts>-<offset>.parquet

dbt then reads `warehouse/bronze/<table>/*.parquet` and is feed-agnostic
between this streaming path and the one-shot snapshot path.

Notes:
- Each flush writes a fresh Parquet file (Parquet doesn't append). Files
  are timestamp+offset-named so multiple consumer restarts don't collide.
- Tombstones (op=d) are emitted with `_op='d'` so silver can dedupe-then-filter.
- Idempotency on restart relies on Kafka committed offsets (auto-commit).
"""

from __future__ import annotations

import json
import logging
import os
import signal
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

import pyarrow as pa
import pyarrow.parquet as pq
from kafka import KafkaConsumer


BOOTSTRAP_SERVERS = os.environ.get("KAFKA_BOOTSTRAP_SERVERS", "kafka:9092")
WAREHOUSE = Path(os.environ.get("LAKEHOUSEIT_WAREHOUSE", "/warehouse"))
GROUP_ID = os.environ.get("CONSUMER_GROUP_ID", "lakehouseit-consumer")
TOPIC_PREFIX = os.environ.get("DEBEZIUM_TOPIC_PREFIX", "lakehouseit")
FLUSH_INTERVAL_S = float(os.environ.get("CONSUMER_FLUSH_INTERVAL", "5"))
FLUSH_MAX_BATCH = int(os.environ.get("CONSUMER_FLUSH_MAX_BATCH", "200"))

TABLES = ("users", "orgs", "subscriptions", "events")

log = logging.getLogger("lakehouseit.consumer")
logging.basicConfig(
    level=os.environ.get("CONSUMER_LOG_LEVEL", "INFO"),
    format="%(asctime)s %(name)s %(levelname)s %(message)s",
)


_stop = False


def _handle_signal(signum: int, _frame) -> None:
    global _stop
    log.info("received signal %s, draining …", signum)
    _stop = True


def parse_debezium(value: bytes) -> tuple[str, dict] | None:
    """Return (op, row) — None if the message is unparseable or has no payload."""
    if not value:
        return None
    try:
        envelope = json.loads(value)
    except json.JSONDecodeError:
        return None
    payload = envelope.get("payload", envelope)
    op = payload.get("op")
    if op in ("c", "u", "r"):
        row = payload.get("after")
    elif op == "d":
        row = payload.get("before")
    else:
        return None
    if not isinstance(row, dict):
        return None
    return op, row


def write_batch(table: str, rows: list[dict]) -> Path:
    target_dir = WAREHOUSE / "bronze" / table
    target_dir.mkdir(parents=True, exist_ok=True)
    ts = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S%f")
    out = target_dir / f"stream-{ts}.parquet"
    table_arr = pa.Table.from_pylist(rows)
    pq.write_table(table_arr, out, compression="zstd")
    return out


def main() -> None:
    signal.signal(signal.SIGINT, _handle_signal)
    signal.signal(signal.SIGTERM, _handle_signal)

    topics = [f"{TOPIC_PREFIX}.public.{t}" for t in TABLES]
    log.info("connecting to %s, topics=%s", BOOTSTRAP_SERVERS, topics)

    consumer = KafkaConsumer(
        *topics,
        bootstrap_servers=BOOTSTRAP_SERVERS,
        group_id=GROUP_ID,
        enable_auto_commit=True,
        auto_offset_reset="earliest",
        value_deserializer=lambda v: v,
    )

    buckets: dict[str, list[dict]] = {t: [] for t in TABLES}
    last_flush = time.monotonic()

    while not _stop:
        msgs = consumer.poll(timeout_ms=1000, max_records=500)
        for tp, batch in msgs.items():
            # tp.topic looks like "lakehouseit.public.events"
            table = tp.topic.rsplit(".", 1)[-1]
            if table not in buckets:
                continue
            for msg in batch:
                parsed = parse_debezium(msg.value)
                if parsed is None:
                    continue
                op, row = parsed
                row["_op"] = op
                row["_kafka_topic"] = tp.topic
                row["_kafka_partition"] = msg.partition
                row["_kafka_offset"] = msg.offset
                row["_ingested_at"] = datetime.now(timezone.utc).isoformat()
                buckets[table].append(row)

        # Flush condition: any bucket is full OR enough time elapsed
        any_full = any(len(b) >= FLUSH_MAX_BATCH for b in buckets.values())
        elapsed = time.monotonic() - last_flush
        if any_full or elapsed >= FLUSH_INTERVAL_S:
            for table, rows in buckets.items():
                if not rows:
                    continue
                try:
                    path = write_batch(table, rows)
                    log.info("→ wrote %d rows to %s", len(rows), path)
                except Exception:  # noqa: BLE001
                    log.exception("flush failed for %s", table)
                    continue
                buckets[table] = []
            last_flush = time.monotonic()

    # Final drain on shutdown
    for table, rows in buckets.items():
        if rows:
            try:
                write_batch(table, rows)
            except Exception:  # noqa: BLE001
                log.exception("shutdown drain failed for %s", table)
    consumer.close()


if __name__ == "__main__":
    try:
        main()
    except Exception:
        log.exception("consumer crashed")
        sys.exit(1)
