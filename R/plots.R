#' Create a Bar Plot with Insper Styling
#'
#' This function creates a customized bar plot using ggplot2 with Insper's
#' visual identity. It supports grouped bars, text labels, and automatic ordering.
#'
#' @param data A data frame containing the data to plot
#' @param x <[`data-masked`][ggplot2::aes_eval]> Column name for x-axis
#' @param y <[`data-masked`][ggplot2::aes_eval]> Column name for y-axis
#' @param fill_var <[`data-masked`][ggplot2::aes_eval]> Column name for fill aesthetic (creates grouped/stacked bars).
#'   If NULL, uses single_color for all bars.
#' @param single_color Character. Hex color code for bars when not using fill_var.
#'   Default is Insper red.
#' @param position Position adjustment for bars. Options: "dodge", "stack",
#'   "fill", "identity". Default is "dodge"
#' @param zero Logical. If TRUE, adds a horizontal line at y = 0. Default is TRUE
#' @param text Logical. If TRUE, adds value labels on bars. Default is FALSE
#' @param palette Character. Color palette name for grouped bars.
#'   Default is "categorical"
#' @param text_size Numeric. Size of text labels. Default is 4
#' @param text_color Character. Color of text labels. Default is "black"
#' @param label_formatter Function. Formatter for text labels. Default is scales::comma
#' @param ... Additional arguments passed to scale_fill_insper()
#'
#' @return A ggplot2 object
#'
#' @examples
#' \dontrun{
#' # Simple bar plot (categorical x, numeric y)
#' insper_barplot(mtcars, x = cyl, y = mpg)
#'
#' # Bar plot with swapped axes (numeric x, categorical y)
#' df <- data.frame(category = letters[1:5], value = c(3, 5, 2, 8, 4))
#' insper_barplot(df, x = value, y = category)
#'
#' # Grouped bar plot
#' insper_barplot(mtcars, x = cyl, y = mpg, fill_var = gear)
#'
#' # With text labels
#' insper_barplot(mtcars, x = cyl, y = mpg, text = TRUE)
#'
#' # Custom color and label formatting
#' insper_barplot(mtcars, x = cyl, y = mpg,
#'                single_color = insper_col("teals1"),
#'                label_formatter = format_num_br)
#' }
#'
#' @family plots
#' @seealso \code{\link{theme_insper}}, \code{\link{scale_fill_insper}}
#' @importFrom ggplot2 aes geom_col
#' @export
insper_barplot <- function(
  data,
  x,
  y,
  fill_var = NULL,
  single_color = insper_col("reds1"),
  position = "dodge",
  zero = TRUE,
  text = FALSE,
  palette = "categorical",
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

  # Check if fill_var was provided using rlang
  has_fill <- !rlang::quo_is_null(rlang::enquo(fill_var))

  # Initialize plot
  if (!has_fill) {
    # Single color bars
    p <- ggplot2::ggplot(data, ggplot2::aes(x = {{ x }}, y = {{ y }})) +
      ggplot2::geom_col(fill = single_color)
  } else {
    # Grouped bars with fill aesthetic
    p <- ggplot2::ggplot(
      data,
      ggplot2::aes(x = {{ x }}, y = {{ y }}, fill = {{ fill_var }})
    ) +
      ggplot2::geom_col(position = position) +
      scale_fill_insper(palette = palette, ...)
  }

  # Add horizontal line at zero if requested
  if (zero) {
    p <- p + ggplot2::geom_hline(yintercept = 0, linewidth = 1)
  }

  # Add text labels if requested
  if (text) {
    if (!has_fill) {
      # Simple text labels
      p <- p +
        ggplot2::geom_text(
          ggplot2::aes(label = label_formatter({{ y }}, accuracy = 0.1)),
          vjust = -0.5,
          hjust = 0.5,
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
          vjust = -0.5,
          hjust = 0.5,
          size = text_size,
          color = text_color
        )
    }
  }

  # Apply y-axis scale
  p <- p +
    ggplot2::scale_y_continuous(
      expand = ggplot2::expansion(mult = c(0, 0.1)),
      labels = scales::comma_format()
    ) +
    theme_insper()

  return(p)
}

