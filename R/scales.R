#' Insper Color Scales for ggplot2
#'
#' @param palette Character string indicating palette name
#' @param discrete Logical indicating whether to use discrete scale
#' @param reverse Logical indicating whether to reverse palette
#' @param ... Additional arguments passed to ggplot2 scale functions
#' @return ggplot2 scale object
#' @importFrom ggplot2 discrete_scale scale_fill_gradientn
#' @importFrom scales manual_pal
#' @export
#' @examples
#' library(ggplot2)
#' ggplot(mtcars, aes(x = wt, y = mpg, color = factor(cyl))) +
#'   geom_point() +
#'   scale_color_insper()
scale_color_insper <- function(palette = "main", discrete = TRUE, reverse = FALSE, ...) {

  if (discrete) {
    ggplot2::discrete_scale(
      "colour", "insper",
      scales::manual_pal(insper_pal(palette, reverse = reverse)),
      ...
    )
  } else {
    ggplot2::scale_color_gradientn(
      colours = insper_pal(palette, type = "continuous", reverse = reverse),
      ...
    )
  }
}

#' @rdname scale_color_insper
#' @export
scale_colour_insper <- scale_color_insper

#' @rdname scale_color_insper
#' @export
scale_fill_insper <- function(palette = "main", discrete = TRUE, reverse = FALSE, ...) {

  if (discrete) {
    ggplot2::discrete_scale(
      "fill", "insper",
      scales::manual_pal(insper_pal(palette, reverse = reverse)),
      ...
    )
  } else {
    ggplot2::scale_fill_gradientn(
      colours = insper_pal(palette, type = "continuous", reverse = reverse),
      ...
    )
  }
}
