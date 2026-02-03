# Data Notes

## Source file

The project expects a CSV extract from Statistics Canada table 14-10-0023-01
(Employment by industry and province, monthly). The repository includes a small
extract for inspection and query validation:

- `data/lfsa_14-10-0023-01_sample.csv`

The extract covers 2022-01 through 2023-09 for Canada and a subset of provinces
across a limited set of industries. A small number of values are blank and a
few rows are marked as revised to reflect typical publication conditions.

For full analysis, replace the extract with the complete CSV from Statistics
Canada and update the load command to point at the full file.

## Load command

Example `psql` load command for the local extract:

```text
\\copy stg_lfs_14_10_0023_01
  (ref_date, geo, dguid, naics, statistics, uom, uom_id, scalar_factor,
   scalar_id, vector, coordinate, value, status, symbol, terminated, decimals)
FROM 'data/lfsa_14-10-0023-01_sample.csv'
WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');
```

## Columns used

The load script ingests the standard table layout used by Statistics Canada
CSV exports. Columns referenced in the load process include:

- `REF_DATE`: Month in `YYYY-MM` format
- `GEO`: Geography name (Canada and provinces)
- `North American Industry Classification System (NAICS)`: Industry label
- `Statistics`: Measure name (filtered to Employment)
- `UOM`: Unit of measure
- `SCALAR_FACTOR`: Unit scaling (e.g., thousands)
- `VALUE`: Numeric value
- `STATUS`: Revision flag when provided
- `VECTOR`, `COORDINATE`: Series identifiers retained for traceability

Additional columns from the extract are loaded into staging for completeness,
but are not required for analysis.

## Units and scaling

Employment values are stored as provided and are not rescaled in the load
process. `SCALAR_FACTOR` should be reviewed before interpreting magnitudes.
