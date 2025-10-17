#' Insper Discrete Color Scale for ggplot2
#'
#' @param palette Character string indicating palette name
#' @param reverse Logical indicating whether to reverse palette
#' @param ... Additional arguments passed to ggplot2::discrete_scale()
#' @return ggplot2 scale object
#' @family scales
#' @seealso \code{\link{insper_pal}}, \code{\link{theme_insper}}, \code{\link{scale_color_insper_c}}
#' @importFrom ggplot2 discrete_scale
#' @importFrom scales manual_pal
#' @export
#' @examples
#' library(ggplot2)
#' ggplot(mtcars, aes(x = wt, y = mpg, color = factor(cyl))) +
#'   geom_point() +
#'   scale_color_insper_d()
scale_color_insper_d <- function(palette = "main", reverse = FALSE, ...) {
  ggplot2::discrete_scale(
    aesthetics = "colour",
    palette = scales::manual_pal(insper_pal(palette, reverse = reverse)),
    ...
  )
}

#' @rdname scale_color_insper_d
#' @export
scale_colour_insper_d <- scale_color_insper_d

#' @rdname scale_color_insper_d
#' @export
scale_fill_insper_d <- function(palette = "main", reverse = FALSE, ...) {
  ggplot2::discrete_scale(
    aesthetics = "fill",
    palette = scales::manual_pal(insper_pal(palette, reverse = reverse)),
    ...
  )
}


#' Insper Continuous Color Scale for ggplot2
#'
#' @param palette Character string indicating palette name
#' @param reverse Logical indicating whether to reverse palette
#' @param ... Additional arguments passed to ggplot2::scale_color_gradientn()
#' @return ggplot2 scale object
#' @family scales
#' @seealso \code{\link{insper_pal}}, \code{\link{theme_insper}}, \code{\link{scale_color_insper_d}}
#' @importFrom ggplot2 scale_color_gradientn
#' @export
#' @examples
#' library(ggplot2)
#' ggplot(mtcars, aes(x = wt, y = mpg, color = hp)) +
#'   geom_point() +
#'   scale_color_insper_c(palette = "teals")
scale_color_insper_c <- function(palette = "teals", reverse = FALSE, ...) {
  ggplot2::scale_color_gradientn(
    colours = insper_pal(palette, type = "continuous", reverse = reverse),
    ...
  )
}

#' @rdname scale_color_insper_c
#' @export
scale_colour_insper_c <- scale_color_insper_c

#' @rdname scale_color_insper_c
#' @importFrom ggplot2 scale_fill_gradientn
#' @export
scale_fill_insper_c <- function(palette = "teals", reverse = FALSE, ...) {
  ggplot2::scale_fill_gradientn(
    colours = insper_pal(palette, type = "continuous", reverse = reverse),
    ...
  )
}
