-- silver__user_events: cleaned event stream enriched with user + org dimensions.
-- Filters out malformed rows (null user_id / unknown event_name) so downstream
-- gold models don't have to defend against them.
{{ config(materialized='table') }}

WITH base AS (
    SELECT
        e.id,
        e.user_id,
        e.org_id,
        e.event_name,
        e.occurred_at,
        e.props
    FROM {{ ref('bronze__events') }} e
    WHERE e.user_id IS NOT NULL
      AND e.event_name IS NOT NULL
)
SELECT
    b.id AS event_id,
    b.user_id,
    b.org_id,
    b.event_name,
    b.occurred_at,
    b.props,
    u.plan AS user_plan,
    o.name AS org_name,
    date_trunc('day',  b.occurred_at) AS event_day,
    date_trunc('week', b.occurred_at) AS event_week
FROM base b
LEFT JOIN {{ ref('bronze__users') }} u ON u.id = b.user_id
LEFT JOIN {{ ref('bronze__orgs')  }} o ON o.id = b.org_id
