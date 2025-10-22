# Test contextFind function

# Helper function to create temporary test files
setup_test_files <- function() {
  temp_dir <- tempdir()
  test_dir <- file.path(temp_dir, "contextFind_test")

  # Clean up if exists
  if (dir.exists(test_dir)) {
    unlink(test_dir, recursive = TRUE)
  }

  dir.create(test_dir, showWarnings = FALSE)
  dir.create(file.path(test_dir, "subdir"), showWarnings = FALSE)

  # Create test R files
  writeLines(c(
    "# Line 1",
    "# Line 2",
    "test_function <- function() {",
    "  x <- 1",
    "  y <- 2",
    "  return(x + y)",
    "}",
    "# Line 8"
  ), file.path(test_dir, "test1.R"))

  writeLines(c(
    "another_function <- function() {",
    "  test_value <- 42",
    "  return(test_value)",
    "}"
  ), file.path(test_dir, "test2.R"))

  # Create test Rmd file
  writeLines(c(
    "---",
    "title: Test",
    "---",
    "",
    "```{r}",
    "test_chunk <- TRUE",
    "```"
  ), file.path(test_dir, "test.Rmd"))

  # Create a file in subdirectory
  writeLines(c(
    "sub_function <- function() {",
    "  test_nested <- 'nested'",
    "}"
  ), file.path(test_dir, "subdir", "nested.R"))

  # Create a non-R file (should be ignored)
  writeLines(c(
    "test_value in txt file"
  ), file.path(test_dir, "ignore.txt"))

  return(test_dir)
}

test_that("contextFind finds basic matches", {
  test_dir <- setup_test_files()

  results <- contextFind("test_function", path = test_dir, contextLines = 0)

  expect_type(results, "list")
  expect_length(results, 1)
  expect_equal(results[[1]]$match_line, 3)
  expect_true(grepl("test1.R$", results[[1]]$file))
})

test_that("contextFind extracts correct context lines", {
  test_dir <- setup_test_files()

  results <- contextFind("x <- 1", path = test_dir, contextLines = 2)

  expect_length(results, 1)
  context <- results[[1]]$context
  expect_length(context, 5)  # 2 before + match + 2 after
  expect_equal(names(context), c("2", "3", "4", "5", "6"))
  expect_equal(as.character(context["4"]), "  x <- 1")
})

test_that("contextFind handles matches at file start", {
  test_dir <- setup_test_files()

  results <- contextFind("# Line 1", path = test_dir, contextLines = 2)

  expect_length(results, 1)
  context <- results[[1]]$context
  # Should only have match + 2 after (no lines before)
  expect_length(context, 3)
  expect_equal(names(context)[1], "1")
})

test_that("contextFind handles matches at file end", {
  test_dir <- setup_test_files()

  results <- contextFind("# Line 8", path = test_dir, contextLines = 2)

  expect_length(results, 1)
  context <- results[[1]]$context
  # Should only have 2 before + match (no lines after)
  expect_length(context, 3)
  expect_equal(names(context)[3], "8")
})

test_that("contextFind returns NULL with message when no matches found", {
  test_dir <- setup_test_files()

  expect_message(
    results <- contextFind("nonexistent_string", path = test_dir),
    "No matches found"
  )

  expect_null(results)
})

test_that("contextFind searches both .R and .Rmd files", {
  test_dir <- setup_test_files()

  # Search for pattern that appears in both types
  results <- contextFind("test", path = test_dir, contextLines = 0)

  expect_true(length(results) > 0)

  # Check that we have results from both file types
  file_extensions <- sapply(results, function(r) {
    tools::file_ext(r$file)
  })

  expect_true("R" %in% file_extensions)
  expect_true("Rmd" %in% file_extensions)
})

