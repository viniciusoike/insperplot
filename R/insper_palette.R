#' Get Insper Color Palette (Internal)
#'
#' Internal function used by scale_*_insper_*() functions to extract palette colors.
#' Users should use \code{\link{list_palettes}} and \code{\link{show_insper_palette}}
#' to explore palettes, and scale functions to apply them.
#'
#' @param palette Character string indicating palette name
#' @param n Number of colors to return
#' @param type Type of palette: "discrete" or "continuous"
#' @param reverse Logical indicating whether to reverse palette
#' @return Vector of hex color codes
#' @family colors
#' @seealso \code{\link{list_palettes}}, \code{\link{show_insper_palette}}, \code{\link{scale_color_insper_d}}, \code{\link{scale_fill_insper_d}}
#' @keywords internal
#' @examples
#' \dontrun{
#' # Internal function - not exported
#' # Users should use scale functions instead
#' ggplot(mtcars, aes(wt, mpg, color = factor(cyl))) +
#'   geom_point() +
#'   scale_color_insper_d("main")
#' }
insper_pal <- function(palette = "main", n = NULL, type = "discrete", reverse = FALSE) {

  if (!palette %in% names(insper_palettes)) {
    cli::cli_abort("Palette {.val {palette}} not found. Available palettes: {.val {names(insper_palettes)}}")
  }

  pal <- insper_palettes[[palette]]

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
