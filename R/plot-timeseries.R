#' Insper Time Series Plot
#'
#' Create time series plots optimized for economic/business data using Insper's
#' visual identity. Automatically handles Date and POSIXct x-axis variables and
#' supports both discrete and continuous color mappings.
#'
#' @param data A data frame containing the data to plot
#' @param x Time variable (numeric, Date, or POSIXct)
#' @param y Value variable
#' @param color Color aesthetic for multiple lines. Accepts either:
#'   \itemize{
#'     \item A bare column name for variable mapping (e.g., \code{color = category})
#'     \item A quoted color string for static color (e.g., \code{color = "blue"})
#'     \item \code{NULL} (default) to use default Insper teal
#'   }
#'   When mapping a variable, the appropriate scale is automatically applied.
#' @param palette Character. Color palette for variable mappings. Default is "categorical".
#' @param line_width Numeric. Width of lines. Default is 0.8
#' @param add_points Logical. If TRUE, adds points to lines. Default is FALSE
#' @param ... Additional arguments passed to \code{ggplot2::geom_line()},
#'   allowing custom aesthetics like linetype, alpha, etc.
#' @return A ggplot2 object
#'
#' @examplesIf has_insper_fonts()
#' library(ggplot2)
#'
#' # Plot inflation over time
#' insper_timeseries(macro_series, x = date, y = ipca)
#'
#' # The color argument automatically detects the type of variable
#' insper_timeseries(macro_series, x = date, y = ipca, color = "#3CBFAE")
#'
#' # Grouped time series (discrete variable)
#' recent_data <- subset(fossil_fuel, year >= 1920)
#' insper_timeseries(recent_data, x = year, y = consumption, color = fuel)
#'
#' @family plots
#' @seealso \code{\link{theme_insper}}, \code{\link{scale_color_insper_d}}
#' @export
insper_timeseries <- function(
  data,
  x,
  y,
  color = NULL,
  palette = "categorical",
  line_width = 0.8,
  add_points = FALSE,
  ...
) {
  # Input validation with cli
  if (!is.data.frame(data)) {
    cli::cli_abort(c(
      "{.arg data} must be a data frame",
      "x" = "You supplied an object of class {.cls {class(data)}}"
    ))
  }

  # Smart detection for color
  color_quo <- rlang::enquo(color)
  color_type <- detect_aesthetic_type(color_quo, "color", data)

  # Warn if palette specified with static color
  warn_palette_ignored(color_type, palette, "color")

  # Initialize plot based on color type
  if (color_type$type == "missing") {
    # Default: Insper teal
    p <- ggplot2::ggplot(data, ggplot2::aes(x = {{ x }}, y = {{ y }})) +
      ggplot2::geom_line(
        color = get_insper_colors("teals1"),
        linewidth = line_width,
        ...
      )

    if (add_points) {
      p <- p +
        ggplot2::geom_point(color = get_insper_colors("teals1"), size = 1)
    }
  } else if (color_type$type == "static_color") {
    # User-specified static color
    p <- ggplot2::ggplot(data, ggplot2::aes(x = {{ x }}, y = {{ y }})) +
      ggplot2::geom_line(
        color = color_type$value,
        linewidth = line_width,
        ...
      )

    if (add_points) {
      p <- p +
        ggplot2::geom_point(color = color_type$value, size = 1)
    }
  } else {
    # Variable mapping - multiple lines
    p <- ggplot2::ggplot(
      data,
      ggplot2::aes(x = {{ x }}, y = {{ y }}, color = {{ color }})
    ) +
      ggplot2::geom_line(linewidth = line_width, ...)

    # Add appropriate color scale
    if (color_type$is_continuous) {
      p <- p + scale_color_insper_c(palette = palette)
    } else {
      p <- p + scale_color_insper_d(palette = palette)
    }

    if (add_points) {
      p <- p + ggplot2::geom_point(size = 1)
    }
  }

  p <- p +
    theme_insper() +
    ggplot2::theme(
      panel.grid.minor.x = ggplot2::element_blank()
    )

  return(p)
}
