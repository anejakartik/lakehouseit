# lakehouseit

> Open-source modern data stack template. Postgres → CDC → Kafka → Iceberg → dbt → DuckDB. One `docker compose up`.

**Live demo:** GitHub Codespace template *(coming soon)* + DuckDB-WASM playground at [lakehouseit.kartikaneja.com](https://lakehouseit.kartikaneja.com) *(coming soon)*
**Status:** alpha · last shipped 2026-06-17
**Built by:** [Kartik Aneja](https://kartikaneja.com) — AI/ML Platform Engineer

[![CI](https://github.com/anejakartik/lakehouseit/actions/workflows/ci.yml/badge.svg)](https://github.com/anejakartik/lakehouseit/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](./LICENSE)

---

## Why this exists

You're a Data Engineer at an early-stage startup. You want the modern stack (Iceberg, dbt, CDC) but you don't have 2 weeks to integrate 6 vendors and you don't have $5K/month for the managed equivalents.

See [PRODUCT.md](./PRODUCT.md) for the full writeup.

## What works today (alpha MVP)

End-to-end batch pipeline runs via a single `make demo`:

- **Postgres source** — `postgres/init.sql` schema (`users`, `orgs`, `events`, `subscriptions`) with `wal_level=logical` for CDC
- **Synthetic seed** — `scripts/seed_postgres.py` populates ~200 users / 60 orgs / ~150 subscriptions / ~24K events; deterministic
- **Bronze snapshot** — `scripts/snapshot_to_parquet.py` reads from Postgres via DuckDB's `postgres` extension and writes Iceberg-style Parquet layout under `warehouse/bronze/<table>/data.parquet`
- **dbt project** — 4 bronze (passthrough views), 2 silver (cleaned/enriched), 4 gold (DAU, WAU by plan, MRR by plan, monthly churn) all materializing into a single DuckDB file
- **Query layer** — `scripts/query.sh` runs sample analytics against the gold layer; matching `.sql` for `docker compose exec dbt duckdb` invocations
- **Streaming track scaffolded** — Kafka + Debezium + Iceberg-REST containers declared under the `streaming` Compose profile; `scripts/register_debezium.sh` registers a Postgres→Kafka connector for the four source tables

## Try it (60 seconds, local)

```bash
git clone https://github.com/anejakartik/lakehouseit.git
cd lakehouseit
make demo
# = make up → make seed → make snapshot → make build → make query
```

What `make demo` produces:

```
warehouse/
├── bronze/
│   ├── users/data.parquet
│   ├── orgs/data.parquet
│   ├── subscriptions/data.parquet
│   └── events/data.parquet
└── lakehouseit.duckdb        ← silver + gold tables, queryable via DuckDB CLI
```

Optional streaming track:

```bash
make streaming-up   # starts kafka + debezium + iceberg-rest, registers the CDC connector
```

## Architecture

See [docs/architecture.md](./docs/architecture.md). Two-track design: a batch path (`Postgres → snapshot → Parquet → dbt → DuckDB`) for deterministic demos and a streaming path (`Postgres → Debezium → Kafka → consumer → Iceberg`) that produces the same bronze artifacts. dbt and downstream queries are identical for both feeds.

## What's next

See [ROADMAP.md](./ROADMAP.md). Top items: Kafka → Iceberg sink (closing the streaming loop), Great Expectations gates between bronze and silver, GitHub Codespace template, public DuckDB-WASM playground.

## Contributing

PRs welcome. See [AGENTS.md](./AGENTS.md).

## License

MIT — see [LICENSE](./LICENSE).
