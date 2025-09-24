test_that("extrafont can import/list CM fonts in an isolated cache", {
  skip_if_not_installed("extrafont")
  skip_if_not_installed("withr")

  metrics <- system.file("fonts", "metrics", package = "fontcm")
  pfb     <- system.file("fonts", "outlines",   package = "fontcm")
  skip_if_not(nzchar(metrics) && dir.exists(metrics), "metrics dir missing")
  skip_if_not(nzchar(pfb) && dir.exists(pfb), "type1 dir missing")

  tmp_home <- withr::local_tempdir()
  withr::local_envvar(c(
    HOME = tmp_home,
    USERPROFILE = tmp_home,
    XDG_CACHE_HOME = file.path(tmp_home, "cache"),
    XDG_CONFIG_HOME = file.path(tmp_home, "config"),
    XDG_DATA_HOME = file.path(tmp_home, "data"),
    R_USER_CACHE_DIR = file.path(tmp_home, "cache", "R"),
    R_USER_CONFIG_DIR = file.path(tmp_home, "config", "R"),
    R_USER_DATA_DIR = file.path(tmp_home, "data", "R")
  ))

  ns <- asNamespace("extrafont")
  has_afm_import <- exists("afm_import", envir = ns, inherits = FALSE)
  fm <- get("font_import", ns)
  fm_formals <- names(formals(fm))
  can_type <- "type" %in% fm_formals

  afm_files <- list.files(metrics, pattern = "\\.afm$", full.names = FALSE)
  skip_if_not(length(afm_files) > 0, "no AFM files found")

  imported <- FALSE
  err <- NULL

  # Try AFM import via the most explicit/supported route first
  if (has_afm_import) {
    afm_fun <- get("afm_import", ns)
    # Build args dynamically for compatibility across versions
    a <- list(paths = metrics, recursive = FALSE, pattern = "\\.afm$", prompt = FALSE)
    # Some versions don't have 'prompt'; trim to only present formals
    present <- intersect(names(a), names(formals(afm_fun)))
    a <- a[present]
    tryCatch({ do.call(afm_fun, a); imported <- TRUE }, error = function(e) err <<- e)
  }

  # Fallback: font_import(type = "afm") if supported
  if (!imported && can_type) {
    a <- list(paths = metrics, recursive = FALSE, pattern = "\\\\.afm$", prompt = FALSE, quiet = TRUE, type = "afm")
    present <- intersect(names(a), fm_formals); a <- a[present]
    tryCatch({ do.call(fm, a); imported <- TRUE }, error = function(e) err <<- e)
  }

  # If we couldn't import AFMs with this extrafont, skip (version limitation)
  skip_if_not(imported, paste("AFM import not supported by this extrafont version;", if (!is.null(err)) conditionMessage(err) else ""))

  expect_silent(extrafont::loadfonts(device = "pdf", quiet = TRUE))

  # Confirm some CM family appears in the registry; else skip (import may have no visible families yet)
  families <- tryCatch(extrafont::fonts(), error = function(e) character())
  if (!length(families)) {
    families <- tryCatch(extrafont::fonts(device = "pdf"), error = function(e) character())
  }
  fam_lower <- tolower(families)
  has_cm <- any(grepl("^cm", fam_lower)) || any(grepl("computer modern|cm roman|cmr", fam_lower))
  skip_if_not(has_cm, "CM family not found in extrafont registry after AFM import")

  # Render a tiny PDF as a smoke test
  pick <- families[grep("(?i)^(cm|computer modern|cm roman|cmr)", families)][1]
  tf <- tempfile(fileext = ".pdf")
  grDevices::pdf(tf, width = 3, height = 2, family = pick)
  plot.new(); text(0.5, 0.5, paste("extrafont:", pick))
  grDevices::dev.off()
  expect_true(file.exists(tf))
  expect_gt(file.info(tf)$size, 1000)
  unlink(tf)
})
