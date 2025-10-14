# Package hooks for startup/load events

#' @keywords internal
.onLoad <- function(libname, pkgname) {
  # Modern approach: Do NOT automatically enable showtext_auto()
  # This avoids DPI conflicts and follows 2025 R graphics best practices
  # Users should install fonts locally and use ragg device for best results

  # Set package option to track recommended setup
  options(insperplot.fonts_loaded = FALSE)
}


#' @keywords internal
.onAttach <- function(libname, pkgname) {
  # Display startup message when package is attached
  packageStartupMessage(
    "insperplot ",
    utils::packageVersion("insperplot"),
    " loaded.\n",
    "Font setup: ?setup_insper_fonts | Device setup: ?use_ragg_device"
  )
}
