#' Insper Box Plot
#'
#' Create box plots with optional jittered points and statistical annotations
#' using Insper's visual identity.
#'
#' @param data A data frame containing the data to plot
#' @param x Variable for x-axis (categorical)
#' @param y Variable for y-axis (numeric)
#' @param fill Fill aesthetic. Accepts either:
#'   \itemize{
#'     \item A bare column name for variable mapping (e.g., \code{fill = Species})
#'     \item A quoted color string for static fill (e.g., \code{fill = "lightblue"})
#'     \item \code{NULL} (default) to use default Insper teal
#'   }
#' @param palette Character. Color palette for variable mappings. Default is "categorical".
#' @param add_jitter Logical. If TRUE, adds jittered points. If NULL (default),
#'   automatically enables jitter when the largest group has <100 observations.
#' @param add_notch Logical. If TRUE, creates notched boxplot. Default is FALSE
#' @param box_alpha Numeric. Transparency of boxes (0-1). Default is 0.8
#' @param ... Additional arguments passed to \code{ggplot2::geom_boxplot()}
#' @return A ggplot2 object
#'
#' @examplesIf has_insper_fonts()
#' # Simple boxplot with default fill
#' insper_boxplot(iris, x = Species, y = Sepal.Length)
#'
#' # Static fill color
#' insper_boxplot(iris, x = Species, y = Sepal.Length, fill = "#F15A22")
#'
#' # Variable fill mapping
#' insper_boxplot(iris, x = Species, y = Sepal.Length, fill = Species)
#'
#' # Boxplot without jitter
#' insper_boxplot(iris, x = Species, y = Sepal.Length, add_jitter = FALSE)
#' @family plots
#' @seealso \code{\link{theme_insper}}, \code{\link{scale_fill_insper_d}}
#' @export
insper_boxplot <- function(
  data,
  x,
  y,
  fill = NULL,
  palette = "categorical",
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

  # Smart detection for fill
  fill_quo <- rlang::enquo(fill)
  fill_type <- detect_aesthetic_type(fill_quo, "fill", data)

  # Warn if palette specified with static fill
  warn_palette_ignored(fill_type, palette, "fill")

  # Smart default for add_jitter: enable only if <100 obs per group
  if (is.null(add_jitter)) {
    x_quo <- rlang::enquo(x)
    x_vals <- rlang::eval_tidy(x_quo, rlang::as_data_mask(data))

    # Count observations per group
    group_counts <- table(x_vals)
    max_group_size <- max(group_counts)

    # Auto-enable jitter if all groups have <100 observations
    add_jitter <- max_group_size < 100
  }

  # Initialize plot based on fill type
  if (fill_type$type == "missing") {
    # Default: Insper teal
    p <- ggplot2::ggplot(data, ggplot2::aes(x = {{ x }}, y = {{ y }})) +
      ggplot2::geom_boxplot(
        fill = get_insper_colors("teals2"),
        alpha = box_alpha,
        notch = add_notch,
        ...
      )
  } else if (fill_type$type == "static_color") {
    # User-specified static color
    p <- ggplot2::ggplot(data, ggplot2::aes(x = {{ x }}, y = {{ y }})) +
      ggplot2::geom_boxplot(
        fill = fill_type$value,
        alpha = box_alpha,
        notch = add_notch,
        ...
      )
  } else {
    # Variable mapping - boxplots are inherently discrete
    p <- ggplot2::ggplot(
      data,
      ggplot2::aes(x = {{ x }}, y = {{ y }}, fill = {{ fill }})
    ) +
      ggplot2::geom_boxplot(alpha = box_alpha, notch = add_notch, ...) +
      scale_fill_insper_d(palette = palette)
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
