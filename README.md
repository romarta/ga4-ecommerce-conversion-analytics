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

Analysis is based on session-level GA4 data. Checkout metrics measure event coverage rather than strict sequential progression due to identified tracking limitations.
See [Analytical Methodology](docs/methodology.md) for KPI definitions, analysis periods, and data limitations.

## Project Progress

**Completed:** SQL exploration and behavioral analysis, data quality checks, methodology documentation, Python environment setup, BigQuery integration, session data validation, and Statistical testing.

**Next:** Power BI dashboard, and business recommendations.

## Data Source

[Google Analytics 4 Sample E-commerce Dataset](https://developers.google.com/analytics/bigquery/web-ecommerce-demo-dataset)