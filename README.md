# Canadian Labour Market Analysis — SQL

## Overview

This project uses SQL to analyze Canadian labour market data sourced from
Statistics Canada’s Labour Force Survey.

The purpose of the project is to demonstrate how SQL is used directly for
analytical work: schema design, data normalization, and non-trivial querying
to answer concrete questions.

This repository reflects an internal-style analytical workflow that was later
prepared for public review.

## Data Source

Primary data source:

- Statistics Canada — Labour Force Survey
- Table: 14-10-0023-01
- Description: Employment by industry and province, monthly
- Frequency: Monthly
- Geography: Canada and provinces

The dataset was selected because it is authoritative, versioned, and
representative of real analytical data used in practice.

Source documentation is referenced directly from Statistics Canada.

## Analytical Scope

This analysis focuses on a small number of questions:

- How employment levels change over time by province
- How industries differ in volatility and recovery patterns
- How year-over-year trends vary across regions
- How seasonality affects interpretation of monthly changes

The goal is depth and interpretability rather than exhaustive coverage.

## Data Modeling Approach

The data is modeled using a simple relational structure:

- A fact table containing monthly employment observations
- Dimension tables for:
  - Date
  - Province / geography
  - Industry classification

This structure supports:
- Time-series analysis
- Cross-regional comparison
- Industry-level aggregation

Constraints and keys are used where appropriate to enforce consistency.

## SQL Dialect

Queries are written using PostgreSQL-compatible SQL.

The focus is on:
- Readability
- Analytical intent
- Portability to other analytical databases

No ORM or application layer is included.

## Repository Structure

- `data/`
  - Raw CSV source files
- `sql/`
  - `schema.sql` — table definitions
  - `load.sql` — data loading assumptions
  - `analysis_queries.sql` — analytical queries
- `outputs/`
  - Query results (CSV or Markdown)
  - Ontario-scoped samples and full national outputs are stored separately
- `docs/`
  - Data notes
  - Assumptions and limitations
  - Schema documentation
- `CHANGELOG.md`
  - Incremental development history

Each file exists to support a specific analytical purpose.

Outputs are intentionally split between Ontario-scoped samples and all-province
results to keep inspection-ready extracts separate from full runs.

## Assumptions and Limitations

- Employment figures are subject to revision by Statistics Canada
- No seasonal adjustment is applied unless explicitly stated
- Results should be interpreted in the context of survey methodology

This analysis does not attempt to infer causality.

## Status

This project reflects an iterative analytical workflow.

Queries and schema evolved as questions were clarified and assumptions reviewed.
See `CHANGELOG.md` for version history.