#' Insper Scatter Plot
#'
#' Create scatter plots with regression lines and confidence intervals using
#' Insper's visual identity.
#'
#' @param data A data frame containing the data to plot
#' @param x <[`data-masked`][ggplot2::aes_eval]> Variable for x-axis
#' @param y <[`data-masked`][ggplot2::aes_eval]> Variable for y-axis
#' @param color <[`data-masked`][ggplot2::aes_eval]> Variable for color aesthetic (optional)
#' @param add_smooth Logical. If TRUE, adds a regression line. Default is TRUE
#' @param smooth_method Character. Smoothing method ("lm", "loess", "gam"). Default is "lm"
#' @param point_size Numeric. Size of points. Default is 2
#' @param point_alpha Numeric. Transparency of points (0-1). Default is 0.7
#' @return A ggplot2 object
#'
#' @examples
#' \dontrun{
#' # Simple scatter plot
#' insper_scatterplot(mtcars, x = wt, y = mpg)
#'
#' # Colored by variable
#' insper_scatterplot(mtcars, x = wt, y = mpg, color = factor(cyl))
#'
#' # Without smooth line
#' insper_scatterplot(mtcars, x = wt, y = mpg, add_smooth = FALSE)
#'
#' # With loess smoothing
#' insper_scatterplot(mtcars, x = wt, y = mpg, smooth_method = "loess")
#' }
#'
#' @family plots
#' @seealso \code{\link{theme_insper}}, \code{\link{scale_color_insper}}
#' @export
insper_scatterplot <- function(
  data,
  x,
  y,
  color = NULL,
  add_smooth = TRUE,
  smooth_method = "lm",
  point_size = 2,
  point_alpha = 0.7
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

  # Check if color was provided using rlang
  has_color <- !rlang::quo_is_null(rlang::enquo(color))

  # Initialize plot
  if (!has_color) {
    p <- ggplot2::ggplot(data, ggplot2::aes(x = {{ x }}, y = {{ y }})) +
      ggplot2::geom_point(
        color = insper_col("teals1"),
        size = point_size,
        alpha = point_alpha
      )
  } else {
    p <- ggplot2::ggplot(
      data,
      ggplot2::aes(x = {{ x }}, y = {{ y }}, color = {{ color }})
    ) +
      ggplot2::geom_point(size = point_size, alpha = point_alpha) +
      scale_color_insper()
  }

  # Add smooth line if requested
  if (add_smooth) {
    p <- p +
      ggplot2::geom_smooth(
        method = smooth_method,
        color = insper_col("oranges1"),
        fill = insper_col("oranges1"),
        alpha = 0.2
      )
  }

  p <- p + theme_insper()

  return(p)
}

