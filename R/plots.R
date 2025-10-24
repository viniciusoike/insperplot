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
#' @examples
#' \dontrun{
#' # Simple bar plot with default color
#' insper_barplot(mtcars, x = cyl, y = mpg)
#'
#' # Static fill color
#' insper_barplot(mtcars, x = cyl, y = mpg, fill = "steelblue")
#'
#' # Grouped bar plot (variable mapping)
#' insper_barplot(mtcars, x = cyl, y = mpg, fill = gear)
#'
#' # Stacked bars
#' insper_barplot(mtcars, x = cyl, y = mpg, fill = gear, position = "stack")
#'
#' # With text labels
#' insper_barplot(mtcars, x = cyl, y = mpg, text = TRUE)
#'
#' # Horizontal bars (numeric x, categorical y)
#' df <- data.frame(category = letters[1:5], value = c(3, 5, 2, 8, 4))
#' insper_barplot(df, x = value, y = category)
#'
#' # Custom palette
#' insper_barplot(mtcars, x = cyl, y = mpg, fill = gear, palette = "bright")
#'
#' # Custom color and label formatting
#' insper_barplot(mtcars, x = cyl, y = mpg,
#'                fill = "#009491",
#'                label_formatter = format_num_br)
#' }
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
      ggplot2::geom_col(fill = get_insper_colors("reds1"), position = position, ...)

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

  p <- p + theme_insper() + ggplot2::theme(panel.grid.major.x = ggplot2::element_blank())

  return(p)
}

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
#' @examples
#' \dontrun{
#' # Simple scatter plot with default color
#' insper_scatterplot(mtcars, x = wt, y = mpg)
#'
#' # Static color
#' insper_scatterplot(mtcars, x = wt, y = mpg, color = "blue")
#'
#' # Discrete variable mapping
#' insper_scatterplot(mtcars, x = wt, y = mpg, color = factor(cyl))
#'
#' # Continuous variable mapping
#' insper_scatterplot(mtcars, x = wt, y = mpg, color = hp)
#'
#' # Custom palette
#' insper_scatterplot(mtcars, x = wt, y = mpg, color = factor(cyl), palette = "bright")
#'
#' # With smooth line
#' insper_scatterplot(mtcars, x = wt, y = mpg, add_smooth = TRUE)
#'
#' # Shape 21 with both color and fill (different variables)
#' insper_scatterplot(mtcars, x = wt, y = mpg,
#'                    color = factor(cyl),
#'                    fill = factor(gear),
#'                    shape = 21, stroke = 1.5)
#'
#' # Shape 21 with static color and mapped fill
#' insper_scatterplot(mtcars, x = wt, y = mpg,
#'                    color = "black",
#'                    fill = factor(cyl),
#'                    shape = 21)
#' }
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
      geom_params$color <- get_insper_colors("teals3")  # Default outline for filled shapes
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
      geom_params$color <- get_insper_colors("teals1")  # Default
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
#' @examples
#' \dontrun{
#' # Simple time series with default color
#' df <- data.frame(time = 1:10, value = rnorm(10))
#' insper_timeseries(df, x = time, y = value)
#'
#' # Static color
#' insper_timeseries(df, x = time, y = value, color = "darkblue")
#'
#' # Grouped time series (discrete variable)
#' df <- data.frame(
#'   time = rep(1:10, 2),
#'   value = rnorm(20),
#'   category = rep(c("A", "B"), each = 10)
#' )
#' insper_timeseries(df, x = time, y = value, color = category)
#'
#' # With date axis
#' df$date <- as.Date("2020-01-01") + df$time
#' insper_timeseries(df, x = date, y = value, color = category)
#'
#' # Custom palette
#' insper_timeseries(df, x = time, y = value, color = category, palette = "bright")
#'
#' # With points
#' insper_timeseries(df, x = time, y = value, color = category, add_points = TRUE)
#' }
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

