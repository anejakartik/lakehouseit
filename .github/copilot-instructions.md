# Copilot instructions for lakehouseit

> Same intent as [../AGENTS.md](../AGENTS.md), Copilot-format.

## Product context

This repo is **lakehouseit** — open-source modern data stack template. See [PRODUCT.md](../PRODUCT.md).

- **Target user:** Data Engineer at an early-stage startup
- **Their pain:** 2-week setup time, vendor cost, no reference patterns
- **Our wedge:** One `docker compose up`, Iceberg + dbt + Great Expectations preconfigured, realistic seed data

## Conventions

- **dbt models:** bronze__/silver__/gold__ prefix, one model per file
- **Postgres seed:** synthetic SaaS schema (users, orgs, events, subscriptions)
- **No paid SaaS deps** — everything in compose must run locally for free

## Hard constraints

- `docker compose up` must succeed on a clean machine in < 5 min
- Sample data ≥ 100K rows so queries are realistic
- Free-tier hosting only (Codespace, Vercel for WASM, no managed Snowflake/Databricks)

## Repo layout

```
lakehouseit/
├── README.md, PRODUCT.md, ROADMAP.md, AGENTS.md, DEMO.md
├── .github/
├── docs/architecture.md
├── docker-compose.yml
├── postgres/init.sql
├── debezium/config.json
├── dbt/
│   ├── dbt_project.yml
│   └── models/
│       ├── bronze/
│       ├── silver/
│       └── gold/
├── scripts/seed.sh
└── queries/             # sample DuckDB queries against gold layer
```
