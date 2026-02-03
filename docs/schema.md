# Schema Description

## Dimension tables

`dim_date`
- Grain: one row per month
- `date_key` is a `YYYYMM` integer used for joins
- `month_start` stores the first day of the month

`dim_province`
- One row per geography in the LFS extract (Canada and provinces)
- `is_national` flags the Canada total series

`dim_industry`
- One row per industry label in the extract
- `naics_code` and `industry_level` are reserved for future normalization

## Fact table

`fact_employment`
- Grain: monthly employment observation by province and industry
- Foreign keys to `dim_date`, `dim_province`, and `dim_industry`
- `statistic`, `uom`, `scalar_factor`, and `status` preserve source semantics
- Uniqueness enforced on `(date_key, province_id, industry_id, statistic, uom)`

## Relationship summary

- `dim_date` 1-to-many `fact_employment`
- `dim_province` 1-to-many `fact_employment`
- `dim_industry` 1-to-many `fact_employment`
