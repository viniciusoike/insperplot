# Package hooks for startup/load events

#' @keywords internal
.onLoad <- function(libname, pkgname) {
  # Try to automatically import Insper fonts from Google Fonts when package loads
  # This runs silently - if it fails, users can manually call import_insper_fonts()
  # or install fonts locally

  tryCatch({
    # Only attempt if showtext/sysfonts available
    if (requireNamespace("showtext", quietly = TRUE) &&
        requireNamespace("sysfonts", quietly = TRUE)) {

      # Try to import fonts silently (verbose = FALSE)
      import_insper_fonts(enable = TRUE, verbose = FALSE)
    }
  }, error = function(e) {
    # Silently fail - fonts will fall back to system defaults
    # Users can manually call import_insper_fonts() if needed
  })
}


#' @keywords internal
.onAttach <- function(libname, pkgname) {
  # Display startup message when package is attached
  packageStartupMessage(
    "insperplot ",
    utils::packageVersion("insperplot"),
    " loaded.\nFor best results, use Insper fonts: see ?import_insper_fonts or ?check_insper_fonts"
  )
}
