-- Q1: Employment trend by province (All industries)
SELECT
    d.month_start,
    p.province_name,
    f.employment,
    f.uom,
    f.scalar_factor
FROM fact_employment f
JOIN dim_date d
  ON d.date_key = f.date_key
JOIN dim_province p
  ON p.province_id = f.province_id
JOIN dim_industry i
  ON i.industry_id = f.industry_id
WHERE i.industry_name = 'All industries'
  AND f.statistic ILIKE 'Employment%'
ORDER BY p.province_name, d.month_start;

-- Q2: Year-over-year change by province
WITH base AS (
    SELECT
        d.month_start,
        p.province_name,
        f.employment
    FROM fact_employment f
    JOIN dim_date d
      ON d.date_key = f.date_key
    JOIN dim_province p
      ON p.province_id = f.province_id
    JOIN dim_industry i
      ON i.industry_id = f.industry_id
    WHERE i.industry_name = 'All industries'
      AND f.statistic ILIKE 'Employment%'
)
SELECT
    month_start,
    province_name,
    employment,
    employment - LAG(employment, 12) OVER (
        PARTITION BY province_name
        ORDER BY month_start
    ) AS yoy_change,
    (employment / NULLIF(LAG(employment, 12) OVER (
        PARTITION BY province_name
        ORDER BY month_start
    ), 0) - 1.0) * 100.0 AS yoy_change_pct
FROM base
ORDER BY province_name, month_start;

-- Q3: Industry volatility by province (std dev of month-over-month % change)
WITH base AS (
    SELECT
        d.month_start,
        p.province_name,
        i.industry_name,
        f.employment
    FROM fact_employment f
    JOIN dim_date d
      ON d.date_key = f.date_key
    JOIN dim_province p
      ON p.province_id = f.province_id
    JOIN dim_industry i
      ON i.industry_id = f.industry_id
    WHERE i.industry_name <> 'All industries'
      AND f.statistic ILIKE 'Employment%'
), changes AS (
    SELECT
        month_start,
        province_name,
        industry_name,
        (employment - LAG(employment) OVER (
            PARTITION BY province_name, industry_name
            ORDER BY month_start
        )) / NULLIF(LAG(employment) OVER (
            PARTITION BY province_name, industry_name
            ORDER BY month_start
        ), 0) AS mom_change_pct
    FROM base
)
SELECT
    province_name,
    industry_name,
    STDDEV_SAMP(mom_change_pct) AS volatility_mom_pct
FROM changes
WHERE mom_change_pct IS NOT NULL
GROUP BY province_name, industry_name
ORDER BY volatility_mom_pct DESC, province_name, industry_name;

-- Q4: Rolling 12-month average by province (All industries)
WITH base AS (
    SELECT
        d.month_start,
        p.province_name,
        f.employment
    FROM fact_employment f
    JOIN dim_date d
      ON d.date_key = f.date_key
    JOIN dim_province p
      ON p.province_id = f.province_id
    JOIN dim_industry i
      ON i.industry_id = f.industry_id
    WHERE i.industry_name = 'All industries'
      AND f.statistic ILIKE 'Employment%'
)
SELECT
    month_start,
    province_name,
    AVG(employment) OVER (
        PARTITION BY province_name
        ORDER BY month_start
        ROWS BETWEEN 11 PRECEDING AND CURRENT ROW
    ) AS employment_12m_avg
FROM base
ORDER BY province_name, month_start;

-- Q5: Provincial share of national employment
WITH province_totals AS (
    SELECT
        d.month_start,
        p.province_name,
        f.employment
    FROM fact_employment f
    JOIN dim_date d
      ON d.date_key = f.date_key
    JOIN dim_province p
      ON p.province_id = f.province_id
    JOIN dim_industry i
      ON i.industry_id = f.industry_id
    WHERE i.industry_name = 'All industries'
      AND f.statistic ILIKE 'Employment%'
      AND p.province_name <> 'Canada'
), national_totals AS (
    SELECT
        d.month_start,
        f.employment AS national_employment
    FROM fact_employment f
    JOIN dim_date d
      ON d.date_key = f.date_key
    JOIN dim_province p
      ON p.province_id = f.province_id
    JOIN dim_industry i
      ON i.industry_id = f.industry_id
    WHERE i.industry_name = 'All industries'
      AND f.statistic ILIKE 'Employment%'
      AND p.province_name = 'Canada'
)
SELECT
    p.month_start,
    p.province_name,
    p.employment,
    n.national_employment,
    p.employment / NULLIF(n.national_employment, 0) AS provincial_share
FROM province_totals p
JOIN national_totals n
  ON n.month_start = p.month_start
ORDER BY p.province_name, p.month_start;

-- Q6: Pre vs post period comparison (explicit periods)
WITH periods AS (
    SELECT 'pre' AS period, DATE '2017-01-01' AS start_date, DATE '2019-12-01' AS end_date
    UNION ALL
    SELECT 'post' AS period, DATE '2022-01-01' AS start_date, DATE '2024-12-01' AS end_date
), base AS (
    SELECT
        d.month_start,
        p.province_name,
        f.employment
    FROM fact_employment f
    JOIN dim_date d
      ON d.date_key = f.date_key
    JOIN dim_province p
      ON p.province_id = f.province_id
    JOIN dim_industry i
      ON i.industry_id = f.industry_id
    WHERE i.industry_name = 'All industries'
      AND f.statistic ILIKE 'Employment%'
      AND p.province_name <> 'Canada'
)
SELECT
    b.province_name,
    per.period,
    AVG(b.employment) AS avg_employment
FROM base b
JOIN periods per
  ON b.month_start BETWEEN per.start_date AND per.end_date
GROUP BY b.province_name, per.period
ORDER BY b.province_name, per.period;
