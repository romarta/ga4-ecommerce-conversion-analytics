# E-commerce Customer Journey & Conversion Analytics

**Status: Work in Progress**

### Google BigQuery | SQL | Python | Power BI

## Project Overview

Analysis of e-commerce user behavior using Google Analytics 4 event data.

**Business goal:** Identify conversion patterns, differences between customer segments, and opportunities to improve the shopping experience.

## Dataset

- **Source:** Google Analytics 4 — Google Merchandise Store
- **BigQuery:** `bigquery-public-data.ga4_obfuscated_sample_ecommerce`
- **Period:** November 2020 – January 2021

## Analysis Scope

- **Traffic & Engagement:** Sessions, user activity, and trends.
- **Product Engagement:** Product views, cart interactions, and purchases.
- **Checkout Performance:** Checkout event coverage and purchase conversion.
- **Audience & Acquisition:** Device segments, search behavior, promotions, and traffic sources.
- **Statistics:** Evaluation of selected differences in conversion rates.

## Methodology

Analyses use session-level data extracted with BigQuery SQL.
Initial quality checks identified incomplete `add_to_cart` tracking and inconsistencies in checkout event sequences. Detailed conversion analyses therefore focus on November 25, 2020 – January 31, 2021, with event coverage distinguished from sequential conversion.

## Project Progress

**Completed:** Data exploration, quality checks, session preparation, and checkout analysis.

**Next:** Product engagement, audience analysis, statistical evaluation, and Power BI reporting.

## Data Source

[Google Analytics 4 Sample E-commerce Dataset](https://developers.google.com/analytics/bigquery/web-ecommerce-demo-dataset)