-- bronze__events.sql — 1:1 reflection of source events table from Iceberg
-- Placeholder: lands with full pipeline this week.

{{ config(materialized='view') }}

SELECT
    id,
    user_id,
    org_id,
    event_name,
    occurred_at,
    props
FROM {{ source('iceberg_raw', 'events') }}
