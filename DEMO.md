# Demo — lakehouseit

## Modes

| Mode | URL | Status |
|---|---|---|
| **Codespace launch** | (Click "Code → Codespaces" on the repo page) | *coming soon* |
| **Local docker compose** | `docker compose up` after clone | *scaffold; full compose lands this week* |
| **DuckDB-WASM playground** | [lakehouseit.kartikaneja.com](https://lakehouseit.kartikaneja.com) | *coming soon* |

## Local quickstart (target)

```bash
git clone https://github.com/anejakartik/lakehouseit.git
cd lakehouseit
docker compose up -d
./scripts/seed.sh                       # ~100K rows of synthetic SaaS data
docker compose run dbt dbt run          # bronze → silver → gold
docker compose run duckdb < queries/dau.sql
```

## Recorded walkthrough

*(60-second screen recording lands with first working compose — target this week)*
