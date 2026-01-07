
# R/pages/page_employment.R


# ---- Employment page ----

library(ggplot2)
library(scales)
library(plotly)

employment_ui <- function(id) {
  ns <- NS(id)
  div(id = ns("container"),
      tags$div(
        class = "govuk-width-container",
        tags$main(
          class = "govuk-main-wrapper",
          id = "main-content",
          #tags$h1(class = "govuk-heading-xl", "Employment"),
          #sliderInput(ns("num"), "Pick a number", 1, 100, 50),
          verbatimTextOutput(ns("out"))
        )
      )
      
  )
}


# employment_server <- function(id) {
#  moduleServer(id, function(input, output, session) {
#    output$out <- renderText({ paste("Number is:", input$num) })
#  })
#  }



employment_ui <- function(id) {
  ns <- NS(id)
  div(class = "govuk-width-container",
      tags$main(class = "govuk-main-wrapper",
                tags$span(class = "govuk-caption-xl", "Labour Market"),
                tags$h1(class = "govuk-heading-xl", "Employment"),
                tags$p(class = "govuk-body-s", paste("Last updated:", Sys.Date())),
                
                # 3 stats  card
                div(class = "govuk-grid-row",
                    div(class = "govuk-grid-column-one-third",
                        div(class = "govuk-summary-card", style="padding:15px; background:#f3f2f1; border-top:4px solid #1d70b8;",
                            h3(class="govuk-heading-s", "Total Unemployed"), uiOutput(ns("stat1"))
                        )
                    ),
                    div(class = "govuk-grid-column-one-third",
                        div(class = "govuk-summary-card", style="padding:15px; background:#f3f2f1; border-top:4px solid #d4351c;",
                            h3(class="govuk-heading-s", "Duration (Weeks)"), uiOutput(ns("stat2"))
                        )
                    ),
                    div(class = "govuk-grid-column-one-third",
                        div(class = "govuk-summary-card", style="padding:15px; background:#f3f2f1; border-top:4px solid #00703c;",
                            h3(class="govuk-heading-s", "Population"), uiOutput(ns("stat3"))
                        )
                    )
                ),
                
                # chart
                h2(class = "govuk-heading-m", "Trends over time"),
                sliderInput(ns("range"), "Year Range", min(economics$date), max(economics$date),
                            value = c(as.Date("2010-01-01"), max(economics$date)), width = "100%"),
                plotlyOutput(ns("trend"), height = "350px")
      )
  )
}

employment_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    
    # filter the data
    dat <- reactive({ economics[economics$date >= input$range[1] & economics$date <= input$range[2], ] })
    
    # stats logic
    output$stat1 <- renderUI({
      curr <- tail(dat()$unemploy, 1); prev <- tail(dat()$unemploy, 2)[1]
      col <- if(curr > prev) "red" else "green" # red if unemployment goes up
      HTML(paste0("<h2 class='govuk-heading-l'>", comma(curr), "</h2>",
                  "<strong class='govuk-tag govuk-tag--", col, "'>", curr-prev, " vs last month</strong>"))
    })
    
    output$stat2 <- renderUI({
      curr <- tail(dat()$uempmed, 1); prev <- tail(dat()$uempmed, 2)[1]
      col <- if(curr > prev) "red" else "green" # red if duration goes up
      HTML(paste0("<h2 class='govuk-heading-l'>", comma(curr), "</h2>",
                  "<strong class='govuk-tag govuk-tag--", col, "'>", round(curr-prev,1), " vs last month</strong>"))
    })
    
    output$stat3 <- renderUI({
      curr <- tail(dat()$pop, 1); prev <- tail(dat()$pop, 2)[1]
      col <- if(curr > prev) "green" else "red" # green if "pop" goes up
      HTML(paste0("<h2 class='govuk-heading-l'>", comma(curr), "</h2>",
                  "<strong class='govuk-tag govuk-tag--", col, "'>", round(curr-prev,1), " vs last month</strong>"))
    })
    
    #plot
    output$trend <- renderPlotly({
      ggplotly(ggplot(dat(), aes(date, unemploy)) + geom_area(fill="#1d70b8", alpha=0.2) +
                 geom_line(col="#1d70b8", size=1) + theme_minimal() + labs(x=NULL, y="Unemployed (000s)"))
    })
  })
}