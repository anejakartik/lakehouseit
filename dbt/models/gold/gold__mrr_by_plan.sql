-- gold__mrr_by_plan: current MRR aggregated by plan from active subscriptions only.
{{ config(materialized='table') }}

SELECT
    plan,
    COUNT(*)            AS active_subscriptions,
    SUM(mrr_usd)        AS mrr_usd,
    ROUND(AVG(mrr_usd), 2) AS avg_mrr_usd
FROM {{ ref('silver__subscriptions') }}
WHERE is_active
GROUP BY plan
ORDER BY mrr_usd DESC
