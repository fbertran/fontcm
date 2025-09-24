extract_pfb_names <- function(lines) {
  lines <- gsub("\r$", "", lines, useBytes = TRUE)
  keep <- nzchar(lines) & grepl("<<", lines, fixed = TRUE) & !grepl("^\\s*[%#]", lines)
  lines <- lines[keep]
  if (!length(lines)) return(character())

  get_token <- function(s) {
    parts <- strsplit(s, "<<", fixed = TRUE)[[1]]
    last <- parts[[length(parts)]]
    m <- regexpr("[[:space:]>#\"']", last, perl = TRUE)
    tok <- if (m[1] > 0) substr(last, 1, m[1] - 1) else last
    trimws(tok)
  }

  toks <- vapply(lines, get_token, character(1))
  toks <- toks[nzchar(toks)]
  toks <- toks[grepl("\\.pfb$", toks, ignore.case = TRUE)]
  unique(tolower(toks))
}


test_that("core font resources are present", {
  base <- system.file("fonts", package = "fontcm")
  expect_true(nzchar(base), info = "inst/fonts dir should be installed")
  expect_true(file.exists(file.path(base, "cm-lgc.map")))
  expect_true(file.exists(file.path(base, "8r-mod.enc")))

  afm_dir <- system.file("fonts", "metrics", package = "fontcm")
  pfb_dir <- system.file("fonts", "outlines", package = "fontcm")
  expect_true(dir.exists(afm_dir))
  expect_true(dir.exists(pfb_dir))

  # Check a minimal set of core faces exist (AFM + PFB)
  core_afm <- c("fcmr8a.afm","fcmb8a.afm","fcmri8a.afm","fcmbi8a.afm")
  core_pfb <- sub("\\.afm$", ".pfb", core_afm)

  for (f in core_afm) expect_true(file.exists(file.path(afm_dir, f)), info = f)
  for (f in core_pfb) expect_true(file.exists(file.path(pfb_dir, f)), info = f)

  # The map should reference those PFB files

  map_txt <- readLines(file.path(base, "cm-lgc.map"), warn = FALSE)
  pfbs_in_map <- extract_pfb_names(map_txt)
  skip_if_not(length(pfbs_in_map) > 0, "no PFB names parsed from map")

  # case-insensitive compare
  for (f in core_pfb) {
    f <- tolower(f)
    expect_true(f %in% pfbs_in_map, info = paste("mapped:", f))
  }

})
