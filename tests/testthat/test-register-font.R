test_that("Type 1 family can be registered and used by pdf()", {
  afm_dir <- system.file("fonts", "metrics", package = "fontcm")
  enc     <- file.path(system.file("fonts", package = "fontcm"), "8r-mod.enc")

  reg      <- file.path(afm_dir, "fcmr8a.afm")
  bold     <- file.path(afm_dir, "fcmb8a.afm")
  ital     <- file.path(afm_dir, "fcmri8a.afm")
  boldital <- file.path(afm_dir, "fcmbi8a.afm")

  skip_if_not(all(file.exists(c(enc, reg, bold, ital, boldital))),
              "AFM/encoding files missing")

  register_cm_8r <- function(base_name = "CMRoman_8r_mod", enc) {
    fam <- grDevices::Type1Font(
      "CMRoman",
      metrics  = c(reg, bold, ital, boldital),
      encoding = enc
    )

    # choose a unique name; avoid clashes with different encodings
    fam_name <- base_name
    cur <- grDevices::pdfFonts()
    if (!is.null(cur[[fam_name]])) {
      old_enc <- tryCatch(cur[[fam_name]]$encoding, error = function(e) NULL)
      if (!is.null(old_enc) &&
          !identical(normalizePath(old_enc, mustWork = FALSE),
                     normalizePath(enc,  mustWork = FALSE))) {
        fam_name <- paste0(base_name, "_", as.integer(runif(1, 1e6, 9e6)))
      }
    }
    args <- list(); args[[fam_name]] <- fam
    do.call(grDevices::pdfFonts, args)
    fam_name
  }

  fam_name <- register_cm_8r(enc = enc)

  tf <- tempfile(fileext = ".pdf")
  if (requireNamespace("withr", quietly = TRUE)) {
    withr::defer(unlink(tf), envir = parent.frame())
  } else {
    on.exit(unlink(tf), add = TRUE)
  }

  # IMPORTANT: match the device encoding to the font family encoding
  grDevices::pdf(tf, width = 3, height = 2, family = fam_name, encoding = enc)
  plot.new(); text(0.5, 0.5, paste("CM Roman test:", fam_name))
  grDevices::dev.off()

  expect_true(file.exists(tf))
  expect_gt(file.info(tf)$size, 1000)  # non-empty
})
