# Product — lakehouseit

## Target user

**Persona:** Data Engineer at a Series-A startup. Owns the data platform. Has Postgres production data and wants to build a proper analytics/ML layer without an enterprise vendor stack.

**Job they're trying to do:** Stand up a modern data stack (CDC ingestion, lakehouse storage, dbt models, quality gates) in days, not weeks.

**Current workflow:** Hand-rolled Postgres → Snowflake replication scripts. Manual dbt setup. No data quality. Pays Fivetran $$ or builds Airbyte themselves.

## The pain

1. **Setup time.** Integrating Debezium + Kafka + Iceberg + dbt + Great Expectations from scratch is 2+ weeks.
2. **Vendor cost.** Fivetran ($800/mo+) + Snowflake ($$$) + dbt Cloud ($$) + Monte Carlo ($$) adds up fast.
3. **Lock-in risk.** Vendor stacks make migration painful.
4. **No reference patterns.** Every team reinvents bronze/silver/gold conventions.

## Existing alternatives — and why they fall short

| Alternative | Why it doesn't fit |
|---|---|
| **Fivetran + Snowflake + dbt Cloud** | $$$ per month at scale, vendor lock-in |
| **Airbyte + Snowflake** | OSS for ingest but still expensive warehouse |
| **Custom Postgres → Snowflake scripts** | Brittle, no schema evolution, no quality gates |
| **Various GitHub starter templates** | Most are 2-year-old and use deprecated patterns (Hive, Parquet without Iceberg, etc.) |

## Our wedge

1. **One `docker compose up`.** Six services orchestrated, sample data seeded, dbt models pre-built.
2. **Modern stack baseline.** Iceberg (not Hive), CDC (not batch dumps), DuckDB query layer (no Snowflake required).
3. **Real seed data.** A synthetic SaaS company schema (users, events, subscriptions) — realistic enough to model.
4. **Pre-built dbt models.** Bronze/silver/gold examples that solve actual SaaS analytics use cases (DAU, churn cohort, MRR).
5. **Quality gates.** Great Expectations checks wired in from day one.

## MVP scope

**Must-have:**
- `docker-compose.yml` with: Postgres, Debezium, Kafka, Iceberg REST catalog, dbt, DuckDB
- Seed script generating ~100K rows of synthetic SaaS data
- Debezium config that streams Postgres → Kafka → Iceberg
- dbt project with sample bronze / silver / gold models
- Great Expectations data quality checks
- README walkthrough + screen-recording of `up → seed → query`

**Out of scope for MVP:**
- Cloud deployment templates (AWS/GCP/Azure)
- Production-grade auth/security
- Streaming dbt incremental models
- Lineage UI

## Success metric

- Reproducibility: `docker compose up` works on a clean machine in < 5 min
- GitHub Codespace template launches the full stack with one click
- 10+ external stars in 4 weeks

## Non-goals

- Not a hosted product. This is a template.
- Not for enterprise scale. Snowflake/Databricks remain the right tool above ~10TB.
- Not opinionated about cloud — runs anywhere Docker runs.
