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


test_that("a few PFBs mentioned in the map file exist on disk", {
  base <- system.file("fonts", package = "fontcm")
  pfb_dir <- system.file("fonts", "type1", package = "fontcm")
  map <- file.path(base, "cm-lgc.map")
  skip_if_not(file.exists(map) && dir.exists(pfb_dir))

  map_txt <- readLines(map, warn = FALSE)
  lines <- grep("<<.*\\.pfb", map_txt, value = TRUE)
  # Take first 10 entries deterministically
  pfbs <- extract_pfb_names(lines)
pfbs <- head(pfbs, 10)
  for (p in pfbs) {
    expect_true(file.exists(file.path(pfb_dir, p)), info = p)
  }
})
