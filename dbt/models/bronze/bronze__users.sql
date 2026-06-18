-- bronze__users: 1:1 reflection of source `users` table from the lake.
{{ config(materialized='view') }}

SELECT
    id,
    email,
    signup_at,
    plan
FROM {{ source('bronze_lake', 'users') }}
