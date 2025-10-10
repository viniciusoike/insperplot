#' Get Insper Color Palette
#'
#' @param palette Character string indicating palette name
#' @param n Number of colors to return
#' @param type Type of palette: "discrete" or "continuous"
#' @param reverse Logical indicating whether to reverse palette
#' @return Vector of hex color codes
#' @family colors
#' @export
#' @examples
#' insper_pal("main")
#' insper_pal("reds", n = 5)
insper_pal <- function(palette = "primary", n = NULL, type = "discrete", reverse = FALSE) {

  if (!palette %in% names(insper_colors)) {
    stop("Palette not found. Available palettes: ", paste(names(insper_colors), collapse = ", "))
  }

  pal <- insper_colors[[palette]]

  if (reverse) pal <- rev(pal)

  if (is.null(n)) {
    n <- length(pal)
  }

  if (type == "discrete") {
    if (n > length(pal)) {
      warning("Not enough colors in palette. Recycling colors.")
      pal <- rep(pal, length.out = n)
    } else {
      pal <- pal[1:n]
    }
  } else {
    pal <- grDevices::colorRampPalette(pal)(n)
  }

  return(pal)
}
