# =============================================================================
# Database Query Functions for Employment Statistics
# =============================================================================
#
# These functions execute parameterised SQL queries against the ONS Labour
# Market Overview data on Data Workspace.
#
# Usage in Shiny:
#   - Connect filter dropdowns to these functions
#   - Pass NULL to include all values for a filter
#
# =============================================================================

library(DBI)
library(RPostgres)

# -----------------------------------------------------------------------------
# Database Connection
# -----------------------------------------------------------------------------
# TODO: Update connection details for Data Workspace PostgreSQL
# Data Workspace typically provides connection via environment variables

get_db_connection <- function() {
  dbConnect(
    RPostgres::Postgres(),
    host = Sys.getenv("DATABASE_HOST", "localhost"),
    port = as.integer(Sys.getenv("DATABASE_PORT", "5432")),
    dbname = Sys.getenv("DATABASE_NAME", "ons_labour_market"),
    user = Sys.getenv("DATABASE_USER", ""),
    password = Sys.getenv("DATABASE_PASSWORD", "")
  )
}


# -----------------------------------------------------------------------------
# Get Employment (Absolute Value) Over Time
# -----------------------------------------------------------------------------
#' @param region_filter Character. Region name or NULL for all regions
#' @param age_filter Character. Age group or NULL for all ages
#' @param sector_filter Character. Sector name or NULL for all sectors
#' @return data.frame with time_period and total_employment columns

get_employment_absolute <- function(region_filter = NULL,
                                    age_filter = NULL,
                                    sector_filter = NULL) {

  con <- get_db_connection()
  on.exit(dbDisconnect(con))

  query <- "
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
      time_period ASC
  "

  result <- dbGetQuery(con, query, params = list(
    region_filter,
    age_filter,
    sector_filter
  ))

  return(result)
}


# -----------------------------------------------------------------------------
# Get Employment Rate Over Time
# -----------------------------------------------------------------------------
#' @param region_filter Character. Region name or NULL for all regions
#' @param age_filter Character. Age group or NULL for all ages
#' @param sector_filter Character. Sector name or NULL for all sectors
#' @return data.frame with time_period and employment_rate columns

get_employment_rate <- function(region_filter = NULL,
                                age_filter = NULL,
                                sector_filter = NULL) {

  con <- get_db_connection()
  on.exit(dbDisconnect(con))

  query <- "
    SELECT
      time_period,
      SUM(employment_count) * 100.0 / SUM(population) AS employment_rate
    FROM
      ons_labour_market.employment_data
    WHERE
      (region = $1 OR $1 IS NULL)
      AND (age_group = $2 OR $2 IS NULL)
      AND (sector = $3 OR $3 IS NULL)
    GROUP BY
      time_period
    ORDER BY
      time_period ASC
  "

  result <- dbGetQuery(con, query, params = list(
    region_filter,
    age_filter,
    sector_filter
  ))

  return(result)
}


# -----------------------------------------------------------------------------
# Get Available Filter Values
# -----------------------------------------------------------------------------
# Use these to populate dropdown menus in the Shiny UI

get_regions <- function() {
  con <- get_db_connection()
  on.exit(dbDisconnect(con))

  query <- "SELECT DISTINCT region FROM ons_labour_market.employment_data ORDER BY region"
  result <- dbGetQuery(con, query)
  return(result$region)
}

get_age_groups <- function() {
  con <- get_db_connection()
  on.exit(dbDisconnect(con))

  query <- "SELECT DISTINCT age_group FROM ons_labour_market.employment_data ORDER BY age_group"
  result <- dbGetQuery(con, query)
  return(result$age_group)
}

get_sectors <- function() {
  con <- get_db_connection()
  on.exit(dbDisconnect(con))

  query <- "SELECT DISTINCT sector FROM ons_labour_market.employment_data ORDER BY sector"
  result <- dbGetQuery(con, query)
  return(result$sector)
}


# -----------------------------------------------------------------------------
# Example Usage (for testing)
# -----------------------------------------------------------------------------
#
# # Get all employment data (no filters)
# all_employment <- get_employment_absolute()
#
# # Get employment for Wales only
# wales_employment <- get_employment_absolute(region_filter = "Wales")
#
# # Get employment for 65+ in Hospitality in Wales
# filtered_employment <- get_employment_absolute(
#   region_filter = "Wales",
#   age_filter = "65+",
#   sector_filter = "Hospitality"
# )
#
# # Get employment rate for same filters
# filtered_rate <- get_employment_rate(
#   region_filter = "Wales",
#   age_filter = "65+",
#   sector_filter = "Hospitality"
# )
