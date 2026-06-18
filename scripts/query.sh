#!/usr/bin/env bash
# Run sample analytics queries against the gold layer using DuckDB.
#
# Usage:
#     ./scripts/query.sh
#     ./scripts/query.sh ./scripts/query_revenue.sql      # specific query file

set -euo pipefail

WAREHOUSE="${LAKEHOUSEIT_WAREHOUSE:-./warehouse}"
DUCKDB_FILE="${DUCKDB_FILE:-${WAREHOUSE}/lakehouseit.duckdb}"

if ! command -v duckdb >/dev/null; then
    echo "duckdb CLI not found on PATH. Install: https://duckdb.org/docs/installation/" >&2
    exit 1
fi

if [[ "$#" -ge 1 ]]; then
    sql_file="$1"
    duckdb "${DUCKDB_FILE}" < "${sql_file}"
    exit 0
fi

duckdb "${DUCKDB_FILE}" <<'SQL'
.mode markdown
.headers on
.timer on

.print
.print === DAILY ACTIVE USERS (last 30 days) ===
SELECT day, dau
FROM main_gold.gold__dau
WHERE day >= current_date - INTERVAL 30 DAY
ORDER BY day DESC
LIMIT 30;

.print
.print === MRR BY PLAN (current snapshot) ===
SELECT plan, active_subscriptions, mrr_usd
FROM main_gold.gold__mrr_by_plan
ORDER BY mrr_usd DESC;

.print
.print === MONTHLY CHURN RATE ===
SELECT month, churned_subs, total_subs_at_start, churn_rate
FROM main_gold.gold__monthly_churn
ORDER BY month DESC
LIMIT 6;
SQL
