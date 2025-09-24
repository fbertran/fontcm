test_that("exported symbols exist in the namespace", {
  ns <- asNamespace("fontcm")
  exports <- c()
  for (nm in exports) {
    expect_true(exists(nm, envir = ns, inherits = FALSE), info = nm)
  }
})
