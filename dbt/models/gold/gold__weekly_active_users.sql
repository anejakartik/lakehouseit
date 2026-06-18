-- gold__weekly_active_users: distinct users per week, broken down by plan.
{{ config(materialized='table') }}

SELECT
    event_week         AS week,
    user_plan,
    COUNT(DISTINCT user_id) AS wau
FROM {{ ref('silver__user_events') }}
GROUP BY 1, 2
ORDER BY 1, 2
