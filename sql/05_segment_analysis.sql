-- Product engagement by device.
-- Period: 2020-11-25 to 2021-01-31.
-- Metrics measure event co-occurrence within sessions, not event order.

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
    WHERE _TABLE_SUFFIX BETWEEN '20201125' AND '20210131'
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
        COUNTIF(event_name = 'view_item') > 0 AS has_view_item,
        COUNTIF(event_name = 'add_to_cart') > 0 AS has_add_to_cart,
        COUNTIF(event_name = 'purchase') > 0 AS has_purchase
    FROM events
    WHERE user_pseudo_id IS NOT NULL
      AND ga_session_id IS NOT NULL
    GROUP BY user_pseudo_id, ga_session_id
)

SELECT
    device_category,
    COUNT(*) AS total_sessions,
    COUNTIF(has_view_item) AS product_view_sessions,
    COUNTIF(has_view_item AND has_add_to_cart) AS product_view_and_cart_sessions,
    COUNTIF(has_view_item AND has_purchase) AS product_view_and_purchase_sessions,
    ROUND(
        100 * SAFE_DIVIDE(
            COUNTIF(has_view_item AND has_add_to_cart),
            COUNTIF(has_view_item)
        ), 2
    ) AS cart_rate_among_product_view_sessions_pct,
    ROUND(
        100 * SAFE_DIVIDE(
            COUNTIF(has_view_item AND has_purchase),
            COUNTIF(has_view_item)
        ), 2
    ) AS purchase_rate_among_product_view_sessions_pct
FROM sessions
GROUP BY device_category
ORDER BY total_sessions DESC;


-- Product search and purchase behavior.
-- Period: 2020-11-25 to 2021-01-31.

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
    WHERE _TABLE_SUFFIX BETWEEN '20201125' AND '20210131'
),

sessions AS (
    SELECT
        user_pseudo_id,
        ga_session_id,
        COUNTIF(event_name = 'view_search_results') > 0 AS has_search,
        COUNTIF(event_name = 'purchase') > 0 AS has_purchase
    FROM events
    WHERE user_pseudo_id IS NOT NULL AND ga_session_id IS NOT NULL
    GROUP BY user_pseudo_id, ga_session_id
)

SELECT
    IF(has_search, 'Search', 'No Search') AS search_segment,
    COUNT(*) AS total_sessions,
    COUNTIF(has_purchase) AS purchase_sessions,
    ROUND(100 * SAFE_DIVIDE(COUNTIF(has_purchase), COUNT(*)), 2) AS session_conversion_rate_pct
FROM sessions
GROUP BY has_search
ORDER BY has_search DESC;




-- Promotion engagement and purchase conversion.
-- Period: 2020-11-25 to 2021-01-31.
-- Session-level associations; no causal interpretation.

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
    WHERE _TABLE_SUFFIX BETWEEN '20201125' AND '20210131'
),

sessions AS (
    SELECT
        user_pseudo_id,
        ga_session_id,
        COUNTIF(event_name = 'view_promotion') > 0 AS has_promotion_view,
        COUNTIF(event_name = 'select_promotion') > 0 AS has_promotion_click,
        COUNTIF(event_name = 'purchase') > 0 AS has_purchase
    FROM events
    WHERE user_pseudo_id IS NOT NULL
      AND ga_session_id IS NOT NULL
    GROUP BY user_pseudo_id, ga_session_id
),

segments AS (
    SELECT
        CASE
            WHEN has_promotion_click THEN 'Promotion Click'
            WHEN has_promotion_view THEN 'Promotion View Only'
            ELSE 'No Recorded Promotion Interaction'
        END AS promotion_segment,
        has_purchase
    FROM sessions
)

SELECT
    promotion_segment,
    COUNT(*) AS total_sessions,
    COUNTIF(has_purchase) AS purchase_sessions,
    ROUND(
        100 * SAFE_DIVIDE(COUNTIF(has_purchase), COUNT(*)), 2) AS session_conversion_rate_pct
FROM segments
GROUP BY promotion_segment
ORDER BY session_conversion_rate_pct DESC;




-- First-user acquisition source availability.
-- Period: 2020-11-25 to 2021-01-31.
-- traffic_source describes first-user acquisition, not session attribution.

SELECT
    COALESCE(traffic_source.source, '(not set)') AS first_user_source,
    COALESCE(traffic_source.medium, '(not set)') AS first_user_medium,
    COUNT(*) AS session_start_events
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20201125' AND '20210131' AND event_name = 'session_start'
GROUP BY first_user_source, first_user_medium
ORDER BY session_start_events DESC
LIMIT 15;




-- Purchase conversion by first-user acquisition source.
-- Period: 2020-11-25 to 2021-01-31.
-- traffic_source represents first-user attribution, not session attribution.

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
        traffic_source.source AS source,
        traffic_source.medium AS medium
    FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
    WHERE _TABLE_SUFFIX BETWEEN '20201125' AND '20210131'
),

sessions AS (
    SELECT
        user_pseudo_id,
        ga_session_id,
        ARRAY_AGG(
            STRUCT(source, medium)
            ORDER BY event_timestamp
            LIMIT 1
        )[OFFSET(0)] AS acquisition,
        COUNTIF(event_name = 'purchase') > 0 AS has_purchase
    FROM events
    WHERE user_pseudo_id IS NOT NULL
      AND ga_session_id IS NOT NULL
    GROUP BY user_pseudo_id, ga_session_id
),

segments AS (
    SELECT
        CASE
            WHEN acquisition.source = 'google'
                 AND acquisition.medium = 'organic'
                THEN 'Google Organic'
            WHEN acquisition.source = '(direct)'
                 AND acquisition.medium = '(none)'
                THEN 'Direct'
            WHEN acquisition.source = 'google'
                 AND acquisition.medium = 'cpc'
                THEN 'Google CPC'
            ELSE 'Other / Unspecified'
        END AS acquisition_segment,
        has_purchase
    FROM sessions
)

SELECT
    acquisition_segment,
    COUNT(*) AS total_sessions,
    COUNTIF(has_purchase) AS purchase_sessions,
    ROUND(100 * SAFE_DIVIDE(COUNTIF(has_purchase), COUNT(*)), 2) AS session_conversion_rate_pct
FROM segments
GROUP BY acquisition_segment
ORDER BY total_sessions DESC;





-- First observed vs subsequent sessions.
-- Period: 2020-11-01 to 2021-01-31.
-- First observed does not necessarily mean first-ever visit.

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
        COUNTIF(event_name = 'purchase') > 0 AS has_purchase
    FROM events
    WHERE user_pseudo_id IS NOT NULL
      AND ga_session_id IS NOT NULL
    GROUP BY user_pseudo_id, ga_session_id
),

ranked_sessions AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY user_pseudo_id
            ORDER BY session_timestamp, ga_session_id
        ) AS session_number
    FROM sessions
)

SELECT
    IF(
        session_number = 1,
        'First Observed Session',
        'Subsequent Session'
    ) AS session_segment,
    COUNT(*) AS total_sessions,
    COUNTIF(has_purchase) AS purchase_sessions,
    ROUND(100 * SAFE_DIVIDE(COUNTIF(has_purchase), COUNT(*)), 2) AS session_conversion_rate_pct
FROM ranked_sessions
GROUP BY session_segment
ORDER BY session_segment;