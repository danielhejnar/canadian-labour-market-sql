BEGIN;

CREATE TABLE IF NOT EXISTS dim_date (
    date_key INTEGER PRIMARY KEY,
    month_start DATE NOT NULL UNIQUE,
    year SMALLINT NOT NULL,
    month SMALLINT NOT NULL,
    CHECK (month BETWEEN 1 AND 12)
);

CREATE TABLE IF NOT EXISTS dim_province (
    province_id SERIAL PRIMARY KEY,
    province_name TEXT NOT NULL UNIQUE,
    is_national BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE IF NOT EXISTS dim_industry (
    industry_id SERIAL PRIMARY KEY,
    industry_name TEXT NOT NULL UNIQUE,
    naics_code TEXT,
    industry_level TEXT
);

CREATE TABLE IF NOT EXISTS fact_employment (
    employment_id BIGSERIAL PRIMARY KEY,
    date_key INTEGER NOT NULL REFERENCES dim_date(date_key),
    province_id INTEGER NOT NULL REFERENCES dim_province(province_id),
    industry_id INTEGER NOT NULL REFERENCES dim_industry(industry_id),
    employment NUMERIC(14,1) NOT NULL,
    statistic TEXT NOT NULL,
    uom TEXT NOT NULL,
    scalar_factor TEXT,
    vector TEXT,
    coordinate TEXT,
    status TEXT,
    data_source TEXT NOT NULL DEFAULT 'Statistics Canada LFS 14-10-0023-01',
    UNIQUE (date_key, province_id, industry_id, statistic, uom)
);

COMMIT;
