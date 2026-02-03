# Assumptions and Limitations

- Province-level totals use the `All industries` series to avoid double counting
  across industry rollups.
- The load script filters `Statistics` to Employment; if the source naming
  differs, adjust the filter in `sql/load.sql`.
- No seasonal adjustment is applied unless it is present in the source data
  and explicitly selected.
- Employment values are interpreted with the provided `SCALAR_FACTOR` and are
  not rescaled during ingestion.
- Missing values are excluded at load time; queries defensively handle gaps
  with `NULLIF` and window function defaults.
- The included CSV extract is intentionally limited in geography, industry
  coverage, and date range to keep the repository inspectable.
- The pre/post comparison uses fixed date ranges and should be updated to match
  the available history in the extracted file.
