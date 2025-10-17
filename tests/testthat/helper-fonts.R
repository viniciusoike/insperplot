# Test Helpers for Font Availability

#' Skip test if Insper fonts are not available
#'
#' This helper function checks if the required Insper fonts are installed
#' and skips the test if they're not available. This prevents font-related
#' test failures in CI environments or systems without the fonts installed.
skip_if_no_fonts <- function() {
  # Suppress verbose output when checking fonts
  font_status <- check_insper_fonts(verbose = FALSE)

  # Check if both fonts are available
  fonts_available <- all(font_status)

  if (!fonts_available) {
    testthat::skip("Insper fonts not available (EB Garamond or Barlow missing)")
  }
}

#' Skip test if ragg device is not available
#'
#' Visual tests may render differently with different graphics devices.
#' This helper skips tests when ragg is not installed.
skip_if_no_ragg <- function() {
  if (!requireNamespace("ragg", quietly = TRUE)) {
    testthat::skip("ragg package not available")
  }
}
