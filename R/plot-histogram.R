#' Insper Histogram
#'
#' Create histograms with formal bin selection methods using Insper's visual identity.
#' Implements Sturges, Freedman-Diaconis, and Scott algorithms for optimal bin width.
#'
#' @param data A data frame containing the data to plot
#' @param x Variable for x-axis (numeric)
#' @param fill Fill aesthetic.
#'   Can be:
#'   \itemize{
#'     \item A quoted color name/hex (e.g., `"blue"`, `"#FF0000"`) for static color
#'     \item A bare column name (e.g., `factor(cyl)`) for discrete grouping
#'     \item A continuous variable (e.g., `hp`) for gradient coloring (rare for histograms)
#'   }
#'   If `NULL` (default), uses Insper red.
#' @param palette Character. Color palette name for variable mappings.
#'   Options: "categorical", "main", "bright", "reds", "teals", etc.
#'   If NULL (default), uses "categorical". Only applies to variable mappings.
#' @param bins Numeric. Number of bins. Only used when bin_method = "manual"
#' @param bin_method Character. Bin selection method: "sturges", "fd" (Freedman-Diaconis),
#'   "scott", or "manual". Default is "sturges"
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
#' @examplesIf has_insper_fonts()
#' # Simple histogram with Sturges method
#' insper_histogram(mtcars, x = mpg)
#'
#' # Using Freedman-Diaconis method
#' insper_histogram(mtcars, x = mpg, bin_method = "fd")
#'
#' # Manual bin specification
#' insper_histogram(mtcars, x = mpg, bin_method = "manual", bins = 15)
#' @family plots
#' @seealso \code{\link{theme_insper}}, \code{\link{insper_density}}
#' @importFrom grDevices nclass.Sturges nclass.FD nclass.scott
#' @export
insper_histogram <- function(
  data,
  x,
  fill = NULL,
  palette = NULL,
  bins = NULL,
  bin_method = c("sturges", "fd", "scott", "manual"),
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

  # Smart detection for fill aesthetic
  fill_quo <- rlang::enquo(fill)
  fill_type <- detect_aesthetic_type(fill_quo, "fill", data)
  warn_palette_ignored(fill_type, palette, "fill")

  # Use default palette if not specified
  if (is.null(palette)) {
    palette <- "categorical"
  }

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

  # Build plot based on fill type
  if (fill_type$type == "missing") {
    # No fill specified - use default Insper red
    p <- ggplot2::ggplot(data, ggplot2::aes(x = {{ x }})) +
      ggplot2::geom_histogram(
        fill = get_insper_colors("reds1"),
        color = border_color,
        bins = n_bins,
        ...
      )
  } else if (fill_type$type == "static_color") {
    # Static color specified
    p <- ggplot2::ggplot(data, ggplot2::aes(x = {{ x }})) +
      ggplot2::geom_histogram(
        fill = fill_type$value,
        color = border_color,
        bins = n_bins,
        ...
      )
  } else {
    # Variable mapping (discrete or continuous)
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
      )

    # Apply appropriate scale
    if (fill_type$is_continuous) {
      p <- p + scale_fill_insper_c(palette = palette)
    } else {
      p <- p + scale_fill_insper_d(palette = palette)
    }
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
