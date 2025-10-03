#' RStudio Add-in for contextFind
#'
#' Launches an interactive gadget for searching project files. The gadget allows
#' the user to enter a search string, choose a directory, specify whether
#' the search should be recursive, and how many lines of context to print.
#' Results are displayed in the console with clickable links to matched lines.
#'
#'
#' @return Invisibly returns the search results as a list (see [contextFind()]).
#' @seealso [contextFind()]
#' @export


contextFind_addin <- function() {
  if (!requireNamespace("rstudioapi", quietly = TRUE)) {
    message("rstudioapi is not available.")
    return()
  }

  if (!requireNamespace("shiny", quietly = TRUE)) {
    message("shiny is not available.")
    return()
  }

  if (!requireNamespace("miniUI", quietly = TRUE)) {
    message("miniUI is not available.")
    return()
  }

  # Pre-fill with highlighted text if available
  selected <- rstudioapi::getActiveDocumentContext()$selection[[1]]$text

  ui <- miniUI::miniPage(
    miniUI::miniContentPanel(
      shiny::tags$div(
        style = "display: grid; grid-template-columns: 1fr 1fr; gap: 10px; margin-bottom: 15px;",

        # Row 1: Search string label and input
        shiny::tags$label("Search string:", style = "margin-bottom: 0; align-self: center;"),
        shiny::textInput("search_text", label = NULL, value = selected, width = "100%"),

        # Row 2: Directory button and recursive checkbox
        shiny::actionButton("choose_dir", "Choose directory", width = "100%"),
        shiny::checkboxInput("recursive", "Search subdirectories", value = TRUE),

        # Row 3: Context lines label and input
        shiny::tags$label("Context lines:", style = "margin-bottom: 0; align-self: center;"),
        shiny::numericInput("contextLines", label = NULL, value = 2, min = 0, max = 10, step = 1, width = "100%")
      ),

      # Full-width search button
      shiny::actionButton("search_btn", "contextFind", width = "100%", class = "btn-primary")
    )
  )

  server <- function(input, output, session) {
    dir_path <- shiny::reactiveVal(getwd())

    shiny::observeEvent(input$choose_dir, {
      dir <- rstudioapi::selectDirectory(
        caption = "Select Directory",
        path = dir_path()
      )
      if (!is.null(dir)) {
        dir_path(dir)
      }
    })

    shiny::observeEvent(input$search_btn, {
      if (nzchar(input$search_text)) {
        contextFind(
          search_text = input$search_text,
          path = dir_path(),
          recursive = input$recursive,
          contextLines = input$contextLines
        )
      } else {
        message("No search string provided.")
      }
      shiny::stopApp()
    })
  }

  shiny::runGadget(ui, server, viewer = shiny::dialogViewer("contextFind", width = 500, height = 300))
}
