-- GA4 E-commerce Customer Journey & Conversion Analytics
-- Data quality: user and session identifier completeness.
-- Analysis period: 2020-11-01 to 2021-01-31.
-- Session Identifier Completeness

WITH event_sessions AS (
    SELECT
        CASE
            WHEN _TABLE_SUFFIX < '20201125'
                THEN '2020-11-01 to 2020-11-24'
            ELSE '2020-11-25 to 2021-01-31'
        END AS analysis_period,
        user_pseudo_id,
        (SELECT ep.value.int_value
            FROM UNNEST(event_params) AS ep
            WHERE ep.key = 'ga_session_id'
            LIMIT 1
        ) AS ga_session_id
    FROM
        `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
    WHERE
        _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
)

SELECT
    analysis_period,
    COUNT(*) AS total_events,
    COUNTIF(user_pseudo_id IS NULL) AS missing_user_ids,
    COUNTIF(ga_session_id IS NULL) AS missing_session_ids,
    COUNTIF(
        user_pseudo_id IS NULL
        OR ga_session_id IS NULL
    ) AS events_without_session_key,
    ROUND(
        100 * SAFE_DIVIDE(
            COUNTIF(
                user_pseudo_id IS NULL
                OR ga_session_id IS NULL
            ),
            COUNT(*)
        ),
        2
    ) AS missing_session_key_pct
FROM event_sessions
GROUP BY analysis_period
ORDER BY analysis_period;



-- Data quality: purchase funnel event coverage by period.
-- The initial period contains 18 days without add_to_cart events.
-- Funnel analysis will focus on 2020-11-25 to 2021-01-31.
-- Funnel Event Coverage

SELECT
    CASE
        WHEN event_date < '20201125'
            THEN '2020-11-01 to 2020-11-24'
        ELSE '2020-11-25 to 2021-01-31'
    END AS analysis_period,
    COUNT(DISTINCT event_date) AS total_days,
    COUNT(DISTINCT IF(
        event_name = 'add_to_cart',
        event_date,
        NULL
    )) AS days_with_add_to_cart,
    COUNTIF(event_name = 'view_item') AS view_item_events,
    COUNTIF(event_name = 'add_to_cart') AS add_to_cart_events,
    COUNTIF(event_name = 'begin_checkout') AS begin_checkout_events,
    COUNTIF(event_name = 'purchase') AS purchase_events
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
GROUP BY analysis_period
ORDER BY analysis_period;



-- Data quality: event coverage in purchasing sessions.
-- Analysis period: 2020-11-25 to 2021-01-31.
-- Missing-stage counts may overlap across sessions.

WITH session_events AS (
    SELECT
        user_pseudo_id,
        (
            SELECT ep.value.int_value
            FROM UNNEST(event_params) AS ep
            WHERE ep.key = 'ga_session_id'
            LIMIT 1
        ) AS ga_session_id,
        event_name
    FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`

    WHERE
        _TABLE_SUFFIX BETWEEN '20201125' AND '20210131'
        AND event_name IN (
            'view_item',
            'add_to_cart',
            'begin_checkout',
            'add_shipping_info',
            'add_payment_info',
            'purchase'
        )
),

session_flags AS (
    SELECT
        user_pseudo_id,
        ga_session_id,
        COUNTIF(event_name = 'view_item') > 0 AS has_view_item,
        COUNTIF(event_name = 'add_to_cart') > 0 AS has_add_to_cart,
        COUNTIF(event_name = 'begin_checkout') > 0 AS has_checkout,
        COUNTIF(event_name = 'add_shipping_info') > 0 AS has_shipping,
        COUNTIF(event_name = 'add_payment_info') > 0 AS has_payment,
        COUNTIF(event_name = 'purchase') > 0 AS has_purchase
    FROM session_events
    WHERE user_pseudo_id IS NOT NULL AND ga_session_id IS NOT NULL
    GROUP BY user_pseudo_id, ga_session_id
)

