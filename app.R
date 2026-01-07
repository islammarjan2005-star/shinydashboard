
# app.R -------------------------------------------------------

# Core packages
library(shiny)
library(bslib)
library(dplyr)
library(stringr)
library(lubridate)
library(ggplot2)
library(plotly)
library(DBI)
library(RPostgres)
library(shinyGovstyle)
library(rlang)          
library(shiny.router)   

`%||%` <- function(x, y) if (!is.null(x)) x else y

# Source internal helpers (keep these filenames)
source("R/components/ggplot_DIT.r")          # your plotting theme/utils
source("R/components/govuk_helpers.R")       # govuk_dependencies(), govuk_apply_rebrand(), govuk_head_assets()
source("R/components/govuk_header.R")        # govuk_header(), (and optionally govuk_footer())
source("R/components/govuk_top_nav.R")       # govuk_top_nav() wrapper for tabset-driven nav (non-router for now)
source("R/components/govuk_page.R")          # govuk_page() wrapper for a blank page template
# ------------------------------------------------------------
# Inputs
# ------------------------------------------------------------

tabs <- c(Home = "home", Employment = "employment", Unemployment = "unemployment", Vacancies = "vacancies")
default_route <- "home"
style <- "DBT"


# ------------------------------------------------------------
# Source page modules (one file per page)
# Each page file exports: <route>_ui(id) and <route>_server(id)
# ------------------------------------------------------------
source("R/pages/page_home.R")
source("R/pages/page_employment.R")
source("R/pages/page_unemployment.R")
source("R/pages/page_vacancies.R")


# ------------------------------------------------------------
# 404 page UI
# ------------------------------------------------------------
page_404_ui <- tags$div(
  class = "govuk-width-container",
  tags$main(class = "govuk-main-wrapper",
            tags$h1(class = "govuk-heading-l", "Page not found"),
            tags$p(class = "govuk-body", "Use the navigation to choose a page."),
            tags$a(class = "govuk-link", href = paste0("#/", default_route), "Back to Home"))
)


# ------------------------------------------------------------
# UI
# ------------------------------------------------------------


ui <- fluidPage(
  # Head assets & design system
  govuk_apply_rebrand(),
  govuk_head_assets(),
  govuk_dependencies(style = style),
  
  # Full-page wrapper
  tags$div(
    class = "govuk-template",
    
    # Header
    govuk_header(service_name = "Labour Markets Dashboard",
                 style = style, 
                 home_href = if (style == "GOVUK") {"https://www.gov.uk/"} else {"https://data.trade.gov.uk/"}, # Replace later with link back to datawroksapce page for the LM dashboard
                 service_href = "#!/", default_route),
    
    # Top navigation
    uiOutput("topnav"),
    
    
    
    # Inline router: same style as the vignette
    router_ui(
      route("/",            home_ui("home")),
      route("home",         home_ui("home")),
      route("employment",   employment_ui("employment")),
      route("unemployment", unemployment_ui("unemployment")),
      route("vacancies",    vacancies_ui("vacancies")),
      page_404 = page_404_ui
    ),
    
    
    # Footer (using shinyGovstyle)
    footer(TRUE)
    
  )
)




# ------------------------------------------------------------
# Server (NO lazy mounting for now)
# ------------------------------------------------------------
server <- function(input, output, session) {
  # Start router — IMPORTANT: no arguments here in this inline pattern
  router_server()
  
  
  
  # Watch hash changes and update nav
  observeEvent(session$clientData$url_hash, {
    # Extract route from hash (strip "#/" if present)
    route <- sub("^#!/?", "", session$clientData$url_hash)
    sel <- if (!nzchar(route)) "home" else route
    
    output$topnav <- renderUI({
      govuk_top_nav(tabs, selected = sel, id_prefix = "nav")
    })
  })
  
  
  # Eagerly mount all page servers for now (no lazy load)
  home_server("home")
  employment_server("employment")
  unemployment_server("unemployment")
  vacancies_server("vacancies")
}



shinyApp(ui, server)