#' Insper Time Series Plot
#'
#' Create time series plots optimized for economic/business data using Insper's
#' visual identity. Automatically handles Date and POSIXct x-axis variables.
#'
#' @param data A data frame containing the data to plot
#' @param x <[`data-masked`][ggplot2::aes_eval]> Time variable (numeric, Date, or POSIXct)
#' @param y <[`data-masked`][ggplot2::aes_eval]> Value variable
#' @param group <[`data-masked`][ggplot2::aes_eval]> Grouping variable for multiple lines (optional)
#' @param line_width Numeric. Width of lines. Default is 1.2
#' @param add_points Logical. If TRUE, adds points to lines. Default is FALSE
#' @return A ggplot2 object
#'
#' @examples
#' \dontrun{
#' # Simple time series
#' df <- data.frame(time = 1:10, value = rnorm(10))
#' insper_timeseries(df, x = time, y = value)
#'
#' # Grouped time series
#' df <- data.frame(
#'   time = rep(1:10, 2),
#'   value = rnorm(20),
#'   group = rep(c("A", "B"), each = 10)
#' )
#' insper_timeseries(df, x = time, y = value, group = group)
#'
#' # With date axis
#' df$date <- as.Date("2020-01-01") + df$time
#' insper_timeseries(df, x = date, y = value)
#' }
#'
#' @family plots
#' @seealso \code{\link{theme_insper}}, \code{\link{scale_color_insper}}
#' @export
insper_timeseries <- function(
  data,
  x,
  y,
  group = NULL,
  line_width = 0.8,
  add_points = FALSE
) {
  # Input validation with cli
  if (!is.data.frame(data)) {
    cli::cli_abort(c(
      "{.arg data} must be a data frame",
      "x" = "You supplied an object of class {.cls {class(data)}}"
    ))
  }

  # Check if group was provided using rlang
  has_group <- !rlang::quo_is_null(rlang::enquo(group))

  # Initialize plot
  if (!has_group) {
    p <- ggplot2::ggplot(data, ggplot2::aes(x = {{ x }}, y = {{ y }})) +
      ggplot2::geom_line(color = insper_col("teals1"), linewidth = line_width)

    if (add_points) {
      p <- p + ggplot2::geom_point(color = insper_col("teals1"), size = 1)
    }
  } else {
    p <- ggplot2::ggplot(
      data,
      ggplot2::aes(x = {{ x }}, y = {{ y }}, color = {{ group }})
    ) +
      ggplot2::geom_line(linewidth = line_width) +
      scale_color_insper()

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
#' @param x <[`data-masked`][ggplot2::aes_eval]> Variable for x-axis (categorical)
#' @param y <[`data-masked`][ggplot2::aes_eval]> Variable for y-axis (numeric)
#' @param fill <[`data-masked`][ggplot2::aes_eval]> Variable for fill aesthetic (optional)
#' @param add_jitter Logical. If TRUE, adds jittered points. Default is TRUE
#' @param add_notch Logical. If TRUE, creates notched boxplot. Default is FALSE
#' @param box_alpha Numeric. Transparency of boxes (0-1). Default is 0.7
#' @return A ggplot2 object
#'
#' @examples
#' \dontrun{
#' # Simple boxplot
#' insper_boxplot(mtcars, x = factor(cyl), y = mpg)
#'
#' # With fill aesthetic
#' insper_boxplot(mtcars, x = factor(cyl), y = mpg, fill = factor(cyl))
#'
#' # Notched boxplot without jitter
#' insper_boxplot(mtcars, x = factor(cyl), y = mpg,
#'                add_notch = TRUE, add_jitter = FALSE)
#'
#' # Vertical boxplot
#' insper_boxplot(mtcars, x = factor(cyl), y = mpg, flip = FALSE)
#' }
#'
#' @family plots
#' @seealso \code{\link{theme_insper}}, \code{\link{scale_fill_insper}}
#' @export
insper_boxplot <- function(
  data,
  x,
  y,
  fill = NULL,
  add_jitter = TRUE,
  add_notch = FALSE,
  box_alpha = 0.8
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
      ggplot2::geom_boxplot(
        fill = insper_col("teals2"),
        alpha = box_alpha,
        notch = add_notch
      )
  } else {
    p <- ggplot2::ggplot(
      data,
      ggplot2::aes(x = {{ x }}, y = {{ y }}, fill = {{ fill }})
    ) +
      ggplot2::geom_boxplot(alpha = box_alpha, notch = add_notch) +
      scale_fill_insper()
  }

  # Add jittered points if requested
  if (add_jitter) {
    p <- p +
      ggplot2::geom_jitter(
        width = 0.2,
        alpha = 0.5,
        color = insper_col("gray_med")
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
#' @param palette Character. Palette name for fill scale. Default is "diverging_insper"
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
#' insper_heatmap(cor_mat, palette = "diverging_red_teal")
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
#' @seealso \code{\link{theme_insper}}, \code{\link{scale_fill_insper}}
#' @export
insper_heatmap <- function(
  data,
  show_values = TRUE,
  value_color = "white",
  value_size = 3,
  palette = "diverging_insper"
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
    ggplot2::geom_tile(color = "white", linewidth = 0.5) +
    scale_fill_insper(palette = palette, discrete = FALSE) +
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
#' Insper Lollipop Plot
#'
#' Create lollipop charts (combination of geom_segment and geom_point) using
#' Insper's visual identity. Ideal for displaying ranked categorical data.
#'
#' @param data A data frame containing the data to plot
#' @param x <[`data-masked`][ggplot2::aes_eval]> Variable for x-axis (categorical)
#' @param y <[`data-masked`][ggplot2::aes_eval]> Variable for y-axis (numeric)
#' @param color <[`data-masked`][ggplot2::aes_eval]> Variable for color aesthetic (optional)
#' @param sorted Logical. If TRUE, sorts by y value. Default is FALSE
#' @param point_size Numeric. Size of points. Default is 4
#' @param line_width Numeric. Width of segments. Default is 1
#' @return A ggplot2 object
#'
#' @examples
#' \dontrun{
#' # Simple vertical lollipop plot
#' df <- data.frame(category = letters[1:10], value = runif(10, 0, 100))
#' insper_lollipop(df, x = category, y = value)
#'
#' # Sorted by value
#' insper_lollipop(df, x = category, y = value, sorted = TRUE)
#'
#' # With color aesthetic
#' df$group <- rep(c("A", "B"), 5)
#' insper_lollipop(df, x = category, y = value, color = group)
#'
#' # For horizontal orientation, swap x and y then add coord_flip()
#' insper_lollipop(df, x = category, y = value) + ggplot2::coord_flip()
#' }
#'
#' @family plots
#' @seealso \code{\link{theme_insper}}, \code{\link{scale_color_insper}}
#' @export
insper_lollipop <- function(
  data,
  x,
  y,
  color = NULL,
  sorted = FALSE,
  point_size = 4,
  line_width = 1
) {
  # Input validation with cli
  if (!is.data.frame(data)) {
    cli::cli_abort(c(
      "{.arg data} must be a data frame",
      "x" = "You supplied an object of class {.cls {class(data)}}"
    ))
  }

  # Check if color was provided using rlang
  has_color <- !rlang::quo_is_null(rlang::enquo(color))

  # Sort if requested
  if (sorted) {
    data <- data |>
      dplyr::arrange({{ y }})
  }

  # Initialize plot
  if (!has_color) {
    p <- ggplot2::ggplot(data, ggplot2::aes(x = {{ x }}, y = {{ y }})) +
      ggplot2::geom_segment(
        ggplot2::aes(xend = {{ x }}, yend = 0),
        color = insper_col("teals1"),
        linewidth = line_width
      ) +
      ggplot2::geom_point(
        color = insper_col("reds1"),
        size = point_size
      )
  } else {
    p <- ggplot2::ggplot(
      data,
      ggplot2::aes(x = {{ x }}, y = {{ y }}, color = {{ color }})
    ) +
      ggplot2::geom_segment(
        ggplot2::aes(xend = {{ x }}, yend = 0),
        linewidth = line_width
      ) +
      ggplot2::geom_point(size = point_size) +
      scale_color_insper()
  }

  p <- p + theme_insper()

  return(p)
}

#' Insper Area Plot
#'
#' Create area charts for time series data using Insper's visual identity.
#' Supports both single and grouped/stacked areas.
#'
#' @param data A data frame containing the data to plot
#' @param x <[`data-masked`][ggplot2::aes_eval]> Time variable (numeric, Date, or POSIXct)
#' @param y <[`data-masked`][ggplot2::aes_eval]> Value variable
#' @param fill <[`data-masked`][ggplot2::aes_eval]> Variable for fill aesthetic (optional)
#' @param stacked Logical. If TRUE and fill is provided, creates stacked areas.
#'   Default is FALSE
#' @param area_alpha Numeric. Transparency of areas (0-1). Default is 0.6
#' @param add_line Logical. If TRUE, adds line on top of area. Default is TRUE
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
#' }
#'
#' @family plots
#' @seealso \code{\link{theme_insper}}, \code{\link{scale_fill_insper}}, \code{\link{insper_timeseries}}
#' @export
insper_area <- function(
  data,
  x,
  y,
  fill = NULL,
  stacked = FALSE,
  area_alpha = 1,
  add_line = TRUE
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
      ggplot2::geom_area(fill = insper_col("teals1"), alpha = area_alpha)

    if (add_line) {
      p <- p + ggplot2::geom_line(color = insper_col("teals3"), linewidth = 1)
    }
  } else {
    p <- ggplot2::ggplot(
      data,
      ggplot2::aes(x = {{ x }}, y = {{ y }}, fill = {{ fill }})
    ) +
      ggplot2::geom_area(alpha = area_alpha, position = position) +
      scale_fill_insper()

    if (add_line) {
      p <- p +
        ggplot2::geom_line(
          ggplot2::aes(color = {{ fill }}),
          linewidth = 0.8,
          position = position
        ) +
        scale_color_insper()
    }
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
#' @param x <[`data-masked`][ggplot2::aes_eval]> Variable for x-axis (categorical)
#' @param y <[`data-masked`][ggplot2::aes_eval]> Variable for y-axis (numeric)
#' @param fill <[`data-masked`][ggplot2::aes_eval]> Variable for fill aesthetic (optional)
#' @param show_boxplot Logical. If TRUE, overlays a boxplot. Default is TRUE
#' @param show_points Logical. If TRUE, adds jittered points. Default is FALSE
#' @param violin_alpha Numeric. Transparency of violins (0-1). Default is 0.7
#' @return A ggplot2 object
#'
#' @examples
#' \dontrun{
#' # Simple violin plot
#' insper_violin(mtcars, x = factor(cyl), y = mpg)
#'
#' # With fill aesthetic and points
#' insper_violin(mtcars, x = factor(cyl), y = mpg,
#'               fill = factor(cyl), show_points = TRUE)
#'
#' # Vertical violin without boxplot
#' insper_violin(mtcars, x = factor(cyl), y = mpg,
#'               show_boxplot = FALSE, flip = FALSE)
#' }
#'
#' @family plots
#' @seealso \code{\link{theme_insper}}, \code{\link{scale_fill_insper}}, \code{\link{insper_boxplot}}
#' @export
insper_violin <- function(
  data,
  x,
  y,
  fill = NULL,
  show_boxplot = TRUE,
  show_points = FALSE,
  violin_alpha = 0.7
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
      ggplot2::geom_violin(fill = insper_col("teals2"), alpha = violin_alpha)
  } else {
    p <- ggplot2::ggplot(
      data,
      ggplot2::aes(x = {{ x }}, y = {{ y }}, fill = {{ fill }})
    ) +
      ggplot2::geom_violin(alpha = violin_alpha) +
      scale_fill_insper()
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
        color = insper_col("gray_med")
      )
  }

  p <- p + theme_insper()

  return(p)
}
