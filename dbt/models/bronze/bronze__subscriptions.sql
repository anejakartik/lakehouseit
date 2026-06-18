-- bronze__subscriptions: 1:1 reflection of source `subscriptions` table from the lake.
{{ config(materialized='view') }}

SELECT
    id,
    org_id,
    plan,
    started_at,
    ended_at,
    mrr_usd
FROM {{ source('bronze_lake', 'subscriptions') }}
