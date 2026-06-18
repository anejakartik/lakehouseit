-- silver__subscriptions: subscription history with derived lifecycle columns.
{{ config(materialized='table') }}

SELECT
    s.id                                        AS subscription_id,
    s.org_id,
    o.name                                      AS org_name,
    s.plan,
    s.mrr_usd,
    s.started_at,
    s.ended_at,
    s.ended_at IS NULL                          AS is_active,
    COALESCE(s.ended_at, CURRENT_TIMESTAMP)
        - s.started_at                          AS lifetime,
    date_trunc('month', s.started_at)           AS started_month,
    date_trunc('month', s.ended_at)             AS ended_month
FROM {{ ref('bronze__subscriptions') }} s
LEFT JOIN {{ ref('bronze__orgs') }} o ON o.id = s.org_id
