-- bronze__orgs: 1:1 reflection of source `orgs` table from the lake.
{{ config(materialized='view') }}

SELECT
    id,
    name,
    owner_id
FROM {{ source('bronze_lake', 'orgs') }}
