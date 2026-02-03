BEGIN;

CREATE TEMP TABLE stg_lfs_14_10_0023_01 (
    ref_date TEXT,
    geo TEXT,
    dguid TEXT,
    naics TEXT,
    statistics TEXT,
    uom TEXT,
    uom_id INTEGER,
    scalar_factor TEXT,
    scalar_id INTEGER,
    vector TEXT,
    coordinate TEXT,
    value TEXT,
    status TEXT,
    symbol TEXT,
    terminated TEXT,
    decimals INTEGER
);

-- Example load command (psql):
-- \copy stg_lfs_14_10_0023_01
--   (ref_date, geo, dguid, naics, statistics, uom, uom_id, scalar_factor,
--    scalar_id, vector, coordinate, value, status, symbol, terminated, decimals)
-- FROM 'data/lfsa_14-10-0023-01.csv'
-- WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');

INSERT INTO dim_date (date_key, month_start, year, month)
SELECT DISTINCT
    (EXTRACT(YEAR FROM month_start)::INT * 100 + EXTRACT(MONTH FROM month_start)::INT) AS date_key,
    month_start,
    EXTRACT(YEAR FROM month_start)::INT AS year,
    EXTRACT(MONTH FROM month_start)::INT AS month
FROM (
    SELECT to_date(ref_date, 'YYYY-MM') AS month_start
    FROM stg_lfs_14_10_0023_01
    WHERE ref_date ~ '^[0-9]{4}-[0-9]{2}$'
) s
ON CONFLICT (date_key) DO NOTHING;

INSERT INTO dim_province (province_name, is_national)
SELECT DISTINCT
    geo AS province_name,
    (geo = 'Canada') AS is_national
FROM stg_lfs_14_10_0023_01
WHERE geo IS NOT NULL
  AND geo <> ''
ON CONFLICT (province_name) DO NOTHING;

INSERT INTO dim_industry (industry_name)
SELECT DISTINCT
    naics AS industry_name
FROM stg_lfs_14_10_0023_01
WHERE naics IS NOT NULL
  AND naics <> ''
ON CONFLICT (industry_name) DO NOTHING;

INSERT INTO fact_employment (
    date_key,
    province_id,
    industry_id,
    employment,
    statistic,
    uom,
    scalar_factor,
    vector,
    coordinate,
    status
)
SELECT
    dd.date_key,
    dp.province_id,
    di.industry_id,
    NULLIF(s.value, '')::NUMERIC(14,1) AS employment,
    s.statistics AS statistic,
    s.uom AS uom,
    s.scalar_factor,
    s.vector,
    s.coordinate,
    s.status
FROM stg_lfs_14_10_0023_01 s
JOIN dim_date dd
  ON dd.month_start = to_date(s.ref_date, 'YYYY-MM')
JOIN dim_province dp
  ON dp.province_name = s.geo
JOIN dim_industry di
  ON di.industry_name = s.naics
WHERE s.value IS NOT NULL
  AND s.value <> ''
  AND s.statistics ILIKE 'Employment%'
  AND s.uom IS NOT NULL
ON CONFLICT (date_key, province_id, industry_id, statistic, uom) DO NOTHING;

COMMIT;
