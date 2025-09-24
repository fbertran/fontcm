if (requireNamespace("testthat", quietly = TRUE)) {
  library(testthat)
  suppressPackageStartupMessages(library(fontcm))
  test_check("fontcm")
} else {
  warning("testthat not installed; tests skipped.")
}
