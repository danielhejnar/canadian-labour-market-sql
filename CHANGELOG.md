# Changelog

## 2026-02-03
- Refreshed the included extract with a broader province/industry slice and
  retained blank values and revision flags.
- Added a `psql` load example and clarified extract scope in data notes.
- Captured revision `status` in the fact table during load.
- Regenerated sample outputs to align with the updated extract.

## 2026-01-30
- Documented assumptions around `All industries` totals and scaling factors.
- Added explicit pre/post period comparison query with fixed date ranges.
- Deferred seasonally adjusted comparisons pending confirmation of available series.

## 2026-01-22
- Refined year-over-year calculation to return both absolute and percent change.
- Added defensive handling for zero or missing denominators in window metrics.
- Adjusted national share query to rely on the Canada total series rather than summing provinces.

## 2026-01-10
- Added rolling 12-month average query for provincial trend smoothing.
- Implemented industry volatility calculation based on month-over-month changes.

## 2025-12-15
- Introduced staging table for CSV ingestion and `COPY`-based load flow.
- Added traceability columns (`vector`, `coordinate`, `scalar_factor`) to the fact table.

## 2025-12-02
- Drafted initial schema with date, province, and industry dimensions.
- Added constraints and uniqueness rules to prevent duplicate observations.

## 2025-11-18
- Established repository layout and initial data notes.
- Logged open questions on seasonal adjustment and NAICS normalization.
