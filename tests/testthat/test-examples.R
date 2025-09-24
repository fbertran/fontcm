test_that("manual examples run (no donttest/dontrun)", {
  tps <- c("fontcm")
  for (tp in tps) {
    expect_error(suppressWarnings(example(topic = tp, package = "fontcm", character.only = TRUE,
                                          run.donttest = FALSE, give.lines = FALSE, echo = FALSE)), NA)
  }
})
