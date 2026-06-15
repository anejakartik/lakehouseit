-- gold__dau.sql — daily active users from the silver event stream
-- Placeholder: actual implementation lands with seed data + full pipeline this week.

{{ config(materialized='table') }}

SELECT
    date_trunc('day', occurred_at) AS day,
    COUNT(DISTINCT user_id)        AS dau
FROM {{ ref('silver__user_events') }}
GROUP BY 1
ORDER BY 1
