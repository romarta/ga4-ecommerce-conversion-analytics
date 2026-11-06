# E-commerce Customer Journey & Conversion Analytics

**Status: In Progress — 2 of 3 Power BI Report Pages Completed**

### Google BigQuery | SQL | Python | Power BI | Statistical Analysis

## Project Overview

End-to-end analysis of e-commerce customer behavior using Google Analytics 4 event data from the Google Merchandise Store.

**Business goal:** Identify conversion patterns, evaluate differences between customer segments, and uncover opportunities to improve the shopping experience.

The project combines SQL-based data preparation, statistical analysis in Python, and interactive reporting in Power BI.

## Dataset

- **Source:** Google Analytics 4 — Google Merchandise Store
- **BigQuery:** `bigquery-public-data.ga4_obfuscated_sample_ecommerce`
- **Full analysis period:** 01 Nov 2020 – 31 Jan 2021 (92 days)
- **Checkout and purchase-path analysis:** 25 Nov 2020 – 31 Jan 2021 (68 days)

The shorter reporting period addresses identified inconsistencies in the recording of selected e-commerce events.

## Analysis Scope

- **Traffic & Engagement:** Session volume, user activity, and temporal trends.
- **Product Engagement:** Product views, cart interactions, and recorded purchase events.
- **Checkout Performance:** Checkout event coverage and purchase-session co-occurrence.
- **Customer Journey:** Observed purchase paths and tracking quality diagnostics.
- **Audience & Acquisition:** Device segments, search behavior, promotional interactions, and traffic sources.
- **Statistics:** Evaluation of selected differences in session conversion rates.

## Key Findings

- **360,129 sessions** and **4,848 purchase sessions** were recorded during the full 92-day period, corresponding to a **1.35% session conversion rate**.
- Sessions with on-site search had a higher observed conversion rate than sessions without search (**4.14% vs. 1.22%**). This is an association, not evidence of a causal effect.
- Device-level conversion differences were not statistically significant in the overall analysis (**p = 0.166**).
- During the 68-day checkout analysis period, **25.59% of purchase sessions** had no recorded `add_to_cart` event in the same session.
- **62.31% of purchase sessions** contained an observed, correctly ordered checkout event sequence.

Detailed statistical findings and business implications are documented in [Business Insights](reports/business_insights.md).

## Power BI Dashboard

The interactive dashboard uses a shared dimensional model, reusable DAX measures, and a Google Analytics-inspired visual theme.

### 1. Executive Overview — Completed

Provides a high-level view of website traffic and conversion performance.

**Features:**
- Sessions, purchase sessions, and conversion KPIs.
- Daily and weekly performance trends.
- Day-of-week and hour-of-day conversion heatmap.
- Period-over-period conversion comparisons.
- Weekly performance scorecard.
- Interactive date filtering and custom tooltips.

### 2. Customer Journey — Completed

Examines recorded e-commerce events, checkout behavior, and observed purchase paths.

**Features:**
- Event coverage and checkout KPIs.
- Device-level checkout comparisons.
- Event coverage heatmap by device.
- Tracking quality diagnostics.
- Weekly purchase-path composition analysis.
- Custom purchase-path tooltip.
- Interactive filters and bookmark-controlled methodology panel.

### 3. Conversion Drivers — In Progress

Planned analysis of conversion patterns associated with on-site search, promotional engagement, returning users, and other customer characteristics, supported by statistical evidence.

## Methodology

The analysis reconstructs sessions from GA4 event-level data and applies statistical methods to evaluate selected conversion differences.

**Event coverage is not treated as a sequential conversion funnel.** Recorded events may be missing or span multiple sessions, so checkout and purchase-path metrics require careful interpretation.

See [Analytical Methodology](docs/methodology.md) for KPI definitions, session reconstruction rules, reporting periods, and data limitations.

## Repository Structure

| Directory / File | Contents |
|---|---|
| `sql/` | BigQuery exploration, session reconstruction, statistical exports, and Power BI reporting tables |
| `notebooks/` | Python statistical analysis and visualizations |
| `powerbi/` | Power BI report |
| `docs/methodology.md` | Analytical methodology and limitations |
| `reports/business_insights.md` | Statistical findings and business implications |
| `requirements.txt` | Python dependencies |

## Project Progress

**Completed:**
- SQL exploration and GA4 session reconstruction.
- Data quality checks and reporting-period validation.
- Statistical analysis in Python.
- BigQuery reporting tables.
- Power BI Executive Overview.
- Power BI Customer Journey.

**Next steps:**
- Complete the Power BI Conversion Drivers page.
- Finalize dashboard screenshots and documentation.
- Consolidate business recommendations.

## Data Source

[Google Analytics 4 Sample E-commerce Dataset](https://developers.google.com/analytics/bigquery/web-ecommerce-demo-dataset)