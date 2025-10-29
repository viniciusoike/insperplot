#' Insper Density Plot
#'
#' Create density plots to visualize distributions using Insper's visual identity.
#' Supports grouped densities with automatic color assignment.
#'
#' @param data A data frame containing the data to plot
#' @param x Variable for x-axis (numeric)
#' @param fill Fill aesthetic.
#'   Can be:
#'   \itemize{
#'     \item A quoted color name/hex (e.g., `"purple"`, `"#9B59B6"`) for static color
#'     \item A bare column name (e.g., `factor(cyl)`) for discrete grouping
#'     \item A continuous variable (e.g., `gear`) for gradient coloring (rare for density)
#'   }
#'   If `NULL` (default), uses Insper teal. When a variable is mapped, it applies to
#'   both density fill and line color.
#' @param palette Character. Color palette name for variable mappings.
#'   Options: "categorical", "main", "bright", "reds", "teals", etc.
#'   If NULL (default), uses "categorical". Only applies to variable mappings.
#' @param fill_color Character. Hex color for density area when not using fill aesthetic.
#'   Default is Insper teal. (Deprecated: use `fill = "color"` instead)
#' @param line_color Character. Color for density line. Default is darker teal.
#'   (Deprecated: use in combination with `fill = "color"`)
#' @param alpha Numeric. Transparency of density area (0-1). Default is 0.6
#' @param bw Numeric or character. Bandwidth for density estimation.
#'   Can be a numeric value or a bandwidth selector name ("nrd0", "nrd", "ucv", "bcv", "SJ").
#'   Default is NULL which uses ggplot2's default ("nrd0").
#' @param adjust Numeric. Adjustment multiplier for bandwidth. Default is 1.
#' @param kernel Character. Kernel for density estimation. Default is "gaussian".
#' @param ... Additional arguments passed to \code{ggplot2::geom_density()}
#' @return A ggplot2 object
#'
#' @examplesIf has_insper_fonts()
#' # Simple density plot (default teal)
#' insper_density(macro_series, x = ipca)
#'
#' # Static color
#' insper_density(macro_series, x = ipca, fill = "purple")
#'
#' # Grouped density plot (discrete variable)
#' insper_density(iris, x = Sepal.Length, fill = Species)
#' @family plots
#' @seealso \code{\link{theme_insper}}, \code{\link{insper_histogram}}
#' @export
insper_density <- function(
  data,
  x,
  fill = NULL,
  palette = NULL,
  fill_color = get_insper_colors("teals1"),
  line_color = get_insper_colors("teals3"),
  alpha = 0.6,
  bw = NULL,
  adjust = 1,
  kernel = "gaussian",
  ...
) {
  # Input validation with cli
  if (!is.data.frame(data)) {
    cli::cli_abort(c(
      "{.arg data} must be a data frame",
      "x" = "You supplied an object of class {.cls {class(data)}}"
    ))
  }

  # Smart detection for fill aesthetic
  fill_quo <- rlang::enquo(fill)
  fill_type <- detect_aesthetic_type(fill_quo, "fill", data)
  warn_palette_ignored(fill_type, palette, "fill")

  # Use default palette if not specified
  if (is.null(palette)) {
    palette <- "categorical"
  }

  # Build plot based on fill type
  if (fill_type$type == "missing") {
    # No fill specified - use default Insper teal
    p <- ggplot2::ggplot(data, ggplot2::aes(x = {{ x }})) +
      ggplot2::geom_density(
        fill = fill_color,
        color = line_color,
        alpha = alpha,
        bw = bw,
        adjust = adjust,
        kernel = kernel,
        ...
      )
  } else if (fill_type$type == "static_color") {
    # Static color specified - use for both fill and line
    p <- ggplot2::ggplot(data, ggplot2::aes(x = {{ x }})) +
      ggplot2::geom_density(
        fill = fill_type$value,
        color = fill_type$value,
        alpha = alpha,
        bw = bw,
        adjust = adjust,
        kernel = kernel,
        ...
      )
  } else {
    # Variable mapping - propagate to both fill and color
    p <- ggplot2::ggplot(
      data,
      ggplot2::aes(x = {{ x }}, fill = {{ fill }}, color = {{ fill }})
    ) +
      ggplot2::geom_density(
        alpha = alpha,
        bw = bw,
        adjust = adjust,
        kernel = kernel,
        ...
      )

    # Apply appropriate scales
    if (fill_type$is_continuous) {
      p <- p +
        scale_fill_insper_c(palette = palette) +
        scale_color_insper_c(palette = palette)
    } else {
      p <- p +
        scale_fill_insper_d(palette = palette) +
        scale_color_insper_d(palette = palette)
    }
  }

  # Apply theme and scale
  p <- p +
    ggplot2::scale_y_continuous(
      expand = ggplot2::expansion(mult = c(0, 0.05))
    ) +
    theme_insper()

  return(p)
}
