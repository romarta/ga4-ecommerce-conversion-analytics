-- Prepare session conversion metrics by date and UTC hour.
CREATE OR REPLACE TABLE
  `ga4-conversion-analytics.reporting.hourly_performance`
PARTITION BY session_date AS

WITH events AS (
  SELECT
    user_pseudo_id,
    (
      SELECT ep.value.int_value
      FROM UNNEST(event_params) AS ep
      WHERE ep.key = 'ga_session_id'
      LIMIT 1
    ) AS ga_session_id,
    event_timestamp,
    event_name
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
),

sessions AS (
  SELECT
    user_pseudo_id,
    ga_session_id,
    MIN(event_timestamp) AS session_timestamp,
    MAX(IF(event_name = 'purchase', 1, 0)) AS has_purchase
  FROM events
  WHERE user_pseudo_id IS NOT NULL  AND ga_session_id IS NOT NULL
  GROUP BY user_pseudo_id, ga_session_id
)

SELECT
  DATE(TIMESTAMP_MICROS(session_timestamp)) AS session_date,
  EXTRACT(HOUR FROM TIMESTAMP_MICROS(session_timestamp)) AS session_hour_utc,
  COUNT(*) AS total_sessions,
  SUM(has_purchase) AS purchase_sessions
FROM sessions
GROUP BY session_date, session_hour_utc;