-- Prepare session-level event coverage for Power BI.
CREATE OR REPLACE TABLE `ga4-conversion-analytics.reporting.checkout_event_coverage`
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
    user_pseudo_id,
    ga_session_id,
    DATE(TIMESTAMP_MICROS(MIN(event_timestamp))) AS session_date,
    ARRAY_AGG(
      COALESCE(device_category, 'unknown')
      ORDER BY event_timestamp
      LIMIT 1
    )[OFFSET(0)] AS device_category,

    MAX(IF(event_name = 'view_item', 1, 0)) AS has_view_item,
    MAX(IF(event_name = 'add_to_cart', 1, 0)) AS has_add_to_cart,
    MAX(IF(event_name = 'begin_checkout', 1, 0)) AS has_begin_checkout,
    MAX(IF(event_name = 'add_shipping_info', 1, 0)) AS has_shipping_info,
    MAX(IF(event_name = 'add_payment_info', 1, 0)) AS has_payment_info,
    MAX(IF(event_name = 'purchase', 1, 0)) AS has_purchase

  FROM events
  WHERE user_pseudo_id IS NOT NULL AND ga_session_id IS NOT NULL
  GROUP BY user_pseudo_id, ga_session_id
)

SELECT
  session_date,
  device_category,
  COUNT(*) AS total_sessions,
  SUM(has_view_item) AS view_item_sessions,
  SUM(has_add_to_cart) AS add_to_cart_sessions,
  SUM(has_begin_checkout) AS checkout_sessions,
  SUM(has_shipping_info) AS shipping_sessions,
  SUM(has_payment_info) AS payment_sessions,
  SUM(has_purchase) AS purchase_sessions,
  COUNTIF(has_begin_checkout = 1 AND has_purchase = 1) AS checkout_purchase_sessions
FROM sessions
GROUP BY session_date, device_category;