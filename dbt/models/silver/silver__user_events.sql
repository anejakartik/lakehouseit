-- silver__user_events.sql — cleaned event stream with user dimension joined in
-- Placeholder: lands with full pipeline this week.

{{ config(materialized='table') }}

SELECT
    e.id,
    e.user_id,
    e.org_id,
    e.event_name,
    e.occurred_at,
    u.plan AS user_plan
FROM {{ ref('bronze__events') }} e
LEFT JOIN {{ ref('bronze__users') }} u
    ON u.id = e.user_id
