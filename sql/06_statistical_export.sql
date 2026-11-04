-- Session-level dataset for statistical analysis.
-- Period: 2020-11-01 to 2021-01-31.

WITH events AS (
    SELECT
        user_pseudo_id,
        (
            SELECT ep.value.int_value
            FROM UNNEST(event_params) AS ep
            WHERE ep.key = 'ga_session_id'
            LIMIT 1
        ) AS ga_session_id,
        event_date,
        event_timestamp,
        event_name,
        device.category AS device_category
    FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
    WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
)

SELECT
    user_pseudo_id,
    ga_session_id,
    PARSE_DATE('%Y%m%d', MIN(event_date)) AS session_date,
    ARRAY_AGG(
        device_category IGNORE NULLS
        ORDER BY event_timestamp
        LIMIT 1
    )[SAFE_OFFSET(0)] AS device_category,
    COUNTIF(event_name = 'view_search_results') > 0 AS has_search,
    COUNTIF(event_name = 'purchase') > 0 AS has_purchase
FROM events
WHERE user_pseudo_id IS NOT NULL AND ga_session_id IS NOT NULL
GROUP BY user_pseudo_id, ga_session_id;