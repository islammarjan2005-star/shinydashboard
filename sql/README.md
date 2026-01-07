# SQL Queries for Employment Statistics

SQL queries for the ONS Labour Market Overview data on Data Workspace.

## Files

| File | Description |
|------|-------------|
| `employment_absolute.sql` | Employment count (absolute value) over time |
| `employment_rate.sql` | Employment rate (percentage) over time |
| `combined_example.sql` | Examples showing combined filters and stacked chart queries |

## Schema Assumptions

These queries assume a table structure like:

```sql
ons_labour_market.employment_data (
    time_period     DATE,
    region          VARCHAR,    -- e.g., 'Wales', 'Scotland', 'North East'
    age_group       VARCHAR,    -- e.g., '16-24', '25-34', '65+'
    sector          VARCHAR,    -- e.g., 'Hospitality', 'Manufacturing'
    employment_count NUMERIC,   -- Absolute number employed
    employment_rate  NUMERIC,   -- Percentage employed
    population      NUMERIC     -- Working-age population (for calculating rates)
)
```

**TODO**: Update table and column names once connected to actual ONS data.

## Filter Parameters

All queries support three optional filters:
- `$1` / `region_filter` - Region name or NULL for all
- `$2` / `age_filter` - Age group or NULL for all
- `$3` / `sector_filter` - Sector name or NULL for all

## R Integration

See `R/data/db_queries.R` for parameterised R functions that wrap these queries.

```r
# Example: Get 65+ employment in Hospitality in Wales
data <- get_employment_absolute(
  region_filter = "Wales",
  age_filter = "65+",
  sector_filter = "Hospitality"
)
```

## Next Steps

1. Confirm database connection details for Data Workspace
2. Verify actual table/column names in ONS dataset
3. Test queries and adjust as needed
4. Integrate with Shiny dropdown inputs
