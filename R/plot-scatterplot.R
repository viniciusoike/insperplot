#' Insper Scatter Plot
#'
#' Create scatter plots with regression lines and confidence intervals using
#' Insper's visual identity. Supports both color and fill aesthetics for
#' maximum flexibility with different point shapes.
#'
#' @param data A data frame containing the data to plot
#' @param x Variable for x-axis
#' @param y Variable for y-axis
#' @param color Color aesthetic. Accepts either:
#'   \itemize{
#'     \item A bare column name for variable mapping (e.g., \code{color = Species})
#'     \item A quoted color string for static color (e.g., \code{color = "blue"})
#'     \item \code{NULL} (default) to use default Insper teal
#'   }
#'   When mapping a variable, the appropriate scale is automatically applied.
#' @param fill Fill aesthetic (for shapes 21-25 with fill interiors). Accepts either:
#'   \itemize{
#'     \item A bare column name for variable mapping (e.g., \code{fill = Species})
#'     \item A quoted color string for static fill (e.g., \code{fill = "lightblue"})
#'     \item \code{NULL} (default) - no fill mapping
#'   }
#' @param palette Character. Color palette for variable mappings. Default is "categorical".
#' @param add_smooth Logical. If TRUE, adds a regression line. Default is FALSE
#' @param smooth_method Character. Smoothing method ("lm", "loess", "gam", "glm"). Default is "lm"
#' @param point_size Numeric. Size of points. Default is 2
#' @param point_alpha Numeric. Transparency of points (0-1). Default is 1
#' @param ... Additional arguments passed to \code{ggplot2::geom_point()},
#'   allowing custom aesthetics like shape, stroke, etc.
#' @return A ggplot2 object
#'
#' @details
#' This function supports two types of point shapes:
#' \itemize{
#'   \item **Solid shapes (16-20)**: Only use \code{color} aesthetic for point color
#'   \item **Outlined shapes (21-25)**: Use both \code{color} (outline) and \code{fill} (interior)
#' }
#'
#' For outlined shapes, you can map different variables to color and fill, or use
#' static colors for fine-grained control.
#'
#' @examplesIf has_insper_fonts()
#' # Simple scatter plot with default color
#' insper_scatterplot(mtcars, x = wt, y = mpg)
#'
#' # Discrete variable mapping
#' insper_scatterplot(mtcars, x = wt, y = mpg, color = factor(cyl))
#'
#' # With smooth line
#' insper_scatterplot(mtcars, x = wt, y = mpg, add_smooth = TRUE)
#'
#' # ... arguments always passed to geom_point()
#' insper_scatterplot(mtcars, x = wt, y = mpg, size = 3, alpha = 0.5)
#'
#' # Shape 21 with static color and mapped fill
#' insper_scatterplot(mtcars, x = wt, y = mpg,
#'                    color = "white",
#'                    fill = factor(cyl),
#'                    shape = 21)
#'
#' @family plots
#' @seealso \code{\link{theme_insper}}, \code{\link{scale_color_insper_d}}, \code{\link{scale_fill_insper_d}}
#' @export
insper_scatterplot <- function(
  data,
  x,
  y,
  color = NULL,
  fill = NULL,
  palette = "categorical",
  add_smooth = FALSE,
  smooth_method = "lm",
  point_size = 2,
  point_alpha = 1,
  ...
) {
  # Input validation with cli
  if (!is.data.frame(data)) {
    cli::cli_abort(c(
      "{.arg data} must be a data frame",
      "x" = "You supplied an object of class {.cls {class(data)}}"
    ))
  }

  if (!smooth_method %in% c("lm", "loess", "gam", "glm")) {
    cli::cli_abort(c(
      "{.arg smooth_method} must be one of: {.val lm}, {.val loess}, {.val gam}, or {.val glm}",
      "x" = "You supplied: {.val {smooth_method}}"
    ))
  }

  # Smart detection for color and fill
  color_quo <- rlang::enquo(color)
  fill_quo <- rlang::enquo(fill)

  color_type <- detect_aesthetic_type(color_quo, "color", data)
  fill_type <- detect_aesthetic_type(fill_quo, "fill", data)

  # Warn if palette specified with static aesthetics
  if (color_type$type == "static_color" && fill_type$type == "static_color") {
    warn_palette_ignored(color_type, palette, "color")
  }

  # Build base plot
  p <- ggplot2::ggplot(data, ggplot2::aes(x = {{ x }}, y = {{ y }}))

  # Determine which aesthetics to map
  has_color_mapping <- color_type$type == "variable_mapping"
  has_fill_mapping <- fill_type$type == "variable_mapping"

  # Build aesthetic mapping
  if (has_color_mapping && has_fill_mapping) {
    # Both color and fill are variable mappings
    p <- p +
      ggplot2::geom_point(
        ggplot2::aes(color = {{ color }}, fill = {{ fill }}),
        size = point_size,
        alpha = point_alpha,
        ...
      )

    # Add scales based on variable types
    if (color_type$is_continuous) {
      p <- p + scale_color_insper_c(palette = palette)
    } else {
      p <- p + scale_color_insper_d(palette = palette)
    }

    if (fill_type$is_continuous) {
      p <- p + scale_fill_insper_c(palette = palette)
    } else {
      p <- p + scale_fill_insper_d(palette = palette)
    }
  } else if (has_color_mapping) {
    # Only color is variable mapping
    geom_params <- list(size = point_size, alpha = point_alpha)
    if (fill_type$type == "static_color") {
      geom_params$fill <- fill_type$value
    }

    p <- p +
      ggplot2::geom_point(
        ggplot2::aes(color = {{ color }}),
        size = geom_params$size,
        alpha = geom_params$alpha,
        fill = geom_params$fill,
        ...
      )

    # Add appropriate color scale
    if (color_type$is_continuous) {
      p <- p + scale_color_insper_c(palette = palette)
    } else {
      p <- p + scale_color_insper_d(palette = palette)
    }
  } else if (has_fill_mapping) {
    # Only fill is variable mapping
    geom_params <- list(size = point_size, alpha = point_alpha)
    if (color_type$type == "static_color") {
      geom_params$color <- color_type$value
    } else {
      geom_params$color <- get_insper_colors("teals3") # Default outline for filled shapes
    }

    p <- p +
      ggplot2::geom_point(
        ggplot2::aes(fill = {{ fill }}),
        size = geom_params$size,
        alpha = geom_params$alpha,
        color = geom_params$color,
        ...
      )

    # Add appropriate fill scale
    if (fill_type$is_continuous) {
      p <- p + scale_fill_insper_c(palette = palette)
    } else {
      p <- p + scale_fill_insper_d(palette = palette)
    }
  } else {
    # Neither is variable mapping - use static colors
    geom_params <- list(size = point_size, alpha = point_alpha)

    if (color_type$type == "static_color") {
      geom_params$color <- color_type$value
    } else {
      geom_params$color <- get_insper_colors("teals1") # Default
    }

    if (fill_type$type == "static_color") {
      geom_params$fill <- fill_type$value
    }

    p <- p +
      ggplot2::geom_point(
        color = geom_params$color,
        fill = geom_params$fill,
        size = geom_params$size,
        alpha = geom_params$alpha,
        ...
      )
  }

  # Add smooth line if requested
  if (add_smooth) {
    p <- p +
      ggplot2::geom_smooth(
        method = smooth_method,
        color = get_insper_colors("oranges1"),
        fill = get_insper_colors("oranges1"),
        alpha = 0.2
      )
  }

  p <- p + theme_insper()

  return(p)
}
