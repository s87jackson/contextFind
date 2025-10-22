## ----include = FALSE---------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  eval = FALSE
)

## ----------------------------------------------------------
#  install.packages("contextFind")

## ----------------------------------------------------------
#  devtools::install_github("s87jackson/contextFind")

## ----------------------------------------------------------
#  library(contextFind)
#  
#  # Search for all function definitions in your project
#  contextFind("<- function")

## ----------------------------------------------------------
#  # No context - just the matching line
#  contextFind("renderPlot", contextLines = 0)
#  
#  # More context for complex functions
#  contextFind("reactive", contextLines = 5)

## ----------------------------------------------------------
#  # Search only in the R/ directory
#  contextFind("validate", path = "R")
#  
#  # Search in a subdirectory
#  contextFind("test", path = "tests/testthat")

## ----------------------------------------------------------
#  # Search only the current directory (no subdirectories)
#  contextFind("TODO", recursive = FALSE)
#  
#  # Search all subdirectories (default)
#  contextFind("TODO", recursive = TRUE)

## ----------------------------------------------------------
#  # Find all function definitions
#  contextFind("<- function")
#  
#  # Find a specific function
#  contextFind("calculate_metrics <- function")

## ----------------------------------------------------------
#  # Find where a variable is used
#  contextFind("user_data")
#  
#  # Find reactive values in Shiny apps
#  contextFind("reactiveVal")

## ----------------------------------------------------------
#  # Find specific input widgets
#  contextFind("selectInput")
#  
#  # Find output renderers
#  contextFind("renderPlot")

## ----------------------------------------------------------
#  # Find all TODO comments
#  contextFind("TODO")
#  
#  # Find FIXME or bug markers
#  contextFind("FIXME")
#  
#  # Find deprecated functions
#  contextFind(".Deprecated")

## ----------------------------------------------------------
#  # Find all uses of a package
#  contextFind("dplyr::")
#  
#  # Find library calls
#  contextFind("library(")
#  
#  # Find specific ggplot geoms
#  contextFind("geom_point")

## ----------------------------------------------------------
#  # Find browser() calls you may have left in code
#  contextFind("browser()")
#  
#  # Find print statements
#  contextFind("print(")
#  
#  # Find error handling
#  contextFind("tryCatch")

## ----------------------------------------------------------
#  # Store results
#  results <- contextFind("ggplot")
#  
#  # Access the first match
#  results[[1]]$file         # Full file path
#  results[[1]]$match_line   # Line number where match was found
#  results[[1]]$mtime        # File modification time
#  results[[1]]$context      # Named character vector of context lines
#  
#  # Get all matching files
#  unique(sapply(results, function(x) x$file))
#  
#  # Count matches per file
#  table(sapply(results, function(x) basename(x$file)))
#  
#  # Find most recently modified files with matches
#  recent <- results[[length(results)]]
#  cat("Most recent match in:", basename(recent$file),
#      "at line", recent$match_line, "\n")

## ----------------------------------------------------------
#  # Find all assignments to variables starting with "df_"
#  contextFind("df_")
#  
#  # Find function calls (including arguments)
#  contextFind("function(")

## ----------------------------------------------------------
#  # After modifying files, find where you used a new function
#  contextFind("new_function")

## ----------------------------------------------------------
#  # Find all observers
#  contextFind("observe(")
#  
#  # Find all event handlers
#  contextFind("observeEvent")
#  
#  # Find module calls
#  contextFind("Module(")

## ----------------------------------------------------------
#  # Find all functions that need documentation
#  results <- contextFind("<- function", contextLines = 0)
#  
#  # Check if they have roxygen comments
#  documented <- sapply(results, function(r) {
#    lines <- readLines(r$file)
#    line_before <- lines[max(1, r$match_line - 1)]
#    grepl("#'", line_before)
#  })
#  
#  cat(sprintf("%d of %d functions have documentation\n",
#              sum(documented), length(documented)))

## ----------------------------------------------------------
#  # These are different searches:
#  contextFind("data")       # lowercase
#  contextFind("Data")       # uppercase

## ----------------------------------------------------------
#  # Search only source files
#  contextFind("function", path = "R/")
#  
#  # Search only test files
#  contextFind("expect_", path = "tests/testthat/")
#  
#  # Search only vignettes
#  contextFind("knitr", path = "vignettes/")

## ----------------------------------------------------------
#  # Search for roxygen @export tags
#  results <- contextFind("@export", path = "R/")
#  
#  # Find what functions are exported
#  exported_functions <- sapply(results, function(r) {
#    lines <- readLines(r$file)
#    # Look ahead for function definition
#    func_line <- lines[r$match_line + 1]
#    if (grepl("<- function", func_line)) {
#      trimws(gsub("<-.*", "", func_line))
#    } else {
#      NA
#    }
#  })
#  
#  cat("Exported functions:\n")
#  print(na.omit(exported_functions))

## ----------------------------------------------------------
#  # Find potential hardcoded file paths
#  contextFind("C:/")
#  contextFind("/Users/")
#  
#  # Find hardcoded credentials (be careful!)
#  contextFind("password")
#  contextFind("api_key")

## ----------------------------------------------------------
#  # Count UI elements
#  ui_results <- contextFind("Input(", path = ".")
#  cat("Number of input widgets:", length(ui_results), "\n")
#  
#  # Count outputs
#  output_results <- contextFind("render", path = ".")
#  cat("Number of render functions:", length(output_results), "\n")
#  
#  # Find reactive chains
#  contextFind("reactive(")
#  contextFind("observe(")

