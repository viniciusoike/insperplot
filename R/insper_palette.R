#' Get Insper Color Palette
#'
#' @param palette Character string indicating palette name
#' @param n Number of colors to return
#' @param type Type of palette: "discrete" or "continuous"
#' @param reverse Logical indicating whether to reverse palette
#' @return Vector of hex color codes
#' @family colors
#' @seealso \code{\link{show_insper_colors}}, \code{\link{show_insper_palette}}, \code{\link{scale_color_insper_d}}, \code{\link{scale_fill_insper_d}}
#' @export
#' @examples
#' insper_pal("main")
#' insper_pal("reds", n = 5)
#' insper_pal("red_teal")
insper_pal <- function(palette = "main", n = NULL, type = "discrete", reverse = FALSE) {

  if (!palette %in% names(insper_colors)) {
    cli::cli_abort("Palette {.val {palette}} not found. Available palettes: {.val {names(insper_colors)}}")
  }

  pal <- insper_colors[[palette]]

  if (reverse) pal <- rev(pal)

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
