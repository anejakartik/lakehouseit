# Roadmap — lakehouseit

## Shipping log (newest on top)

### 2026-06-15 — Scaffold
- [x] Repo + doc set + CI workflow
- [x] docker-compose skeleton with service declarations
- [x] dbt project layout (`bronze/`, `silver/`, `gold/`)
- Notes: target completing the working stack within 2 days.

---

## Short-term — next 4 weeks

- [ ] **P0 / Working `docker compose up`** — Postgres + Kafka + Debezium + Iceberg REST + dbt all healthy
- [ ] **P0 / Seed data generator** — synthetic SaaS schema (users, orgs, events, subscriptions) at ~100K rows
- [ ] **P0 / Debezium → Kafka → Iceberg pipeline** — verified change-events land in Iceberg
- [ ] **P0 / dbt bronze/silver/gold models** — sample SaaS analytics (DAU, churn cohort, MRR)
- [ ] **P0 / Great Expectations gates** — null checks, schema evolution checks, freshness checks
- [ ] **P0 / DuckDB query layer** — example queries against the gold layer
- [ ] **P0 / Screen recording** — 60-second `up → seed → query` walkthrough
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