test_that("contextFind respects recursive parameter", {
  test_dir <- setup_test_files()

  # Non-recursive search should not find nested file
  results_non_recursive <- contextFind("test_nested", path = test_dir,
                                       recursive = FALSE, contextLines = 0)
  expect_null(results_non_recursive)

  # Recursive search should find nested file
  results_recursive <- contextFind("test_nested", path = test_dir,
                                   recursive = TRUE, contextLines = 0)
  expect_length(results_recursive, 1)
  expect_true(grepl("subdir", results_recursive[[1]]$file))
})

test_that("contextFind ignores non-R files", {
  test_dir <- setup_test_files()

  # Search for pattern that only exists in .txt file
  results <- contextFind("txt file", path = test_dir, contextLines = 0)

  expect_null(results)
})

test_that("contextFind handles multiple matches in same file", {
  test_dir <- setup_test_files()

  results <- contextFind("test", path = test_dir, contextLines = 0)

  expect_true(length(results) > 1)

  # Check that matches are ordered by line number within same file
  test1_results <- Filter(function(r) grepl("test1.R$", r$file), results)
  if (length(test1_results) > 1) {
    line_nums <- sapply(test1_results, function(r) r$match_line)
    expect_equal(line_nums, sort(line_nums))
  }
})

test_that("contextFind result structure is correct", {
  test_dir <- setup_test_files()

  results <- contextFind("test_function", path = test_dir, contextLines = 1)

  expect_type(results, "list")
  expect_length(results, 1)

  result <- results[[1]]
  expect_named(result, c("file", "match_line", "mtime", "context"))
  expect_type(result$file, "character")
  expect_type(result$match_line, "integer")
  expect_s3_class(result$mtime, "POSIXct")
  expect_type(result$context, "character")
  expect_true(all(names(result$context) != ""))  # Context should be named
})

test_that("contextFind throws error when no files found", {
  temp_dir <- tempfile()
  dir.create(temp_dir)

  expect_error(
    contextFind("anything", path = temp_dir),
    "No files found in path"
  )

  unlink(temp_dir, recursive = TRUE)
})

test_that("contextFind handles files with read errors gracefully", {
  test_dir <- setup_test_files()

  # This should not throw an error even if a file can't be read
  # (the function uses tryCatch)
  expect_error(
    contextFind("test", path = test_dir),
    NA
  )
})

test_that("contextFind with contextLines = 0 shows only match line", {
  test_dir <- setup_test_files()

  results <- contextFind("x <- 1", path = test_dir, contextLines = 0)

  expect_length(results, 1)
  context <- results[[1]]$context
  expect_length(context, 1)
  expect_equal(names(context), "4")
})

test_that("contextFind is case-sensitive", {
  test_dir <- setup_test_files()

  # Should find lowercase
  results_lower <- contextFind("test_function", path = test_dir, contextLines = 0)
  expect_length(results_lower, 1)

  # Should not find uppercase (function uses fixed = TRUE)
  results_upper <- contextFind("TEST_FUNCTION", path = test_dir, contextLines = 0)
  expect_null(results_upper)
})

test_that("contextFind results are sorted correctly", {
  test_dir <- setup_test_files()

  # Create files with different modification times
  Sys.sleep(0.1)
  writeLines("old_test <- 1", file.path(test_dir, "old.R"))
  Sys.sleep(0.1)
  writeLines("new_test <- 1", file.path(test_dir, "new.R"))

  results <- contextFind("test", path = test_dir, contextLines = 0)

  expect_true(length(results) > 1)

  # Results should be sorted by mtime (oldest first in internal order,
  # but displayed newest last)
  mtimes <- sapply(results, function(r) r$mtime)
  expect_true(all(diff(mtimes) >= 0))
})

test_that("contextFind handles special regex characters as literal", {
  test_dir <- setup_test_files()

  # Add a file with special characters
  writeLines(c(
    "pattern <- '.*test.*'",
    "x <- 1"
  ), file.path(test_dir, "special.R"))

  # Should find literal string (fixed = TRUE means no regex)
  results <- contextFind(".*test.*", path = test_dir, contextLines = 0)

  expect_length(results, 1)
  expect_true(grepl("special.R$", results[[1]]$file))
})
