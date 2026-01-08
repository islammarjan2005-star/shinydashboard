
# R/pages/page_employment.R

# ---- Employment page ----

library(ggplot2)
library(scales)
library(plotly)

# Source database query functions
# source("R/data/db_queries.R")  # Uncomment when DB connection is ready


# -----------------------------------------------------------------------------
# Mock data for development (remove when connected to ONS database)
# -----------------------------------------------------------------------------
mock_employment_data <- function() {
  dates <- seq(as.Date("2020-01-01"), as.Date("2024-12-01"), by = "month")
  data.frame(
    time_period = dates,
    total_employment = 32000 + cumsum(rnorm(length(dates), 50, 100))
  )
}

mock_regions <- c("All regions", "England", "Wales", "Scotland", "Northern Ireland",
                  "North East", "North West", "Yorkshire", "East Midlands",
                  "West Midlands", "East of England", "London", "South East", "South West")

mock_age_groups <- c("All ages", "16-17", "18-24", "25-34", "35-49", "50-64", "65+")

mock_sectors <- c("All sectors", "Agriculture", "Manufacturing", "Construction",
                  "Retail", "Hospitality", "Transport", "Finance", "Health", "Education")


# -----------------------------------------------------------------------------
# UI
# -----------------------------------------------------------------------------
employment_ui <- function(id) {
  ns <- NS(id)
  div(class = "govuk-width-container",
      tags$main(class = "govuk-main-wrapper",
                tags$span(class = "govuk-caption-xl", "Labour Market"),
                tags$h1(class = "govuk-heading-xl", "Employment"),
                tags$p(class = "govuk-body-s", paste("Last updated:", Sys.Date())),

                # Filter controls
                div(class = "govuk-grid-row",
                    div(class = "govuk-grid-column-one-third",
                        tags$label(class = "govuk-label", `for` = ns("region"), "Region"),
                        selectInput(ns("region"), NULL, choices = mock_regions,
                                    selected = "All regions", width = "100%")
                    ),
                    div(class = "govuk-grid-column-one-third",
                        tags$label(class = "govuk-label", `for` = ns("age"), "Age group"),
                        selectInput(ns("age"), NULL, choices = mock_age_groups,
                                    selected = "All ages", width = "100%")
                    ),
                    div(class = "govuk-grid-column-one-third",
                        tags$label(class = "govuk-label", `for` = ns("sector"), "Sector"),
                        selectInput(ns("sector"), NULL, choices = mock_sectors,
                                    selected = "All sectors", width = "100%")
                    )
                ),

                tags$hr(class = "govuk-section-break govuk-section-break--m govuk-section-break--visible"),

                # Stats cards
                div(class = "govuk-grid-row",
                    div(class = "govuk-grid-column-one-third",
                        div(class = "govuk-summary-card", style="padding:15px; background:#f3f2f1; border-top:4px solid #1d70b8;",
                            h3(class="govuk-heading-s", "Total Employed"), uiOutput(ns("stat_employed"))
                        )
                    ),
                    div(class = "govuk-grid-column-one-third",
                        div(class = "govuk-summary-card", style="padding:15px; background:#f3f2f1; border-top:4px solid #00703c;",
                            h3(class="govuk-heading-s", "Employment Rate"), uiOutput(ns("stat_rate"))
                        )
                    ),
                    div(class = "govuk-grid-column-one-third",
                        div(class = "govuk-summary-card", style="padding:15px; background:#f3f2f1; border-top:4px solid #f47738;",
                            h3(class="govuk-heading-s", "Change (12 months)"), uiOutput(ns("stat_change"))
                        )
                    )
                ),

                # Chart
                h2(class = "govuk-heading-m", "Employment over time"),
                tags$p(class = "govuk-body-s govuk-hint", textOutput(ns("filter_summary"))),
                plotlyOutput(ns("trend"), height = "400px")
      )
  )
}


# -----------------------------------------------------------------------------
# Server
# -----------------------------------------------------------------------------
employment_server <- function(id) {
  moduleServer(id, function(input, output, session) {

    # Convert "All X" selections to NULL for SQL queries
    get_filter <- function(value, all_label) {
      if (value == all_label) NULL else value
    }

    # Fetch data based on filters
    # TODO: Replace mock_employment_data() with get_employment_absolute() when DB ready
    dat <- reactive({
      # region_filter <- get_filter(input$region, "All regions")
      # age_filter <- get_filter(input$age, "All ages")
      # sector_filter <- get_filter(input$sector, "All sectors")
      # get_employment_absolute(region_filter, age_filter, sector_filter)

      # Using mock data for now
      mock_employment_data()
    })

    # Filter summary text
    output$filter_summary <- renderText({
      parts <- c()
      if (input$region != "All regions") parts <- c(parts, input$region)
      if (input$age != "All ages") parts <- c(parts, input$age)
      if (input$sector != "All sectors") parts <- c(parts, input$sector)

      if (length(parts) == 0) {
        "Showing: All employment (UK total)"
      } else {
        paste("Showing:", paste(parts, collapse = ", "))
      }
    })

    # Stats
    output$stat_employed <- renderUI({
      curr <- tail(dat()$total_employment, 1)
      HTML(paste0("<h2 class='govuk-heading-l'>", comma(round(curr)), "k</h2>"))
    })

    output$stat_rate <- renderUI({
      # TODO: Calculate from real data
      HTML("<h2 class='govuk-heading-l'>75.1%</h2>")
    })

    output$stat_change <- renderUI({
      data <- dat()
      if (nrow(data) >= 13) {
        curr <- tail(data$total_employment, 1)
        prev <- data$total_employment[nrow(data) - 12]
        change <- curr - prev
        col <- if(change >= 0) "green" else "red"
        sign <- if(change >= 0) "+" else ""
        HTML(paste0("<h2 class='govuk-heading-l'>", sign, comma(round(change)), "k</h2>",
                    "<strong class='govuk-tag govuk-tag--", col, "'>",
                    sign, round(change / prev * 100, 1), "%</strong>"))
      } else {
        HTML("<h2 class='govuk-heading-l'>--</h2>")
      }
    })

    # Plot
    output$trend <- renderPlotly({
      data <- dat()

      p <- ggplot(data, aes(x = time_period, y = total_employment)) +
        geom_line(colour = "#1d70b8", linewidth = 1) +
        geom_point(colour = "#1d70b8", size = 1.5) +
        scale_y_continuous(labels = comma) +
        labs(x = NULL, y = "Employment (thousands)") +
        theme_minimal() +
        theme(
          panel.grid.minor = element_blank(),
          axis.text = element_text(size = 10)
        )

      ggplotly(p) %>%
        layout(hovermode = "x unified")
    })
  })
}
