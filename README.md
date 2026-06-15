# lakehouseit

> Open-source modern data stack template. Postgres → CDC → Kafka → Iceberg → dbt → DuckDB. One `docker compose up`.

**Live demo:** GitHub Codespace template *(coming soon)* + DuckDB-WASM playground at [lakehouseit.kartikaneja.com](https://lakehouseit.kartikaneja.com) *(coming soon)*
**Status:** scaffold · last shipped 2026-06-15
**Built by:** [Kartik Aneja](https://kartikaneja.com) — AI/ML Platform Engineer

[![CI](https://github.com/anejakartik/lakehouseit/actions/workflows/ci.yml/badge.svg)](https://github.com/anejakartik/lakehouseit/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](./LICENSE)

---

## Why this exists

You're a Data Engineer at an early-stage startup. You want the modern stack (Iceberg, dbt, CDC) but you don't have 2 weeks to integrate 6 vendors and you don't have $5K/month for the managed equivalents.

See [PRODUCT.md](./PRODUCT.md) for the full writeup.

## What works today

- *(scaffolding — `docker compose up` skeleton + dbt project layout in place; full pipeline lands this week)*
- Repo + doc structure
- Empty docker-compose skeleton (Postgres + Kafka + Debezium + Iceberg REST + dbt + DuckDB containers declared)
- dbt project skeleton with bronze/silver/gold model directories

## Try it (when shipped)

```bash
git clone https://github.com/anejakartik/lakehouseit.git
cd lakehouseit
docker compose up -d              # Postgres + Kafka + Debezium + Iceberg REST + dbt
./scripts/seed.sh                  # generates synthetic SaaS data
docker compose run dbt dbt run     # bronze/silver/gold models
docker compose run duckdb query.sql # query the gold layer
```

## Architecture

See [docs/architecture.md](./docs/architecture.md). One command starts all 6 services. CDC streams `Postgres → Debezium → Kafka → Iceberg` and dbt models build bronze/silver/gold on top.

## What's next

See [ROADMAP.md](./ROADMAP.md). Top items: working `docker compose up`, seed data, dbt bronze/silver/gold, DuckDB-WASM query playground.

## Contributing

PRs welcome. See [AGENTS.md](./AGENTS.md).

## License

MIT — see [LICENSE](./LICENSE).