#' Insper Box Plot
#'
#' Create box plots with optional jittered points and statistical annotations
#' using Insper's visual identity.
#'
#' @param data A data frame containing the data to plot
#' @param x Variable for x-axis (categorical)
#' @param y Variable for y-axis (numeric)
#' @param fill Variable for fill aesthetic (optional)
#' @param add_jitter Logical. If TRUE, adds jittered points. If NULL (default),
#'   automatically enables jitter when the largest group has <100 observations.
#' @param add_notch Logical. If TRUE, creates notched boxplot. Default is FALSE
#' @param box_alpha Numeric. Transparency of boxes (0-1). Default is 0.8
#' @param ... Additional arguments passed to \code{ggplot2::geom_boxplot()}
#' @return A ggplot2 object
#'
#' @examples
#' \dontrun{
#' # Simple boxplot
#' insper_boxplot(iris, x = Species, y = Sepal.Length)
#'
#' # With fill aesthetic
#' insper_boxplot(iris, x = Species, y = Sepal.Length, fill = Species)
#'
#' # Notched boxplot without jitter
#' insper_boxplot(iris, x = Species, y = Sepal.Length,
#'                add_notch = TRUE, add_jitter = FALSE)
#' }
#'
#' @family plots
#' @seealso \code{\link{theme_insper}}, \code{\link{scale_fill_insper_d}}
#' @export
insper_boxplot <- function(
  data,
  x,
  y,
  fill = NULL,
  add_jitter = NULL,
  add_notch = FALSE,
  box_alpha = 0.8,
  ...
) {
  # Input validation with cli
  if (!is.data.frame(data)) {
    cli::cli_abort(c(
      "{.arg data} must be a data frame",
      "x" = "You supplied an object of class {.cls {class(data)}}"
    ))
  }

  # Check if fill was provided using rlang
  has_fill <- !rlang::quo_is_null(rlang::enquo(fill))

  # Smart default for add_jitter: enable only if <100 obs per group
  if (is.null(add_jitter)) {
    x_quo <- rlang::enquo(x)
    x_vals <- rlang::eval_tidy(x_quo, data)

    # Count observations per group
    group_counts <- table(x_vals)
    max_group_size <- max(group_counts)

    # Auto-enable jitter if all groups have <100 observations
    add_jitter <- max_group_size < 100
  }

  # Initialize plot
  if (!has_fill) {
    p <- ggplot2::ggplot(data, ggplot2::aes(x = {{ x }}, y = {{ y }})) +
      ggplot2::geom_boxplot(
        fill = get_insper_colors("teals2"),
        alpha = box_alpha,
        notch = add_notch,
        ...
      )
  } else {
    p <- ggplot2::ggplot(
      data,
      ggplot2::aes(x = {{ x }}, y = {{ y }}, fill = {{ fill }})
    ) +
      ggplot2::geom_boxplot(alpha = box_alpha, notch = add_notch, ...) +
      scale_fill_insper_d()
  }

  # Add jittered points if requested
  if (add_jitter) {
    p <- p +
      ggplot2::geom_jitter(
        width = 0.2,
        alpha = 0.5,
        color = get_insper_colors("gray_med")
      )
  }

  p <- p + theme_insper()

  return(p)
}

