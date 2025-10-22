#' Search R and Rmd Files for Matching Text, Get Context and Links
#'
#' @param search_text Text to search for
#' @param path Root directory to search
#' @param recursive Whether to recurse into subfolders
#' @param contextLines Number of context lines around match
#' @param verbose If TRUE (the default), prints the results to the console
#' @return A list of lists, one for each match, with objects: file, match_line, mtime, and context.
#' file is the file path in which the match was found, match_line is the line number
#' for this particular match, mtime is a POSIXct datetime value indicating when
#' the file was last modified, and context contains the number of lines before
#' and after the found match (set by the contextLines parameter).
#'
#' @importFrom stats setNames
#'
#' @examples
#'
#' # Find custom functions in your codebase
#' contextFind("<- function")
#'
#' # Get more context
#' contextFind("<- function", contextLines = 3)
#'
#' # Explicitly set the search directory
#' contextFind("<- function", path = getwd())
#'
#' # Exclude subdirectories
#' contextFind("<- function", recursive = FALSE)
#'
#' @export
#'

contextFind <- function(
    search_text,
    path = ".",
    recursive = TRUE,
    contextLines = 2,
    verbose = TRUE) {

  all_files <- c(
    list.files(path, recursive = recursive, pattern = ".R$", full.names = TRUE),
    list.files(path, recursive = recursive, pattern = ".Rmd$", full.names = TRUE)
  )

  if(length(all_files)==0) stop("No files found in path")

  results <- list()

  for (file in all_files) {
    lines <- tryCatch(readLines(file, warn = FALSE), error = function(e) return(NULL))
    if (is.null(lines)) next

    for (i in seq_along(lines)) {
      if (grepl(search_text, lines[i], fixed = TRUE)) {
        context_start <- max(1, i - contextLines)
        context_end <- min(length(lines), i + contextLines)
        context_lines <- lines[context_start:context_end]

        results[[length(results) + 1]] <- list(
          file = file,
          match_line = i,
          mtime = file.info(file)$mtime,
          context = setNames(context_lines, (context_start:context_end))
        )
      }
    }
  }

  total_matches <- length(results)

  if (total_matches == 0) {
    if(verbose) message("No matches found.")
    return(invisible(NULL))
  }

  results <- results[order(
    sapply(results, function(x) x$mtime),                 # by mtime
    tolower(sapply(results, function(x) x$file)),         # then by file (case-insensitive)
    sapply(results, function(x) x$match_line),            # then by line number
    na.last = TRUE
  )]

  if(verbose){
    cat(
      sprintf("\nFound %d match%s for \"%s\"\n",
      total_matches,
      ifelse(total_matches == 1, "", "es"), search_text)
      )
  }

  highlight_start <- "\033[1;33m"  # Bold Yellow
  highlight_end <- "\033[0m"

  for (i in seq_along(results)) {
    res <- results[[i]]
    abs_path <- normalizePath(res$file, winslash = "/")

    # Construct a file:// URL with line number
    url <- sprintf("file://%s#%d", abs_path, res$match_line)
    link_text <- sprintf("%s (line %d)", basename(res$file), res$match_line)

    if(verbose){
      cat("\n==============================\n")
      cat(sprintf("Match %d of %d\n", total_matches - i + 1, total_matches))
      cat(cli::style_hyperlink(link_text, url), "\n")
      cat("Last Modified: ", format(res$mtime, "%Y-%m-%d %H:%M:%S"), "\n", sep = "")
      cat("------------------------------\n")
    }


    for (line_num in names(res$context)) {
      line_text <- res$context[[line_num]]
      if (as.integer(line_num) == res$match_line) {
        line_text <- gsub(
          search_text,
          paste0(highlight_start, search_text, highlight_end),
          line_text,
          fixed = TRUE
        )
      }
      if(verbose) cat(sprintf("   Line %s: %s\n", line_num, line_text))
    }
  }

  invisible(results)
}
