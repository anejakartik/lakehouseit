-- gold__dau: daily active users from the silver event stream.
{{ config(materialized='table') }}

SELECT
    event_day                  AS day,
    COUNT(DISTINCT user_id)    AS dau,
    COUNT(*)                   AS events
FROM {{ ref('silver__user_events') }}
GROUP BY 1
ORDER BY 1