#' Insper Heatmap
#'
#' Create correlation matrices and heatmaps using Insper's visual identity.
#' Automatically detects whether data is a matrix or pre-melted long format.
#'
#' @param data Data frame (melted with Var1, Var2, value columns) or
#'   correlation matrix
#' @param show_values Logical. If TRUE, displays values on tiles. Default is TRUE
#' @param value_color Character. Color for value text. Default is "white"
#' @param value_size Numeric. Size of value text. Default is 3
#' @param palette Character. Palette name for fill scale. Default is "diverging"
#' @param ... Additional arguments passed to \code{ggplot2::geom_tile()}
#' @return A ggplot2 object
#'
#' @examples
#' \dontrun{
#' # From correlation matrix
#' cor_mat <- cor(mtcars[, 1:4])
#' insper_heatmap(cor_mat)
#'
#' # Hide values
#' insper_heatmap(cor_mat, show_values = FALSE)
#'
#' # Custom palette
#' insper_heatmap(cor_mat, palette = "red_teal")
#'
#' # From melted data frame
#' melted <- data.frame(
#'   Var1 = rep(c("A", "B", "C"), each = 3),
#'   Var2 = rep(c("X", "Y", "Z"), 3),
#'   value = runif(9, -1, 1)
#' )
#' insper_heatmap(melted)
#' }
#'
#' @family plots
#' @seealso \code{\link{theme_insper}}, \code{\link{scale_fill_insper_d}}
#' @export
insper_heatmap <- function(
  data,
  show_values = FALSE,
  value_color = "white",
  value_size = 3,
  palette = "diverging",
  ...
) {
  # Input validation with cli
  if (!is.data.frame(data) && !is.matrix(data)) {
    cli::cli_abort(c(
      "{.arg data} must be a data frame or matrix",
      "x" = "You supplied an object of class {.cls {class(data)}}"
    ))
  }

  # Check if data is already in melted format
  is_melted <- is.data.frame(data) &&
    all(c("Var1", "Var2", "value") %in% names(data))

  if (!is_melted) {
    # Convert matrix/data frame to long format
    if (!is.matrix(data)) {
      if (!all(sapply(data, is.numeric))) {
        cli::cli_abort(c(
          "{.arg data} must contain only numeric columns when not pre-melted",
          "i" = "Or provide data in melted format with columns: Var1, Var2, value"
        ))
      }
      data <- as.matrix(data)
    }

    melted_data <- expand.grid(
      Var1 = rownames(data) %||% seq_len(nrow(data)),
      Var2 = colnames(data) %||% seq_len(ncol(data))
    )
    melted_data$value <- as.vector(data)
  } else {
    melted_data <- data
  }

  # Create plot
  p <- ggplot2::ggplot(
    melted_data,
    ggplot2::aes(x = Var1, y = Var2, fill = value)
  ) +
    ggplot2::geom_tile(color = "white", linewidth = 0.5, ...) +
    scale_fill_insper_c(palette = palette) +
    theme_insper() +
    ggplot2::theme(
      axis.text.x = ggplot2::element_text(angle = 45, hjust = 1),
      axis.title = ggplot2::element_blank(),
      panel.grid = ggplot2::element_blank()
    ) +
    ggplot2::labs(fill = "Value")

  # Add value labels if requested
  if (show_values) {
    p <- p +
      ggplot2::geom_text(
        ggplot2::aes(label = round(value, 2)),
        color = value_color,
        size = value_size
      )
  }

  return(p)
}

