-- GA4 E-commerce Customer Journey & Conversion Analytics
-- Session-based checkout analysis.
-- Analysis period: 2020-11-25 to 2021-01-31.
--
-- Stages are based on event presence within the same session.
-- Event order is not enforced due to observed sequence inconsistencies.
-- Stage coverage must not be interpreted as confirmed user drop-off.

WITH events AS (
    SELECT
        user_pseudo_id,
        (
            SELECT ep.value.int_value
            FROM UNNEST(event_params) AS ep
            WHERE ep.key = 'ga_session_id'
            LIMIT 1
        ) AS ga_session_id,
        device.category AS device_category,
        event_name,
        event_timestamp
    FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
    WHERE
        _TABLE_SUFFIX BETWEEN '20201125' AND '20210131'
        AND event_name IN (
            'begin_checkout',
            'add_shipping_info',
            'add_payment_info',
            'purchase'
        )
),

sessions AS (
    SELECT
        user_pseudo_id,
        ga_session_id,
        ARRAY_AGG(
            device_category IGNORE NULLS
            ORDER BY event_timestamp
            LIMIT 1
        )[SAFE_OFFSET(0)] AS device_category,
        COUNTIF(event_name = 'begin_checkout') > 0 AS has_checkout,
        COUNTIF(event_name = 'add_shipping_info') > 0 AS has_shipping,
        COUNTIF(event_name = 'add_payment_info') > 0 AS has_payment,
        COUNTIF(event_name = 'purchase') > 0 AS has_purchase
    FROM events
    WHERE user_pseudo_id IS NOT NULL AND ga_session_id IS NOT NULL
    GROUP BY user_pseudo_id, ga_session_id
)

SELECT
    device_category,
    COUNTIF(has_checkout) AS checkout_sessions,
    COUNTIF(has_checkout AND has_shipping) AS shipping_recorded_sessions,
    COUNTIF(has_checkout AND has_shipping AND has_payment) AS payment_recorded_sessions,
    COUNTIF(has_checkout AND has_shipping AND has_payment AND has_purchase) AS purchase_with_all_checkout_events,
    COUNTIF(has_checkout AND has_purchase) AS checkout_purchase_sessions,
    ROUND(100 * SAFE_DIVIDE(COUNTIF(has_checkout AND has_purchase), COUNTIF(has_checkout)), 2) AS checkout_purchase_rate_pct
FROM sessions
GROUP BY device_category
ORDER BY checkout_sessions DESC;