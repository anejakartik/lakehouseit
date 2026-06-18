# Roadmap — lakehouseit

## Shipping log (newest on top)

### 2026-06-17 — End-to-end batch pipeline + streaming scaffold
- [x] `docker compose up postgres dbt` healthy + `make` orchestration
- [x] Seed data generator — `scripts/seed_postgres.py` deterministically inserts ~200 users / 60 orgs / ~150 subscriptions / ~24K events
- [x] Bronze snapshot — `scripts/snapshot_to_parquet.py` materializes Postgres → Parquet via DuckDB's `postgres` extension, mimicking Iceberg layout
- [x] dbt project fleshed out: 4 bronze passthrough views, silver `user_events` + `subscriptions` with derived lifecycle columns, gold `dau` / `weekly_active_users` / `mrr_by_plan` / `monthly_churn`
- [x] dbt profile + sources.yml wired against the `/warehouse` volume
- [x] DuckDB query layer — `scripts/query.sh` + `dbt/queries.sql` against gold tables
- [x] Streaming track scaffolded — Kafka/Debezium/Iceberg-REST under `streaming` Compose profile, `scripts/register_debezium.sh` registers a CDC connector for the four source tables
- [x] `Makefile` orchestration — `make demo` runs the full batch path end-to-end
- Notes: streaming-side Kafka→Iceberg sink is the next P0; for now both tracks land in the same `warehouse/bronze/` shape so dbt is feed-agnostic.

### 2026-06-15 — Scaffold
- [x] Repo + doc set + CI workflow
- [x] docker-compose skeleton with service declarations
- [x] dbt project layout (`bronze/`, `silver/`, `gold/`)

---

## Short-term — next 4 weeks

- [ ] **P0 / Kafka → Iceberg sink** — close the streaming loop so the streaming track actually feeds bronze (currently it just produces CDC events)
- [ ] **P0 / Great Expectations gates** — null checks, schema evolution checks, freshness checks between bronze and silver
- [ ] **P0 / Screen recording** — 60-second `make demo` walkthrough (top of the README)
- [ ] **P1 / GitHub Codespace template** — one-click launch via codespaces

## Medium-term — months 2–3

- [ ] **AWS deployment template** — Terraform for S3 + MSK + Glue catalog
- [ ] **GCP deployment template** — GCS + Pub/Sub + BigQuery Iceberg connector
- [ ] **More dbt model patterns** — e-commerce, fintech, healthcare templates
- [ ] **Streaming dbt incremental** — dbt 1.10+ streaming models
- [ ] **Lineage UI** — OpenLineage integration
- [ ] **Cost-aware partitioning recommender** — analyze query patterns, suggest partition keys

## Long-term — 6+ months

- [ ] Multi-tenant dbt project structure for SaaS data warehouses
- [ ] Native Polars query examples alongside DuckDB
- [ ] Iceberg compaction + maintenance scripts

## Content posts derived from this roadmap

| Feature | Posted? |
|---|---|
| Launch | _pending_ |
| Why Iceberg over Delta / Hudi | _pending_ |
| Modern data stack on a $5 server | _pending_ |
