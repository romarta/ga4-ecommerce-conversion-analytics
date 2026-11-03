-- GA4 E-commerce Customer Journey & Conversion Analytics
-- Initial exploration of event types and their availability.
-- Source: Google Analytics 4 public sample dataset.
-- Analysis period: 2020-11-01 to 2021-01-31.

SELECT
    event_name,
    COUNT(*) AS event_count,
    COUNT(DISTINCT event_date) AS active_days
FROM
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE
    _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
GROUP BY
    event_name
ORDER BY
    event_count DESC;





-- Weekly traffic and purchase conversion.
-- Period: 2020-11-01 to 2021-01-31.
-- Sessions are assigned to the date of their first recorded event.

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
        event_name
    FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
    WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
),

sessions AS (
    SELECT
        user_pseudo_id,
        ga_session_id,
        PARSE_DATE('%Y%m%d', MIN(event_date)) AS session_date,
        COUNTIF(event_name = 'purchase') > 0 AS has_purchase
    FROM events
    WHERE user_pseudo_id IS NOT NULL AND ga_session_id IS NOT NULL
    GROUP BY user_pseudo_id, ga_session_id
)

SELECT
    DATE_TRUNC(session_date, WEEK(MONDAY)) AS week_start,
    COUNT(DISTINCT session_date) AS observed_days,
    COUNT(*) AS total_sessions,
    COUNTIF(has_purchase) AS purchase_sessions,
    ROUND(100 * SAFE_DIVIDE(COUNTIF(has_purchase), COUNT(*)), 2) AS session_conversion_rate_pct
FROM sessions
GROUP BY week_start
ORDER BY week_start;