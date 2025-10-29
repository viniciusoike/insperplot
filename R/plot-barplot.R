#' Create a Bar Plot with Insper Styling
#'
#' This function creates a customized bar plot using ggplot2 with Insper's
#' visual identity. Supports grouped bars, text labels, and automatic orientation.
#'
#' @param data A data frame containing the data to plot
#' @param x Column name for x-axis
#' @param y Column name for y-axis
#' @param fill Fill aesthetic. Accepts either:
#'   \itemize{
#'     \item A bare column name for variable mapping (e.g., \code{fill = gear})
#'     \item A quoted color string for static fill (e.g., \code{fill = "blue"})
#'     \item \code{NULL} (default) to use default Insper red
#'   }
#'   When mapping a variable, creates grouped or stacked bars based on \code{position}.
#' @param position Position adjustment for bars. Options: "dodge", "stack",
#'   "fill", "identity". Default is "dodge"
#' @param palette Character. Color palette for variable mappings. Default is "categorical".
#' @param zero Logical. If TRUE, adds a horizontal line at y = 0. Default is TRUE
#' @param text Logical. If TRUE, adds value labels on bars. Default is FALSE
#' @param text_size Numeric. Size of text labels. Default is 4
#' @param text_color Character. Color of text labels. Default is "black"
#' @param label_formatter Function. Formatter for text labels. Default is scales::comma
#' @param ... Additional arguments passed to \code{ggplot2::geom_col()},
#'   allowing custom aesthetics like width, alpha, etc.
#'
#' @return A ggplot2 object
#'
#' @details
#' The function automatically detects bar orientation based on variable types:
#' \itemize{
#'   \item **Vertical bars**: When x is categorical and y is numeric (default)
#'   \item **Horizontal bars**: When x is numeric and y is categorical
#' }
#'
#' Text labels and zero lines automatically adjust to the detected orientation.
#'
#' @examplesIf has_insper_fonts()
#' # Simple bar plot with default color
#' insper_barplot(mtcars, x = factor(cyl), y = mpg)
#'
#' # With text labels showing values
#' insper_barplot(mtcars, x = factor(cyl), y = mpg, text = TRUE)
#'
#' @family plots
#' @seealso \code{\link{theme_insper}}, \code{\link{scale_fill_insper_d}}
#' @importFrom ggplot2 aes geom_col
#' @export
insper_barplot <- function(
  data,
  x,
  y,
  fill = NULL,
  position = "dodge",
  palette = "categorical",
  zero = TRUE,
  text = FALSE,
  text_size = 4,
  text_color = "black",
  label_formatter = scales::comma,
  ...
) {
  # Input validation with cli
  if (!is.data.frame(data)) {
    cli::cli_abort(c(
      "{.arg data} must be a data frame",
      "x" = "You supplied an object of class {.cls {class(data)}}",
      "i" = "Convert your data to a data frame with {.fn as.data.frame}"
    ))
  }

  if (!position %in% c("dodge", "stack", "fill", "identity")) {
    cli::cli_abort(c(
      "{.arg position} must be one of: {.val dodge}, {.val stack}, {.val fill}, or {.val identity}",
      "x" = "You supplied: {.val {position}}"
    ))
  }

  # Smart detection for fill
  fill_quo <- rlang::enquo(fill)
  fill_type <- detect_aesthetic_type(fill_quo, "fill", data)

  # Warn if palette specified with static fill
  warn_palette_ignored(fill_type, palette, "fill")

  # Initialize plot based on fill type
  if (fill_type$type == "missing") {
    # Default: Insper red
    p <- ggplot2::ggplot(data, ggplot2::aes(x = {{ x }}, y = {{ y }})) +
      ggplot2::geom_col(
        fill = get_insper_colors("reds1"),
        position = position,
        ...
      )
  } else if (fill_type$type == "static_color") {
    # User-specified static color
    p <- ggplot2::ggplot(data, ggplot2::aes(x = {{ x }}, y = {{ y }})) +
      ggplot2::geom_col(fill = fill_type$value, position = position, ...)
  } else {
    # Variable mapping - grouped/stacked bars
    # Note: Bar plots are inherently discrete (grouping by categories)
    # So we always use discrete scale regardless of variable type
    p <- ggplot2::ggplot(
      data,
      ggplot2::aes(x = {{ x }}, y = {{ y }}, fill = {{ fill }})
    ) +
      ggplot2::geom_col(position = position, ...) +
      scale_fill_insper_d(palette = palette)
  }

  # Detect orientation by checking if x or y is numeric in the data
  # Capture the expressions once
  x_quo <- rlang::enquo(x)
  y_quo <- rlang::enquo(y)

  # Evaluate in the data context
  x_vals <- rlang::eval_tidy(x_quo, rlang::as_data_mask(data))
  y_vals <- rlang::eval_tidy(y_quo, rlang::as_data_mask(data))

  # Check if numeric (not factor, character, or other discrete types)
  x_is_numeric <- is.numeric(x_vals) && !is.factor(x_vals)
  y_is_numeric <- is.numeric(y_vals) && !is.factor(y_vals)

  # Determine if we have horizontal bars (numeric x, categorical y)
  # If both are numeric or both are categorical, default to vertical (y is value axis)
  is_horizontal <- x_is_numeric && !y_is_numeric

  # Add line at zero if requested (horizontal or vertical depending on orientation)
  if (zero) {
    if (is_horizontal) {
      # Horizontal bars: vertical line at x = 0
      p <- p + ggplot2::geom_vline(xintercept = 0, linewidth = 1)
    } else {
      # Vertical bars: horizontal line at y = 0
      p <- p + ggplot2::geom_hline(yintercept = 0, linewidth = 1)
    }
  }

  # Add text labels if requested
  if (text) {
    # Adjust text position based on orientation
    text_vjust <- if (is_horizontal) 0.5 else -0.5
    text_hjust <- if (is_horizontal) -0.1 else 0.5

    if (fill_type$type != "variable_mapping") {
      # Simple text labels (no grouping)
      p <- p +
        ggplot2::geom_text(
          ggplot2::aes(label = label_formatter({{ y }}, accuracy = 0.1)),
          vjust = text_vjust,
          hjust = text_hjust,
          size = text_size,
          color = text_color
        )
    } else {
      # Grouped text labels
      dodge_width <- if (position == "dodge") 0.9 else 0
      p <- p +
        ggplot2::geom_text(
          ggplot2::aes(label = label_formatter({{ y }}, accuracy = 0.1)),
          position = ggplot2::position_dodge(width = dodge_width),
          vjust = text_vjust,
          hjust = text_hjust,
          size = text_size,
          color = text_color
        )
    }
  }

  # Apply continuous scale to the numeric axis
  if (is_horizontal) {
    # Horizontal bars: scale x-axis
    p <- p +
      ggplot2::scale_x_continuous(
        expand = ggplot2::expansion(mult = c(0, 0.1)),
        labels = scales::comma_format()
      )
  } else {
    # Vertical bars: scale y-axis
    p <- p +
      ggplot2::scale_y_continuous(
        expand = ggplot2::expansion(mult = c(0, 0.1)),
        labels = scales::comma_format()
      )
  }

  p <- p +
    theme_insper() +
    ggplot2::theme(panel.grid.major.x = ggplot2::element_blank())

  return(p)
}
