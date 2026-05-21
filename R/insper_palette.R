#' @keywords internal
#' @noRd
insper_pal <- function(
  palette = "main",
  n = NULL,
  type = "discrete",
  reverse = FALSE
) {
  if (!palette %in% names(insper_palettes)) {
    cli::cli_abort(
      "Palette {.val {palette}} not found. Available palettes: {.val {names(insper_palettes)}}"
    )
  }

  pal <- insper_palettes[[palette]]

  if (reverse) {
    pal <- rev(pal)
  }

  if (is.null(n)) {
    n <- length(pal)
  }

  if (type == "discrete") {
    if (n > length(pal)) {
      cli::cli_warn("Not enough colors in palette. Recycling colors.")
      pal <- rep(pal, length.out = n)
    } else {
      pal <- pal[1:n]
    }
  } else {
    pal <- grDevices::colorRampPalette(pal)(n)
  }

  return(pal)
}