#' Insper Area Plot
#'
#' Create area charts for time series data using Insper's visual identity.
#' Supports both single and grouped/stacked areas.
#'
#' @param data A data frame containing the data to plot
#' @param x Time variable (numeric, Date, or POSIXct)
#' @param y Value variable
#' @param fill Variable for fill aesthetic (optional)
#' @param stacked Logical. If TRUE and fill is provided, creates stacked areas.
#'   Default is FALSE
#' @param area_alpha Numeric. Transparency of areas (0-1). Default is 1
#' @param fill_color Character. Hex color code for area when not using fill aesthetic.
#'   Default is Insper teal
#' @param add_line Logical. If TRUE, adds line on top of area. Default is TRUE
#' @param line_color Character. Hex color code for line when not using fill aesthetic.
#'   Default is darker Insper teal
#' @param line_width Numeric. Width of line. Default is 1
#' @param line_alpha Numeric. Transparency of line (0-1). Default is 1
#' @param zero Logical. If TRUE, adds a horizontal line at y = 0. Default is FALSE
#' @param ... Additional arguments passed to \code{ggplot2::geom_area()}
#' @return A ggplot2 object
#'
#' @examples
#' \dontrun{
#' # Simple area plot
#' df <- data.frame(time = 1:50, value = cumsum(rnorm(50)))
#' insper_area(df, x = time, y = value)
#'
#' # Grouped areas
#' df <- data.frame(
#'   time = rep(1:50, 3),
#'   value = c(cumsum(rnorm(50)), cumsum(rnorm(50)), cumsum(rnorm(50))),
#'   group = rep(c("A", "B", "C"), each = 50)
#' )
#' insper_area(df, x = time, y = value, fill = group)
#'
#' # Stacked areas
#' insper_area(df, x = time, y = value, fill = group, stacked = TRUE)
#'
#' # Custom colors and line width
#' insper_area(df, x = time, y = value,
#'             fill_color = get_insper_colors("reds1"),
#'             line_color = get_insper_colors("reds3"),
#'             line_width = 1.5,
#'             zero = TRUE)
#' }
#'
#' @family plots
#' @seealso \code{\link{theme_insper}}, \code{\link{scale_fill_insper_d}}, \code{\link{insper_timeseries}}
#' @export
insper_area <- function(
  data,
  x,
  y,
  fill = NULL,
  stacked = FALSE,
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

  # Check if fill was provided using rlang
  has_fill <- !rlang::quo_is_null(rlang::enquo(fill))

  # Determine position
  position <- if (stacked && has_fill) "stack" else "identity"

  # Initialize plot
  if (!has_fill) {
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
  } else {
    p <- ggplot2::ggplot(
      data,
      ggplot2::aes(x = {{ x }}, y = {{ y }}, fill = {{ fill }})
    ) +
      ggplot2::geom_area(alpha = area_alpha, position = position, ...) +
      scale_fill_insper_d()

    if (add_line) {
      p <- p +
        ggplot2::geom_line(
          ggplot2::aes(color = {{ fill }}),
          linewidth = line_width,
          alpha = line_alpha,
          position = position
        ) +
        scale_color_insper_d()
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

#' Insper Violin Plot
#'
#' Create violin plots to visualize distributions using Insper's visual identity.
#' Optionally overlay boxplots and/or jittered points.
#'
#' @param data A data frame containing the data to plot
#' @param x Variable for x-axis (categorical)
#' @param y Variable for y-axis (numeric)
#' @param fill Variable for fill aesthetic (optional)
#' @param show_boxplot Logical. If TRUE, overlays a boxplot. Default is FALSE
#' @param show_points Logical. If TRUE, adds jittered points. Default is FALSE
#' @param violin_alpha Numeric. Transparency of violins (0-1). Default is 0.7
#' @param ... Additional arguments passed to \code{ggplot2::geom_violin()}
#' @return A ggplot2 object
#'
#' @examples
#' \dontrun{
#' # Simple violin plot
#' insper_violin(iris, x = Species, y = Sepal.Length)
#'
#' # With fill aesthetic and points
#' insper_violin(iris, x = Species, y = Sepal.Length,
#'               fill = Species, show_points = TRUE)
#'
#' # With boxplot overlay
#' insper_violin(iris, x = Species, y = Sepal.Length,
#'               show_boxplot = TRUE)
#' }
#'
#' @family plots
#' @seealso \code{\link{theme_insper}}, \code{\link{scale_fill_insper_d}}, \code{\link{insper_boxplot}}
#' @export
insper_violin <- function(
  data,
  x,
  y,
  fill = NULL,
  show_boxplot = FALSE,
  show_points = FALSE,
  violin_alpha = 0.7,
  ...
) {
  # Input validation with cli
  if (!is.data.frame(data)) {
    cli::cli_abort(c(
      "{.arg data} must be a data frame",
      "x" = "You supplied an object of class {.cls {class(data)}}"
    ))
  }

  # Check if fill was provided using rlang
  has_fill <- !rlang::quo_is_null(rlang::enquo(fill))

  # Initialize plot
  if (!has_fill) {
    p <- ggplot2::ggplot(data, ggplot2::aes(x = {{ x }}, y = {{ y }})) +
      ggplot2::geom_violin(
        fill = get_insper_colors("teals2"),
        alpha = violin_alpha,
        ...
      )
  } else {
    p <- ggplot2::ggplot(
      data,
      ggplot2::aes(x = {{ x }}, y = {{ y }}, fill = {{ fill }})
    ) +
      ggplot2::geom_violin(alpha = violin_alpha, ...) +
      scale_fill_insper_d()
  }

  # Add boxplot if requested
  if (show_boxplot) {
    p <- p + ggplot2::geom_boxplot(width = 0.2, alpha = 0.5, outlier.shape = NA)
  }

  # Add jittered points if requested
  if (show_points) {
    p <- p +
      ggplot2::geom_jitter(
        width = 0.1,
        alpha = 0.5,
        color = get_insper_colors("gray_med")
      )
  }

  p <- p + theme_insper()

  return(p)
}


#' Insper Histogram
#'
#' Create histograms with formal bin selection methods using Insper's visual identity.
#' Implements Sturges, Freedman-Diaconis, and Scott algorithms for optimal bin width.
#'
#' @param data A data frame containing the data to plot
#' @param x Variable for x-axis (numeric)
#' @param fill Variable for fill aesthetic (optional)
#' @param bins Numeric. Number of bins. Only used when bin_method = "manual"
#' @param bin_method Character. Bin selection method: "sturges", "fd" (Freedman-Diaconis),
#'   "scott", or "manual". Default is "sturges"
#' @param fill_color Character. Hex color for bars when not using fill aesthetic.
#'   Default is Insper red.
#' @param border_color Character. Color for bar borders. Default is "white"
#' @param zero Logical. If TRUE, adds a horizontal line at y = 0. Default is TRUE
#' @param ... Additional arguments passed to \code{ggplot2::geom_histogram()}
#' @return A ggplot2 object
#'
#' @details
#' Bin selection methods:
#' \itemize{
#'   \item **Sturges**: \eqn{k = \lceil \log_2(n) + 1 \rceil}. Works well for normal distributions.
#'   \item **Freedman-Diaconis**: Uses IQR to determine bin width. Robust to outliers.
#'   \item **Scott**: Uses standard deviation. Optimal for normal distributions.
#'   \item **Manual**: Specify exact number of bins with the `bins` parameter.
#' }
#'
#' @examples
#' \dontrun{
#' # Simple histogram with Sturges method
#' insper_histogram(mtcars, x = mpg)
#'
#' # Using Freedman-Diaconis method
#' insper_histogram(mtcars, x = mpg, bin_method = "fd")
#'
#' # Manual bin specification
#' insper_histogram(mtcars, x = mpg, bin_method = "manual", bins = 15)
#'
#' # Grouped histogram
#' insper_histogram(mtcars, x = mpg, fill = factor(cyl))
#' }
#'
#' @family plots
#' @seealso \code{\link{theme_insper}}, \code{\link{insper_density}}
#' @importFrom grDevices nclass.Sturges nclass.FD nclass.scott
#' @export
insper_histogram <- function(
  data,
  x,
  fill = NULL,
  bins = NULL,
  bin_method = c("sturges", "fd", "scott", "manual"),
  fill_color = get_insper_colors("reds1"),
  border_color = "white",
  zero = TRUE,
  ...
) {
  # Input validation with cli
  if (!is.data.frame(data)) {
    cli::cli_abort(c(
      "{.arg data} must be a data frame",
      "x" = "You supplied an object of class {.cls {class(data)}}"
    ))
  }

  bin_method <- match.arg(bin_method)

  if (bin_method == "manual" && is.null(bins)) {
    cli::cli_abort(c(
      "{.arg bins} must be specified when bin_method = 'manual'",
      "i" = "Set a number of bins, e.g., bins = 30"
    ))
  }

  # Check if fill was provided using rlang
  has_fill <- !rlang::quo_is_null(rlang::enquo(fill))

  # Extract x values for bin calculation
  x_quo <- rlang::enquo(x)
  x_vals <- rlang::eval_tidy(x_quo, data)

  # Calculate number of bins based on method
  if (bin_method == "sturges") {
    n_bins <- nclass.Sturges(x_vals)
  } else if (bin_method == "fd") {
    n_bins <- nclass.FD(x_vals)
  } else if (bin_method == "scott") {
    n_bins <- nclass.scott(x_vals)
  } else {
    # manual
    n_bins <- bins
  }

  # Initialize plot
  if (!has_fill) {
    p <- ggplot2::ggplot(data, ggplot2::aes(x = {{ x }})) +
      ggplot2::geom_histogram(
        fill = fill_color,
        color = border_color,
        bins = n_bins,
        ...
      )
  } else {
    p <- ggplot2::ggplot(
      data,
      ggplot2::aes(x = {{ x }}, fill = {{ fill }})
    ) +
      ggplot2::geom_histogram(
        color = border_color,
        bins = n_bins,
        position = "identity",
        alpha = 0.7,
        ...
      ) +
      scale_fill_insper_d()
  }

  # Add line at zero if requested
  if (zero) {
    p <- p + ggplot2::geom_hline(yintercept = 0, linewidth = 1)
  }

  # Apply theme and scale
  p <- p +
    ggplot2::scale_y_continuous(
      expand = ggplot2::expansion(mult = c(0, 0.05))
    ) +
    theme_insper()

  return(p)
}


#' Insper Density Plot
#'
#' Create density plots to visualize distributions using Insper's visual identity.
#' Supports grouped densities with automatic color assignment.
#'
#' @param data A data frame containing the data to plot
#' @param x Variable for x-axis (numeric)
#' @param fill Variable for fill/group aesthetic (optional)
#' @param fill_color Character. Hex color for density area when not using fill aesthetic.
#'   Default is Insper teal.
#' @param line_color Character. Color for density line. Default is darker teal.
#' @param alpha Numeric. Transparency of density area (0-1). Default is 0.6
#' @param bandwidth Numeric. Bandwidth for density estimation. Default is NULL (automatic).
#' @param adjust Numeric. Adjustment multiplier for bandwidth. Default is 1.
#' @param kernel Character. Kernel for density estimation. Default is "gaussian".
#' @param ... Additional arguments passed to \code{ggplot2::geom_density()}
#' @return A ggplot2 object
#'
#' @examples
#' \dontrun{
#' # Simple density plot
#' insper_density(mtcars, x = mpg)
#'
#' # Grouped density plot
#' insper_density(mtcars, x = mpg, fill = factor(cyl))
#'
#' # Adjust bandwidth
#' insper_density(mtcars, x = mpg, adjust = 0.5)
#' }
#'
#' @family plots
#' @seealso \code{\link{theme_insper}}, \code{\link{insper_histogram}}
#' @export
insper_density <- function(
  data,
  x,
  fill = NULL,
  fill_color = get_insper_colors("teals1"),
  line_color = get_insper_colors("teals3"),
  alpha = 0.6,
  bandwidth = NULL,
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

  # Check if fill was provided using rlang
  has_fill <- !rlang::quo_is_null(rlang::enquo(fill))

  # Initialize plot
  if (!has_fill) {
    p <- ggplot2::ggplot(data, ggplot2::aes(x = {{ x }})) +
      ggplot2::geom_density(
        fill = fill_color,
        color = line_color,
        alpha = alpha,
        bw = bandwidth,
        adjust = adjust,
        kernel = kernel,
        ...
      )
  } else {
    p <- ggplot2::ggplot(
      data,
      ggplot2::aes(x = {{ x }}, fill = {{ fill }}, color = {{ fill }})
    ) +
      ggplot2::geom_density(
        alpha = alpha,
        bw = bandwidth,
        adjust = adjust,
        kernel = kernel,
        ...
      ) +
      scale_fill_insper_d() +
      scale_color_insper_d()
  }

  # Apply theme and scale
  p <- p +
    ggplot2::scale_y_continuous(
      expand = ggplot2::expansion(mult = c(0, 0.05))
    ) +
    theme_insper()

  return(p)
}
