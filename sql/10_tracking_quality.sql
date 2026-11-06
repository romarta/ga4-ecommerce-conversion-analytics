-- Prepare session-level tracking quality metrics for Power BI.
CREATE OR REPLACE TABLE
  `ga4-conversion-analytics.reporting.tracking_quality`
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
    event_name,
    device.category AS device_category
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE _TABLE_SUFFIX BETWEEN '20201125' AND '20210131'
),

sessions AS (
  SELECT
    DATE(TIMESTAMP_MICROS(MIN(event_timestamp))) AS session_date,
    ARRAY_AGG(
      COALESCE(device_category, 'unknown')
      ORDER BY event_timestamp
      LIMIT 1
    )[OFFSET(0)] AS device_category,
    MIN(IF(event_name = 'add_to_cart', event_timestamp, NULL)) AS cart_ts,
    MIN(IF(event_name = 'begin_checkout', event_timestamp, NULL)) AS checkout_ts,
    MIN(IF(event_name = 'add_shipping_info', event_timestamp, NULL)) AS shipping_ts,
    MIN(IF(event_name = 'add_payment_info', event_timestamp, NULL)) AS payment_ts,
    MIN(IF(event_name = 'purchase', event_timestamp, NULL)) AS purchase_ts,
-- Preserve the recorded order of checkout events.
STRING_AGG(
  CASE event_name
    WHEN 'begin_checkout' THEN 'C'
    WHEN 'add_shipping_info' THEN 'S'
    WHEN 'add_payment_info' THEN 'P'
    WHEN 'purchase' THEN 'B'
  END,
  '' ORDER BY event_timestamp
) AS event_sequence
  FROM events
  WHERE user_pseudo_id IS NOT NULL AND ga_session_id IS NOT NULL
  GROUP BY user_pseudo_id, ga_session_id
)

SELECT
  session_date,
  device_category,

  COUNTIF(purchase_ts IS NOT NULL) AS purchase_sessions,

  COUNTIF(
    purchase_ts IS NOT NULL
    AND cart_ts IS NULL
  ) AS purchase_without_cart_sessions,

  COUNTIF(
    purchase_ts IS NOT NULL
    AND checkout_ts IS NULL
  ) AS purchase_without_checkout_sessions,

  -- Count sessions containing an ordered checkout-to-purchase sequence.
  COUNTIF(
    REGEXP_CONTAINS(event_sequence, r'C.*S.*P.*B')
  ) AS ordered_checkout_purchase_sessions

FROM sessions
GROUP BY session_date, device_category;