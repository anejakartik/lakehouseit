-- bronze__users.sql — 1:1 reflection of source users table from Iceberg
-- Placeholder: lands with full pipeline this week.

{{ config(materialized='view') }}

SELECT
    id,
    email,
    signup_at,
    plan
FROM {{ source('iceberg_raw', 'users') }}
