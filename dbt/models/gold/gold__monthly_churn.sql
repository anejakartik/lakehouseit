-- gold__monthly_churn: month-over-month churn rate.
--
-- churn_rate = subscriptions that ended during the month
--              ÷ subscriptions that were active at the start of the month
{{ config(materialized='table') }}

WITH months AS (
    SELECT DISTINCT date_trunc('month', started_at) AS month
    FROM {{ ref('silver__subscriptions') }}
    UNION
    SELECT DISTINCT date_trunc('month', ended_at) AS month
    FROM {{ ref('silver__subscriptions') }}
    WHERE ended_at IS NOT NULL
),
active_at_start AS (
    SELECT
        m.month,
        COUNT(*) AS total_subs_at_start
    FROM months m
    LEFT JOIN {{ ref('silver__subscriptions') }} s
        ON s.started_at < m.month
       AND (s.ended_at IS NULL OR s.ended_at >= m.month)
    GROUP BY m.month
),
churned_in_month AS (
    SELECT
        date_trunc('month', ended_at) AS month,
        COUNT(*)                       AS churned_subs
    FROM {{ ref('silver__subscriptions') }}
    WHERE ended_at IS NOT NULL
    GROUP BY 1
)
SELECT
    a.month,
    COALESCE(c.churned_subs, 0)        AS churned_subs,
    a.total_subs_at_start,
    CASE WHEN a.total_subs_at_start = 0 THEN 0
         ELSE ROUND(COALESCE(c.churned_subs, 0)::DOUBLE / a.total_subs_at_start, 4)
    END                                AS churn_rate
FROM active_at_start a
LEFT JOIN churned_in_month c USING (month)
ORDER BY a.month
