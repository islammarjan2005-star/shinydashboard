# =============================================================================
# Plotting Functions for Employment Statistics
# =============================================================================
#
# Simple time series plots for employment data
# These integrate with the query functions in db_queries.R
#
# =============================================================================

library(ggplot2)
library(plotly)
library(scales)

source("R/data/db_queries.R")


# -----------------------------------------------------------------------------
# Single Line Time Series: Employment Count
# -----------------------------------------------------------------------------
#' Plot employment count over time as a single line
#' @param data data.frame with time_period and total_employment columns
#' @param title Character. Chart title
#' @return ggplot object

plot_employment_line <- function(data, title = "Employment Over Time") {

  p <- ggplot(data, aes(x = time_period, y = total_employment)) +
    geom_line(colour = "#1d70b8", linewidth = 1) +
    geom_point(colour = "#1d70b8", size = 2) +
    scale_y_continuous(labels = comma) +
    labs(
      title = title,
      x = NULL,
      y = "Employment (thousands)"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(size = 14, face = "bold"),
      axis.text = element_text(size = 10),
      panel.grid.minor = element_blank()
    )

  return(p)
}


# -----------------------------------------------------------------------------
# Single Line Time Series: Employment Rate
# -----------------------------------------------------------------------------
#' Plot employment rate over time as a single line
#' @param data data.frame with time_period and employment_rate columns
#' @param title Character. Chart title
#' @return ggplot object

plot_employment_rate_line <- function(data, title = "Employment Rate Over Time") {

  p <- ggplot(data, aes(x = time_period, y = employment_rate)) +
    geom_line(colour = "#00703c", linewidth = 1) +
    geom_point(colour = "#00703c", size = 2) +
    scale_y_continuous(labels = percent_format(scale = 1), limits = c(0, 100)) +
    labs(
      title = title,
      x = NULL,
      y = "Employment Rate (%)"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(size = 14, face = "bold"),
      axis.text = element_text(size = 10),
      panel.grid.minor = element_blank()
    )

  return(p)
}


# -----------------------------------------------------------------------------
# Stacked Area Chart: Employment by Category
# -----------------------------------------------------------------------------
#' Plot employment as stacked area by a grouping variable (region, age, sector)
#' @param data data.frame with time_period, category, and employment_count columns
#' @param category_col Character. Name of the grouping column
#' @param title Character. Chart title
#' @return ggplot object

plot_employment_stacked <- function(data,
                                    category_col = "region",
                                    title = "Employment by Region") {

  # GOV.UK accessible colour palette
  colours <- c(
    "#1d70b8", # Blue
    "#f47738", # Orange
    "#00703c", # Green
    "#5694ca", # Light blue
    "#912b88", # Purple
    "#d53880", # Pink
    "#4c2c92", # Dark purple
    "#28a197"  # Teal
  )

  p <- ggplot(data, aes(x = time_period,
                        y = employment_count,
                        fill = .data[[category_col]])) +
    geom_area(alpha = 0.8) +
    scale_y_continuous(labels = comma) +
    scale_fill_manual(values = colours) +
    labs(
      title = title,
      x = NULL,
      y = "Employment (thousands)",
      fill = NULL
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(size = 14, face = "bold"),
      axis.text = element_text(size = 10),
      panel.grid.minor = element_blank(),
      legend.position = "right"
    )

  return(p)
}


# -----------------------------------------------------------------------------
# Example Usage
# -----------------------------------------------------------------------------
#
# # Fetch data with filters
# data <- get_employment_absolute(
#   region_filter = "Wales",
#   age_filter = "65+",
#   sector_filter = "Hospitality"
# )
#
# # Create static plot
# p <- plot_employment_line(data, title = "65+ Employment in Hospitality (Wales)")
#
# # Convert to interactive plotly
# ggplotly(p)
#
# # For Shiny output:
# output$trend <- renderPlotly({
#   data <- get_employment_absolute(
#     region_filter = input$region,
#     age_filter = input$age,
#     sector_filter = input$sector
#   )
#   ggplotly(plot_employment_line(data))
# })
