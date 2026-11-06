CREATE OR REPLACE TABLE
  `ga4-conversion-analytics.reporting.purchase_path_archetypes`
PARTITION BY session_date
CLUSTER BY device_category, path_archetype AS

WITH events AS (
  SELECT
    user_pseudo_id,
    (
      SELECT value.int_value
      FROM UNNEST(event_params)
      WHERE key = 'ga_session_id'
    ) AS ga_session_id,
    event_date,
    event_timestamp,
    device.category AS device_category,
    event_name
  FROM
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE
    _TABLE_SUFFIX BETWEEN '20201125' AND '20210131'
),

sessions AS (
  SELECT
    PARSE_DATE('%Y%m%d', MIN(event_date)) AS session_date,

    ARRAY_AGG(
      device_category IGNORE NULLS
      ORDER BY event_timestamp
      LIMIT 1
    )[SAFE_OFFSET(0)] AS device_category,

    COUNTIF(event_name = 'purchase') > 0 AS has_purchase,
    COUNTIF(event_name = 'add_to_cart') > 0 AS has_cart,
    COUNTIF(event_name = 'begin_checkout') > 0 AS has_checkout,

    STRING_AGG(
      CASE event_name
        WHEN 'view_item' THEN 'V'
        WHEN 'add_to_cart' THEN 'A'
        WHEN 'begin_checkout' THEN 'C'
        WHEN 'add_shipping_info' THEN 'S'
        WHEN 'add_payment_info' THEN 'P'
        WHEN 'purchase' THEN 'B'
      END,
      '' ORDER BY event_timestamp
    ) AS event_sequence

  FROM events
  WHERE
    user_pseudo_id IS NOT NULL
    AND ga_session_id IS NOT NULL

  GROUP BY
    user_pseudo_id,
    ga_session_id
),

classified_sessions AS (
  SELECT
    session_date,
    device_category,

    CASE
      WHEN REGEXP_CONTAINS(
        event_sequence, r'V.*A.*C.*S.*P.*B'
      )
        THEN 'Full Ordered Journey'

      WHEN REGEXP_CONTAINS(
        event_sequence, r'C.*S.*P.*B'
      ) AND NOT has_cart
        THEN 'Ordered Checkout, No Cart'

      WHEN REGEXP_CONTAINS(
        event_sequence, r'C.*S.*P.*B'
      )
        THEN 'Ordered Checkout, Other'

      WHEN has_checkout
        THEN 'Incomplete Checkout Order'

      ELSE 'No Checkout Observed'
    END AS path_archetype

  FROM sessions
  WHERE has_purchase
)

SELECT
  session_date,
  device_category,
  path_archetype,
  COUNT(*) AS purchase_sessions
FROM classified_sessions
GROUP BY
  session_date,
  device_category,
  path_archetype;