-- =============================================================================
-- Employment (Absolute Value) Over Time
-- Source: ONS Labour Market Overview - Data Workspace
-- =============================================================================
--
-- This query returns employment counts over time, with optional filters for:
--   - Region (e.g., 'Wales', 'Scotland', 'North East')
--   - Age group (e.g., '16-24', '25-34', '65+')
--   - Sector/Industry (e.g., 'Hospitality', 'Manufacturing')
--
-- NOTE: Adjust table and column names to match actual ONS schema once confirmed.
-- =============================================================================


-- -----------------------------------------------------------------------------
-- VERSION 1: Hard-coded filters (for initial testing)
-- -----------------------------------------------------------------------------

SELECT
    time_period,
    region,
    age_group,
    sector,
    employment_count
FROM
    ons_labour_market.employment_data
WHERE
    region = 'Wales'
    AND age_group = '65+'
    AND sector = 'Hospitality'
ORDER BY
    time_period ASC;


-- -----------------------------------------------------------------------------
-- VERSION 2: Parameterised query (for R/Shiny integration)
-- -----------------------------------------------------------------------------
-- Parameters to be passed from R:
--   @region_filter  - e.g., 'Wales' or NULL for all regions
--   @age_filter     - e.g., '65+' or NULL for all ages
--   @sector_filter  - e.g., 'Hospitality' or NULL for all sectors
-- -----------------------------------------------------------------------------

SELECT
    time_period,
    region,
    age_group,
    sector,
    employment_count
FROM
    ons_labour_market.employment_data
WHERE
    (region = $1 OR $1 IS NULL)
    AND (age_group = $2 OR $2 IS NULL)
    AND (sector = $3 OR $3 IS NULL)
ORDER BY
    time_period ASC;


-- -----------------------------------------------------------------------------
-- VERSION 3: Aggregated totals (for single-line time series)
-- -----------------------------------------------------------------------------
-- Returns total employment per time period after applying filters
-- Use this for plotting a simple line chart
-- -----------------------------------------------------------------------------

SELECT
    time_period,
    SUM(employment_count) AS total_employment
FROM
    ons_labour_market.employment_data
WHERE
    (region = $1 OR $1 IS NULL)
    AND (age_group = $2 OR $2 IS NULL)
    AND (sector = $3 OR $3 IS NULL)
GROUP BY
    time_period
ORDER BY
    time_period ASC;
