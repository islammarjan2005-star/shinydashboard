-- =============================================================================
-- Combined Filter Example: 65+ in Hospitality in Wales
-- Source: ONS Labour Market Overview - Data Workspace
-- =============================================================================
--
-- This demonstrates the full filtering capability requested:
-- "Show the total number of employed 65+ year olds in the hospitality sector in Wales"
--
-- =============================================================================


-- -----------------------------------------------------------------------------
-- Employment Count: 65+ in Hospitality in Wales
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
-- Employment Rate: 65+ in Hospitality in Wales
-- -----------------------------------------------------------------------------

SELECT
    time_period,
    region,
    age_group,
    sector,
    employment_rate
FROM
    ons_labour_market.employment_data
WHERE
    region = 'Wales'
    AND age_group = '65+'
    AND sector = 'Hospitality'
ORDER BY
    time_period ASC;


-- -----------------------------------------------------------------------------
-- For Stacked Area Chart: Employment by Region Over Time
-- -----------------------------------------------------------------------------
-- Use this to create a stacked chart showing regional breakdown
-- The top line shows UK total, segments show regional contributions

SELECT
    time_period,
    region,
    SUM(employment_count) AS employment_count
FROM
    ons_labour_market.employment_data
WHERE
    (age_group = $1 OR $1 IS NULL)
    AND (sector = $2 OR $2 IS NULL)
GROUP BY
    time_period, region
ORDER BY
    time_period ASC, region ASC;


-- -----------------------------------------------------------------------------
-- For Stacked Area Chart: Employment by Age Group Over Time
-- -----------------------------------------------------------------------------

SELECT
    time_period,
    age_group,
    SUM(employment_count) AS employment_count
FROM
    ons_labour_market.employment_data
WHERE
    (region = $1 OR $1 IS NULL)
    AND (sector = $2 OR $2 IS NULL)
GROUP BY
    time_period, age_group
ORDER BY
    time_period ASC, age_group ASC;


-- -----------------------------------------------------------------------------
-- For Stacked Area Chart: Employment by Sector Over Time
-- -----------------------------------------------------------------------------

SELECT
    time_period,
    sector,
    SUM(employment_count) AS employment_count
FROM
    ons_labour_market.employment_data
WHERE
    (region = $1 OR $1 IS NULL)
    AND (age_group = $2 OR $2 IS NULL)
GROUP BY
    time_period, sector
ORDER BY
    time_period ASC, sector ASC;