SELECT
    COUNT(*) AS purchase_sessions,
    COUNTIF(NOT has_view_item) AS missing_view_item,
    COUNTIF(NOT has_add_to_cart) AS missing_add_to_cart,
    COUNTIF(NOT has_checkout) AS missing_checkout,
    COUNTIF(NOT has_shipping) AS missing_shipping,
    COUNTIF(NOT has_payment) AS missing_payment
FROM session_flags
WHERE has_purchase;


-- Data quality: completeness of purchase funnel stages.
-- Checks event presence regardless of event order.
-- Analysis period: 2020-11-25 to 2021-01-31.

WITH events AS (
    SELECT
        user_pseudo_id,
        (
            SELECT ep.value.int_value
            FROM UNNEST(event_params) AS ep
            WHERE ep.key = 'ga_session_id'
            LIMIT 1
        ) AS ga_session_id,
        event_name
    FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
    WHERE
        _TABLE_SUFFIX BETWEEN '20201125' AND '20210131'
        AND event_name IN (
            'view_item',
            'add_to_cart',
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
        COUNT(DISTINCT event_name) AS recorded_funnel_stages,
        COUNTIF(event_name = 'purchase') > 0 AS has_purchase
    FROM events
    WHERE user_pseudo_id IS NOT NULL  AND ga_session_id IS NOT NULL
    GROUP BY user_pseudo_id, ga_session_id
)

SELECT
    COUNTIF(has_purchase) AS purchase_sessions,
    COUNTIF(
        has_purchase
        AND recorded_funnel_stages = 6
    ) AS purchase_sessions_with_all_six_events
FROM sessions;



-- Data quality: sequential checkout event coverage.
-- Analysis period: 2020-11-25 to 2021-01-31.
-- Each stage must follow the previous stage within the same session.

WITH events AS (
    SELECT
        user_pseudo_id,
        (
            SELECT ep.value.int_value
            FROM UNNEST(event_params) AS ep
            WHERE ep.key = 'ga_session_id'
            LIMIT 1
        ) AS ga_session_id,
        event_name,
        event_timestamp
    FROM
        `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
    WHERE
        _TABLE_SUFFIX BETWEEN '20201125' AND '20210131'
        AND event_name IN (
            'begin_checkout',
            'add_shipping_info',
            'add_payment_info',
            'purchase'
        )
),

session_events AS (
    SELECT
        user_pseudo_id,
        ga_session_id,
        ARRAY_AGG(
            STRUCT(event_name, event_timestamp)
            ORDER BY event_timestamp
        ) AS journey
    FROM events
    WHERE
        user_pseudo_id IS NOT NULL
        AND ga_session_id IS NOT NULL
    GROUP BY
        user_pseudo_id,
        ga_session_id
),

stage_1 AS (
    SELECT
        *,
        (
            SELECT MIN(e.event_timestamp)
            FROM UNNEST(journey) AS e
            WHERE e.event_name = 'begin_checkout'
        ) AS t1
    FROM session_events
),

stage_2 AS (
    SELECT
        *,
        (
            SELECT MIN(e.event_timestamp)
            FROM UNNEST(journey) AS e
            WHERE e.event_name = 'add_shipping_info'
              AND e.event_timestamp >= t1
        ) AS t2
    FROM stage_1
),

stage_3 AS (
    SELECT
        *,
        (
            SELECT MIN(e.event_timestamp)
            FROM UNNEST(journey) AS e
            WHERE e.event_name = 'add_payment_info'
              AND e.event_timestamp >= t2
        ) AS t3
    FROM stage_2
),

stage_4 AS (
    SELECT
        *,
        (
            SELECT MIN(e.event_timestamp)
            FROM UNNEST(journey) AS e
            WHERE e.event_name = 'purchase'
              AND e.event_timestamp >= t3
        ) AS t4
    FROM stage_3
)

SELECT
    COUNTIF(t1 IS NOT NULL) AS checkout_sessions,
    COUNTIF(t2 IS NOT NULL) AS shipping_sessions,
    COUNTIF(t3 IS NOT NULL) AS payment_sessions,
    COUNTIF(t4 IS NOT NULL) AS completed_checkout_sessions
FROM stage_4;