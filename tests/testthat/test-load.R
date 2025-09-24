test_that("package loads and has a namespace", {
  expect_true(requireNamespace("fontcm", quietly = TRUE))
  expect_true("fontcm" %in% loadedNamespaces())
})
