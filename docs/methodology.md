# Analytical Methodology

## Data and Analysis Period

**Source:** Google Analytics 4 public e-commerce sample dataset (`bigquery-public-data.ga4_obfuscated_sample_ecommerce`).

- **November 1, 2020 – January 31, 2021:** Traffic trends and first-observed versus subsequent session analysis.
- **November 25, 2020 – January 31, 2021:** Product engagement, checkout analysis, and acquisition and behavioral segments.

The shorter period excludes dates with incomplete `add_to_cart` event coverage.

## Session Definition and KPIs

A session is identified by the combination of `user_pseudo_id` and `ga_session_id`. Events are aggregated at session level, and device category is taken from the earliest event with a recorded device.

| Metric | Definition |
|---|---|
| Total Sessions | Distinct combinations of user and session identifiers |
| Purchase Sessions | Sessions containing at least one `purchase` event |
| Session Conversion Rate | Purchase Sessions / Total Sessions |
| Checkout Purchase Rate | Sessions containing both `begin_checkout` and `purchase` / Sessions containing `begin_checkout` |
| Product View Cart Rate | Sessions containing both `view_item` and `add_to_cart` / Sessions containing `view_item` |
| Product View Purchase Rate | Sessions containing both `view_item` and `purchase` / Sessions containing `view_item` |

Rates are calculated at session level, not from raw event counts.

## Checkout Methodology

Initial checks found inconsistencies in event sequences. Of 3,712 purchase sessions in the shorter analysis period, only 2,313 contained the complete four-stage checkout sequence in the required order.

Checkout reporting therefore measures **event coverage within sessions**, without enforcing chronological order.

These metrics describe recorded behavior and must not be interpreted as confirmed funnel progression or customer abandonment.

## Data Quality and Limitations

- User and session identifiers were complete in the analyzed dataset.
- `add_to_cart` was absent on 18 days in November 2020, despite recorded checkouts and purchases.
- In the shorter period, 950 of 3,712 purchase sessions had no recorded `add_to_cart` event.
- Acquisition segments use **first-user source and medium**, not session-level attribution. Anonymized values limit channel comparisons.
- First-observed versus subsequent sessions are defined within the available 92-day window; first-observed does not necessarily mean first-ever.
- Search and promotion analyses measure associations, not causal effects.

The dataset is a public, obfuscated sample. Findings should be interpreted as exploratory rather than representative of current store performance.

## Python Statistical Analysis

Session-level data is retrieved directly from BigQuery using `google-cloud-bigquery` and local Application Default Credentials (ADC).

- **Source query:** `sql/06_statistical_export.sql`
- **Notebook:** `notebooks/conversion_statistics.ipynb`
- **Analysis period:** November 1, 2020 – January 31, 2021
- **Dataset:** 360,129 unique sessions, including 4,848 purchase sessions
- **Validation:** No missing values or duplicate session identifiers

The dataset includes desktop, mobile, and tablet sessions. User identifiers are retained in memory to account for repeated sessions during statistical analysis.
Raw session-level data and authentication credentials are not stored in the repository.