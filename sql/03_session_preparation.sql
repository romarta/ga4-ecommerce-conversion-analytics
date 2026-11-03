-- GA4 E-commerce Customer Journey & Conversion Analytics
-- Session-level data preparation.
-- Analysis period: 2020-11-25 to 2021-01-31.
-- A session is identified by user_pseudo_id and ga_session_id.

WITH events AS (
    SELECT
        user_pseudo_id,
        (SELECT ep.value.int_value
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
        TIMESTAMP_MICROS(MIN(event_timestamp)) AS session_start_time,
        ARRAY_AGG(
            device_category IGNORE NULLS
            ORDER BY event_timestamp
            LIMIT 1
        )[SAFE_OFFSET(0)] AS device_category,
        COUNT(*) AS event_count,
        COUNTIF(event_name = 'session_start') > 0 AS has_session_start,
        COUNTIF(event_name = 'view_item') > 0 AS has_view_item,
        COUNTIF(event_name = 'add_to_cart') > 0 AS has_add_to_cart,
        COUNTIF(event_name = 'begin_checkout') > 0 AS has_begin_checkout,
        COUNTIF(event_name = 'add_shipping_info') > 0 AS has_shipping_info,
        COUNTIF(event_name = 'add_payment_info') > 0 AS has_payment_info,
        COUNTIF(event_name = 'purchase') > 0 AS has_purchase
    FROM events
    WHERE user_pseudo_id IS NOT NULL AND ga_session_id IS NOT NULL
    GROUP BY user_pseudo_id, ga_session_id
)

SELECT
    device_category,
    COUNT(*) AS total_sessions,
    COUNTIF(has_session_start) AS sessions_with_session_start,
    COUNTIF(has_view_item) AS product_view_sessions,
    COUNTIF(has_add_to_cart) AS add_to_cart_sessions,
    COUNTIF(has_begin_checkout) AS checkout_sessions,
    COUNTIF(has_shipping_info) AS shipping_sessions,
    COUNTIF(has_payment_info) AS payment_sessions,
    COUNTIF(has_purchase) AS purchase_sessions
FROM sessions
GROUP BY device_category
ORDER BY total_sessions DESC;