#' Insper Area Plot
#'
#' Create area charts for time series data using Insper's visual identity.
#' Supports both single and grouped/stacked areas.
#'
#' @details
#' ## Smart Stacking Behavior
#'
#' By default (`stacked = NULL`), the function automatically detects whether to
#' stack areas based on context:
#' \itemize{
#'   \item When `fill` is a variable (e.g., `fill = category`): automatically
#'         creates stacked areas to show part-to-whole relationships
#'   \item When `fill` is missing or a static color: uses overlapping areas
#'         (stacking has no effect)
#' }
#'
#' You can override this behavior by explicitly setting `stacked = TRUE` (force
#' stacking) or `stacked = FALSE` (force overlapping, useful for comparing
#' distributions of different groups).
#'
#' ## Line Overlay
#'
#' By default, a line is drawn on top of each area (`add_line = TRUE`). This
#' helps emphasize trends and makes the areas more visually distinct. The line
#' color matches the fill color. Set `add_line = FALSE` for cleaner appearance
#' when comparing many groups.
#'
#' @param data A data frame containing the data to plot
#' @param x Time variable (numeric, Date, or POSIXct)
#' @param y Value variable
#' @param fill Fill aesthetic.
#'   Can be:
#'   \itemize{
#'     \item A quoted color name/hex (e.g., `"teal"`, `"#00BFFF"`) for static color
#'     \item A bare column name (e.g., `category`) for discrete grouping
#'     \item A continuous variable (e.g., `intensity`) for gradient coloring
#'   }
#'   If `NULL` (default), uses Insper teal. When a variable is mapped, it applies to
#'   both area fill and line color (if `add_line = TRUE`).
#' @param palette Character. Color palette name for variable mappings.
#'   Options: "categorical", "main", "bright", "reds", "teals", etc.
#'   If NULL (default), uses "categorical". Only applies to variable mappings.
#' @param stacked Logical. If TRUE and fill is provided, creates stacked areas.
#'   If NULL (default), automatically detects: stacks when `fill` is a variable
#'   mapping, otherwise uses overlapping areas. Set explicitly to FALSE to force
#'   overlapping areas even with fill mappings
#' @param area_alpha Numeric. Transparency of areas (0-1). Default is 0.9
#' @param fill_color Character. Hex color code for area when not using fill aesthetic.
#'   Default is Insper teal. (Deprecated: use `fill = "color"` instead)
#' @param add_line Logical. If TRUE, adds line on top of area. Default is TRUE
#' @param line_color Character. Hex color code for line when not using fill aesthetic.
#'   Default is darker Insper teal. (Deprecated: use in combination with `fill = "color"`)
#' @param line_width Numeric. Width of line. Default is 0.8
#' @param line_alpha Numeric. Transparency of line (0-1). Default is 1
#' @param zero Logical. If TRUE, adds a horizontal line at y = 0. Default is FALSE
#' @param ... Additional arguments passed to \code{ggplot2::geom_area()}
#' @return A ggplot2 object
#'
#' @examplesIf has_insper_fonts()
#' library(ggplot2)
#'
#' # Simple area plot - Coal consumption since 1900
#' coal_data <- subset(fossil_fuel, fuel == "Coal" & year >= 1900)
#' insper_area(coal_data, x = year, y = consumption)
#'
#' # Stacked area chart showing all fuels (automatically stacked when fill is provided)
#' recent_data <- subset(fossil_fuel, year >= 1950)
#' recent_data$fuel <- factor(recent_data$fuel, levels = c("Oil", "Gas", "Coal"))
#' insper_area(recent_data, x = year, y = consumption, fill = fuel) +
#'   labs(
#'     title = "Global Fossil Fuel Consumption",
#'     subtitle = "Primary energy consumption by fuel type (1950-present)",
#'     x = "Year",
#'     y = "Consumption (TWh)",
#'     fill = "Fuel Type"
#'   )
#'
#' # Force overlapping areas (comparing distributions)
#' insper_area(recent_data, x = year, y = consumption,
#'             fill = fuel, stacked = FALSE) +
#'   labs(
#'     title = "Comparing Fuel Consumption Trends",
#'     subtitle = "Overlapping areas show individual trajectories",
#'     x = "Year",
#'     y = "Consumption (TWh)",
#'     fill = "Fuel Type"
#'   )
#'
#' @family plots
#' @seealso \code{\link{theme_insper}}, \code{\link{scale_fill_insper_d}}, \code{\link{insper_timeseries}}
#' @export
insper_area <- function(
  data,
  x,
  y,
  fill = NULL,
  palette = NULL,
  stacked = NULL,
  area_alpha = 0.9,
  fill_color = get_insper_colors("teals1"),
  add_line = TRUE,
  line_color = get_insper_colors("teals3"),
  line_width = 0.8,
  line_alpha = 1,
  zero = FALSE,
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

  # Smart detection for stacked behavior
  # If stacked is NULL, auto-detect: stack when fill is a variable mapping
  has_fill_mapping <- fill_type$type == "variable_mapping"
  if (is.null(stacked)) {
    stacked <- has_fill_mapping
  }

  # Determine position
  position <- if (stacked && has_fill_mapping) "stack" else "identity"

  # Build plot based on fill type
  if (fill_type$type == "missing") {
    # No fill specified - use default Insper teal
    p <- ggplot2::ggplot(data, ggplot2::aes(x = {{ x }}, y = {{ y }})) +
      ggplot2::geom_area(fill = fill_color, alpha = area_alpha, ...)

    if (add_line) {
      p <- p +
        ggplot2::geom_line(
          color = line_color,
          linewidth = line_width,
          alpha = line_alpha
        )
    }
  } else if (fill_type$type == "static_color") {
    # Static color specified - use for both area and line
    p <- ggplot2::ggplot(data, ggplot2::aes(x = {{ x }}, y = {{ y }})) +
      ggplot2::geom_area(fill = fill_type$value, alpha = area_alpha, ...)

    if (add_line) {
      p <- p +
        ggplot2::geom_line(
          color = fill_type$value,
          linewidth = line_width,
          alpha = line_alpha
        )
    }
  } else {
    # Variable mapping - propagate to both fill and color
    p <- ggplot2::ggplot(
      data,
      ggplot2::aes(x = {{ x }}, y = {{ y }}, fill = {{ fill }})
    ) +
      ggplot2::geom_area(alpha = area_alpha, position = position, ...)

    # Apply appropriate fill scale
    if (fill_type$is_continuous) {
      p <- p + scale_fill_insper_c(palette = palette)
    } else {
      p <- p + scale_fill_insper_d(palette = palette)
    }

    # Add line with matching color mapping
    if (add_line) {
      p <- p +
        ggplot2::geom_line(
          ggplot2::aes(color = {{ fill }}),
          linewidth = line_width,
          alpha = line_alpha,
          position = position
        )

      # Apply appropriate color scale (same as fill)
      if (fill_type$is_continuous) {
        p <- p + scale_color_insper_c(palette = palette)
      } else {
        p <- p + scale_color_insper_d(palette = palette)
      }
    }
  }

  # Add line at zero if requested
  if (zero) {
    p <- p + ggplot2::geom_hline(yintercept = 0, linewidth = 1)
  }

  p <- p +
    theme_insper() +
    ggplot2::theme(
      panel.grid.minor.x = ggplot2::element_blank()
    )

  return(p)
}
