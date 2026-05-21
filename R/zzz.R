# Package hooks for startup/load events

#' @keywords internal
.onAttach <- function(libname, pkgname) {
  packageStartupMessage(
    "insperplot ",
    utils::packageVersion("insperplot"),
    " loaded.\n",
    "Font setup: run setup_insper_fonts() or import_insper_fonts()"
  )
}
