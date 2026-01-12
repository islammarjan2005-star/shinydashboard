
# ------------------------------------------------------------
# GOV.UK Helpers for Shiny Apps
# ------------------------------------------------------------

#' Add GOV.UK Frontend CSS/JS dependencies and initialise components
#'
#' Injects the GOV.UK Frontend styles and JavaScript into your Shiny app,
#' and calls `GOVUKFrontend.initAll()` once the DOM is ready. Supports GOV.UK
#' or DBT design variants.
#'
#' @param style Character. Which style set to use: `"GOVUK"` or `"DBT"`.
#'   Defaults to `"GOVUK"`.
#' @param css_govuk Character. Filename for GOV.UK CSS (in `www/`).
#' @param css_dbt Character. Filename for DBT CSS (in `www/`).
#' @param js Character. Filename for GOV.UK JS (in `www/`).
#'
#' @return A `tagList()` containing `<link>` and `<script>` tags for inclusion
#'   in the UI.
#'
#' @examples
#' # In your UI:
#' fluidPage(
#'   govuk_dependencies(style = "DBT"),
#'   h1("My GOV.UK styled app")
#' )
#'
#' @export
govuk_dependencies <- function(
    style = c("GOVUK", "DBT"),
    css_govuk = "govuk-frontend-6.0.0-beta.0.min.css",
    css_dbt   = "DBT-frontend-6.0.0-beta.0.min.css",
    js        = "govuk-frontend-6.0.0-beta.0.min.js"
) {
  style <- match.arg(style)
  css_file <- if (style == "DBT") css_dbt else css_govuk
  
  tagList(
    tags$link(rel = "stylesheet", href = css_file),
    tags$script(src = js, defer = NA),
    tags$script(HTML("
      document.addEventListener('DOMContentLoaded', function () {
        if (window.GOVUKFrontend && typeof window.GOVUKFrontend.initAll === 'function') {
          window.GOVUKFrontend.initAll();
        }
      });
    "))
  )
}


#' Apply GOV.UK rebrand classes and meta tags
#'
#' Adds classes to `<html>` and `<body>` for GOV.UK rebranded styling,
#' and sets the theme colour meta tag.
#'
#' @return A `tagList()` with `<meta>` and `<script>` tags.
#'
#' @examples
#' fluidPage(
#'   govuk_apply_rebrand(),
#'   h1("Rebranded GOV.UK app")
#' )
#'
#' @export
govuk_apply_rebrand <- function() {
  tagList(
    tags$meta(name = "theme-color", content = "#1d70b8"),
    tags$script(HTML("
      (function () {
        document.documentElement.classList.add('govuk-template', 'govuk-template--rebranded');
        document.addEventListener('DOMContentLoaded', function () {
          document.body.classList.add('govuk-template__body');
        });
      })();
    "))
  )
}


#' Add GOV.UK head assets (favicons, manifest)
#'
#' Injects favicon links, Apple touch icons, and manifest references into the
#' document head. Adjust paths to match your `www/assets/` structure.
#'
#' @return A `tagList()` with `<link>` tags for favicons and manifest.
#'
#' @examples
#' fluidPage(
#'   govuk_head_assets(),
#'   h1("App with GOV.UK favicons")
#' )
#'
#' @export
govuk_head_assets <- function() {
  tagList(
    tags$link(rel = "manifest", href = "assets/manifest.json"),
    tags$link(rel = "icon", type = "image/png",
              href = "assets/images/favicon-32x32.png", sizes = "32x32"),
    tags$link(rel = "icon", type = "image/png",
              href = "assets/images/favicon-16x16.png", sizes = "16x16"),
    tags$link(rel = "apple-touch-icon", href = "assets/images/apple-touch-icon.png"),
    tags$link(rel = "icon", type = "image/svg+xml", href = "assets/rebrand/favicon.svg")
  )
}
