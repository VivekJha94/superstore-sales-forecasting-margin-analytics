# Superstore Sales Forecasting and Margin Analytics

Retail order data analysis: where revenue and margin come from, how sales behave through the year, and a 3-month sales forecast tested against a simple baseline.

**Tools:** PostgreSQL · Power BI (DAX) · Excel (FORECAST.ETS)

## Business question

Which categories, sub-categories and regions drive revenue and margin, when does demand peak, and how well can the next 3 months of sales be forecast?

## Data

Sample Superstore retail order data: 9,994 order lines, 5,009 orders, 793 customers, Jan 2014 to Dec 2017. No nulls and no duplicates.

Cleaning: converted dates from M/D/YYYY text to real dates (checked against a known order, `CA-2016-152156` = 8 Nov 2016), renamed columns to snake_case, fixed encoding (Windows-1252 to UTF-8). Totals were checked after cleaning: sales 2,297,200.86 and profit 286,397.02.

## Method

1. **SQL (PostgreSQL):** monthly revenue and month-over-month growth (`LAG`), AOV by month, sales and margin by category and sub-category, new vs repeat customers by year, profit by region. Queries are in `sql/`.
2. **Dashboard (Power BI):** one page with KPI cards, monthly revenue by year (seasonality), margin by category, sub-category and region, and one chart of profit by discount band.
3. **Forecast (Excel):** `FORECAST.ETS` (seasonal period 12) trained on Jan 2014 to Sep 2017, tested on a 3-month holdout (Oct to Dec 2017) and compared with a flat 3-month moving average (Jul to Sep 2017). Scored with MAPE. Run for total sales and for each category.

## Dashboard

![Dashboard (images/dashboard_overview.png)

![Revenue by month and year](images/seasonality_by_year.png)

## Findings

**Overall:** revenue 2,297,200.86 · profit 286,397.02 · margin 12.47% · 5,009 orders · AOV 458.61.

| Year | Revenue |
|---|---|
| 2014 | 484,247.50 |
| 2015 | 470,532.51 |
| 2016 | 609,205.60 |
| 2017 | 733,215.26 |

- **Seasonality:** Sep to Dec brought 50-54% of each year's sales. Nov and Dec together brought 28-32%. Highest month: Nov 2017 (118,447.82).
- **Category margin:** Technology 17.40%, Office Supplies 17.04%, Furniture 2.49%.
- **Sub-category margin:** lowest are Tables (-8.56%), Bookcases (-3.02%) and Supplies (-2.55%); highest are Labels (44.42%), Paper (43.39%) and Envelopes (42.27%).
- **Region margin:** West 14.94%, East 13.48%, South 11.93%, Central 7.92%.
- **Discounts:** profit is negative for order lines discounted above 20%.
- **Customers:** new customers per year fell from 595 (2014) to 136, 51 and 11 (2015 to 2017), while repeat customers rose from 437 to 587 to 682. The first year has no repeat customers because the data starts in 2014. This is a simple new vs repeat count, not cohort analysis.

## Forecast results (3-month holdout, Oct to Dec 2017)

| Series | ETS MAPE | 3-month moving average MAPE |
|---|---|---|
| Total sales | 20.63% | 27.54% |
| Furniture | 14.55% | 34.64% |
| Office Supplies | 9.45% | 16.31% |
| Technology | 41.76% | 29.58% |

ETS beat the baseline for total sales, Furniture and Office Supplies, but not for Technology.

**Jan to Mar 2018 total sales forecast:** 43,482 (Jan), 42,568 (Feb), 70,679 (Mar), about 156,729 for the quarter. 95% ranges: [fill from the `Forecast_2018` sheet in `superstore_forecast.xlsx`].

![Forecast chart](images/forecast_chart.png)

## Recommendations

1. **Stock ahead of the Sep to Dec peak.** Those months brought half of each year's sales. The holdout model under-predicted October (about 35% low) and November (about 19% low), so plan inventory above the forecast for those months.
2. **Review pricing and discounts on Tables, Bookcases and Supplies.** All three lose money, together -22,387 profit on 16% of sales, and Furniture's overall margin is only 2.49%. Tables carry an average discount of 26% against 16% overall.
3. **Review the Central region.** Its margin (7.92%) is about half of West's (14.94%). Check product mix and discounting before expanding there.

## Limitations

- The holdout is only 3 months and includes the November peak, so MAPE is indicative, not proof of accuracy.
- ETS is basic seasonal exponential smoothing, not an advanced model. It was not reliable for Technology on this holdout.
- The February 2018 forecast (42,568) is more than double February 2017 actual sales (20,301), so treat the monthly figures as ranges.
- Four years of data gives few seasonal cycles.



Raw data: Sample Superstore dataset.
