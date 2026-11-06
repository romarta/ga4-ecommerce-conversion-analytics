# Business Insights & Recommendations

## Key Findings

### Product Search

Sessions with product search converted at **4.14%**, compared with **1.22%** for sessions without search. The difference was statistically significant (+2.92 pp; 95% CI: 2.60–3.24 pp; p < 0.001).
Search activity is a strong indicator of purchase intent, although the relationship is not necessarily causal.

### Promotion Engagement

Conversion rates differed significantly across promotion engagement segments (Wald test, p < 0.001):

- Promotion Click: **3.77%**
- Promotion View Only: **3.45%**
- No Recorded Promotion Interaction: **0.26%**

The Click vs. View Only difference was not statistically significant (+0.32 pp; 95% CI: −0.16–0.80 pp; p = 0.192).

### Visit Behavior

First observed sessions converted at **0.77%**, compared with **3.07%** for subsequent sessions (+2.29 pp; 95% CI: 2.17–2.41 pp; p < 0.001).
Conversion increased from 0.77% on the first observed session to 4.33% on the fourth. Later session numbers represent progressively smaller, selected groups.

### Device Performance

Conversion rates were similar across desktop (**1.32%**), mobile (**1.39%**), and tablet (**1.30%**). The overall difference was not statistically significant (Wald test, p = 0.166).

### Temporal Conversion Patterns

Conversion rates differed significantly across weekdays (Wald χ² = 93.05; p < 0.001).
**Friday** had the highest observed conversion rate (**1.61%**), while **Sunday** had the lowest (**0.95%**). Their exploratory difference was +0.66 pp (95% CI: 0.51–0.80 pp; p < 0.001), without adjustment for multiple comparisons.
The weekday-hour heatmap revealed additional descriptive patterns:

- **Monday:** Higher conversion during late afternoon and evening (15:00–23:00 UTC).
- **Tuesday:** Local peaks in the afternoon and early evening.
- **Friday:** Relatively strong conversion across much of the day, particularly in the afternoon and evening.
- **Sunday:** Generally weaker conversion, especially during morning hours.

These hourly patterns should not guide campaign scheduling without further validation. Hourly session counts were unusually uniform, raising concerns about the reliability of time-of-day behavior in the sample.

### Checkout Tracking

During the tracking-sensitive analysis period (November 25, 2020 – January 31, 2021), **7,660 sessions** recorded `begin_checkout`, of which **3,711** also recorded a purchase (**48.45%**).
Of 3,712 purchase sessions, 2,313 (62.31%) contained the ordered checkout-to-purchase sequence, while only 1,707 (45.99%) contained the full ordered journey from product view to purchase. Another 1,398 sessions (37.66%) recorded checkout activity without the complete ordered checkout sequence. Additionally, 950 purchase sessions (25.59%) had no recorded add_to_cart event in the same session. These findings highlight limitations in observed event sequences and prevent reliable funnel abandonment estimates.

### Traffic and Acquisition

Traffic and conversion varied substantially across weeks. The week of December 7, 2020 recorded **38,729 sessions** and a **1.99%** conversion rate, while the week of January 4, 2021 had a **0.56%** conversion rate.
Approximately **41%** of sessions fell into the Other/Unspecified first-user acquisition category, limiting channel-level interpretation.

## Business Recommendations

1. **Optimize product discovery.** Investigate search usability and product relevance, then evaluate improvements through controlled experiments.
2. **Improve measurement quality.** Audit missing cart and checkout events before using funnel metrics to identify abandonment.
3. **Support returning visitors.** Improve product rediscovery and continuity across visits; test whether these changes increase purchases.
4. **Prioritize validated opportunities.** Avoid reallocating budgets based solely on device, hourly, or acquisition patterns that lack strong supporting evidence.

## Limitations

The analysis uses an anonymized GA4 sample covering November 1, 2020 – January 31, 2021. Tracking-sensitive checkout and promotion analyses use November 25, 2020 – January 31, 2021.
All reported relationships are observational and do not establish causality. See [Methodology](../docs/methodology.md) for statistical methods and data-quality considerations.