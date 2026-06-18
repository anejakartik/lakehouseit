-- bronze__events: 1:1 reflection of source `events` table from the lake.
{{ config(materialized='view') }}

SELECT
    id,
    user_id,
    org_id,
    event_name,
    occurred_at,
    props
FROM {{ source('bronze_lake', 'events') }}
