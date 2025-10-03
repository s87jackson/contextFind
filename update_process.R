# Package Update Process

# Clean environment ----
rm(list = ls())

# Document ----
devtools::document(roclets = c('rd', 'collate', 'namespace', 'vignette'))

# Clean and install ----
system("Rcmd.exe INSTALL --preclean --no-multiarch --with-keep.source .")

# Remove old check directory ----
unlink("C:/Users/SteveJackson/OneDrive - Toxcel/contextFind.Rcheck", recursive = TRUE)

# Check package ----
devtools::check(args = c('--as-cran'), check_dir = tempdir())

# Move Claude files ----

if (dir.exists(".claude")) {
  message("  Moving .claude folder...")
  file.copy(".claude", "in_development", recursive = TRUE, overwrite = TRUE)
  unlink(".claude", recursive = TRUE)
}

claude_md_files <- list.files(pattern = "^CLAUDE.*\\.md$", full.names = TRUE, recursive = FALSE)
if (length(claude_md_files) > 0) {
  for (file in claude_md_files) {
    message(sprintf("  Moving %s...", basename(file)))
    file.copy(file, file.path("in_development", basename(file)), overwrite = TRUE)
    file.remove(file)
  }
}


# Delete docs folder ----
if (dir.exists("docs")) {
  unlink("docs", recursive = TRUE, force = TRUE)
  message("  docs folder deleted successfully")
} else {
  message("  No docs folder found")
}

# Build pkgdown site ----
pkgdown::build_site_github_pages()

# Git commit ----
message("MANUAL STEP: Git commit all changed files (Commit, Push)")
readline(prompt = "Press [enter] to continue after committing")

# CRAN submission prep ----
message("\n=== FOR CRAN SUBMISSION ===")
message("1. Update cran-comments.md")
message("2. Make sure version number in DESCRIPTION is accurate")
message("3. Run: devtools::submit_cran()")
message("4. See https://r-pkgs.org/release.html for more info")

devtools::submit_cran()
