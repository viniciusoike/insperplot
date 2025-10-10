#' Create a Bar Plot with Insper Styling
#'
#' This function creates a customized bar plot using ggplot2 with Insper's
#' visual identity. It supports grouped bars, text labels, coordinate flipping,
#' and automatic ordering.
#'
#' @param .dat A data frame containing the data to plot
#' @param x Column name for x-axis (categorical variable)
#' @param y Column name for y-axis (numeric variable)
#' @param fill Column name for fill aesthetic or color for bars. Default is insper_col("reds1")
#' @param group Column name for grouping variable (creates grouped/stacked bars)
#' @param position Position adjustment for bars. Options: "dodge", "stack",
#'   "fill", "identity". Default is "dodge"
#' @param zero Logical. If TRUE, adds a horizontal line at y = 0. Default is TRUE
#' @param text Logical. If TRUE, adds value labels on bars. Default is FALSE
#' @param flip Logical. If TRUE, creates horizontal bars. Default is FALSE
#' @param palette Character. Color palette name for grouped bars.
#'   Default is "categorical"
#' @param text_size Numeric. Size of text labels. Default is 4
#' @param text_color Character. Color of text labels. Default is "black"
#' @param single_color Character. Color for single bars when no grouping. Currently unused.
#' @param ... Additional arguments passed to scale_fill_insper()
#'
#' @return A ggplot2 object
#'
#' @examples
#' \dontrun{
#' # Simple bar plot
#' insper_barplot(mtcars, x = cyl, y = mpg)
#'
#' # Grouped bar plot
#' insper_barplot(mtcars, x = cyl, y = mpg, group = gear)
#'
#' # Horizontal bars with text labels
#' insper_barplot(mtcars, x = cyl, y = mpg, flip = TRUE, text = TRUE)
#' }
#'
#' @family plots
#' @seealso \code{\link{theme_insper}}, \code{\link{scale_fill_insper}}
#' @importFrom ggplot2 aes geom_col
#' @export
insper_barplot <- function(
    .dat,
    x,
    y,
    fill = insper_col("reds1"),
    group = NULL,
    position = "dodge",
    zero = TRUE,
    text = FALSE,
    flip = FALSE,
    palette = "categorical",
    text_size = 4,
    text_color = "black",
    single_color = NULL,
    ...) {

  # Input validation
  if (!is.data.frame(.dat)) {
    stop("'.dat' must be a data frame")
  }

  if (!position %in% c("dodge", "stack", "fill", "identity")) {
    stop("'position' must be one of: 'dodge', 'stack', 'fill', 'identity'")
  }

  # Initialize plot
  p <- ggplot2::ggplot()

  if (missing(group)) {
    p <- p +
      geom_col(
        data = .dat,
        aes(x = {{ x }}, y = {{ y }}),
        fill = fill
      )
  } else {
    p <- p +
      geom_col(
        data = .dat,
        aes(x = {{ x }}, y = {{ y }}, fill = {{ fill }}),
        position = position
      ) +
      scale_fill_insper(palette = palette, ...)
  }

  # Add horizontal line at zero if requested
  if (zero) {
    p <- p + ggplot2::geom_hline(yintercept = 0, linewidth = 1)
  }

  # Add text labels if requested
  if (text) {
    text_vjust <- if (flip) 0.5 else -0.5
    text_hjust <- if (flip) -0.1 else 0.5

    if (missing(group) && missing(fill)) {
      # Simple text labels
      p <- p +
        ggplot2::geom_text(
          data = .dat,
          ggplot2::aes(x = {{ x }}, y = {{ y }}, label = scales::comma({{ y }}, accuracy = 0.1)),
          vjust = text_vjust,
          hjust = text_hjust,
          size = text_size,
          color = text_color
        )
    } else {
      # Grouped text labels
      dodge_width <- if (position == "dodge") 0.8 else 0
      p <- p +
        ggplot2::geom_text(
          data = .dat,
          ggplot2::aes(
            x = {{ x }},
            y = {{ y }},
            label = scales::comma({{ y }}, accuracy = 0.1),
            group = {{ if (!missing(group)) group else fill }}
          ),
          position = ggplot2::position_dodge(width = dodge_width),
          vjust = text_vjust,
          hjust = text_hjust,
          size = text_size,
          color = text_color
        )
    }
  }

  # Apply coordinate flip if requested
  if (flip) {
    p <- p +
      ggplot2::coord_flip() +
      ggplot2::scale_y_continuous(
        expand = ggplot2::expansion(mult = c(0, 0.1)),
        labels = scales::comma_format()
      )
  } else {
    p <- p +
      ggplot2::scale_y_continuous(
        expand = ggplot2::expansion(mult = c(0, 0.1)),
        labels = scales::comma_format()
      )
  }

  p <- p + theme_insper()

  return(p)
}

#' Insper Scatter Plot
#'
#' Scatter plots with regression lines and confidence intervals
#'
#' @param data Data frame
#' @param x Variable for x-axis
#' @param y Variable for y-axis
#' @param color Variable for color aesthetic
#' @param add_smooth Add smooth regression line
#' @param title Plot title
#' @param subtitle Plot subtitle
#' @param caption Plot caption
#' @return ggplot object
#' @family plots
#' @seealso \code{\link{theme_insper}}, \code{\link{scale_color_insper}}
#' @export
insper_scatterplot <- function(data, x, y, color = NULL, add_smooth = TRUE,
                               title = NULL, subtitle = NULL, caption = NULL) {

  p <- ggplot2::ggplot(data, ggplot2::aes(x = {{x}}, y = {{y}}))

  if (!is.null(substitute(color))) {
    p <- p + ggplot2::geom_point(ggplot2::aes(color = {{color}}), size = 2, alpha = 0.7)
    p <- p + scale_color_insper()
  } else {
    p <- p + ggplot2::geom_point(color = insper_colors$primary["insper_blue"], size = 2, alpha = 0.7)
  }

  if (add_smooth) {
    p <- p + ggplot2::geom_smooth(
      method = "lm",
      color = insper_colors$accent["orange"],
      fill = insper_colors$accent["orange"],
      alpha = 0.2
    )
  }

  p <- p +
    theme_insper() +
    ggplot2::labs(
      title = title,
      subtitle = subtitle,
      caption = caption
    )

  return(p)
}

#' Insper Time Series Plot
#'
#' Time series plots optimized for economic/business data
#'
#' @param data Data frame
#' @param x Time variable
#' @param y Value variable
#' @param group Grouping variable
#' @param title Plot title
#' @param subtitle Plot subtitle
#' @param caption Plot caption
#' @return ggplot object
#' @family plots
#' @seealso \code{\link{theme_insper}}, \code{\link{scale_color_insper}}
#' @export
insper_timeseries <- function(data, x, y, group = NULL, title = NULL,
                              subtitle = NULL, caption = NULL) {

  p <- ggplot2::ggplot(data, ggplot2::aes(x = {{x}}, y = {{y}}))

  if (!is.null(substitute(group))) {
    p <- p +
      ggplot2::geom_line(ggplot2::aes(color = {{group}}), linewidth = 1.2) +
      scale_color_insper()
  } else {
    p <- p + ggplot2::geom_line(color = insper_colors$primary["insper_blue"], linewidth = 1.2)
  }

  p <- p +
    theme_insper() +
    ggplot2::labs(
      title = title,
      subtitle = subtitle,
      caption = caption
    ) +
    ggplot2::scale_x_continuous(expand = c(0.01, 0.01)) +
    ggplot2::theme(
      panel.grid.minor.x = ggplot2::element_blank()
    )

  return(p)
}

#' Insper Box Plot
#'
#' Box plots with statistical annotations
#'
#' @param data Data frame
#' @param x Variable for x-axis
#' @param y Variable for y-axis
#' @param fill Variable for fill aesthetic
#' @param title Plot title
#' @param subtitle Plot subtitle
#' @param caption Plot caption
#' @return ggplot object
#' @family plots
#' @seealso \code{\link{theme_insper}}, \code{\link{scale_fill_insper}}
#' @export
insper_boxplot <- function(data, x, y, fill = NULL, title = NULL,
                           subtitle = NULL, caption = NULL) {

  p <- ggplot2::ggplot(data, ggplot2::aes(x = {{x}}, y = {{y}}))

  if (!is.null(substitute(fill))) {
    p <- p +
      ggplot2::geom_boxplot(ggplot2::aes(fill = {{fill}}), alpha = 0.7) +
      scale_fill_insper()
  } else {
    p <- p + ggplot2::geom_boxplot(fill = insper_colors$primary["insper_light_blue"], alpha = 0.7)
  }

  p <- p +
    ggplot2::geom_jitter(width = 0.2, alpha = 0.5, color = insper_colors$primary["insper_gray"]) +
    theme_insper() +
    ggplot2::labs(
      title = title,
      subtitle = subtitle,
      caption = caption
    ) +
    ggplot2::coord_flip()

  return(p)
}

#' Insper Heatmap
#'
#' Correlation matrices and heatmaps
#'
#' @param data Data frame or correlation matrix
#' @param title Plot title
#' @param subtitle Plot subtitle
#' @param caption Plot caption
#' @param show_values Show correlation values on tiles
#' @return ggplot object
#' @export
insper_heatmap <- function(data, title = NULL, subtitle = NULL,
                           caption = NULL, show_values = TRUE) {

  # If data is not already melted, assume it''s a correlation matrix
  if (!("Var1" %in% names(data) && "Var2" %in% names(data) && "value" %in% names(data))) {
    # Convert correlation matrix to long format
    cor_matrix <- as.matrix(data)
    melted_data <- expand.grid(Var1 = rownames(cor_matrix), Var2 = colnames(cor_matrix))
    melted_data$value <- as.vector(cor_matrix)
  } else {
    melted_data <- data
  }

  p <- ggplot2::ggplot(melted_data, ggplot2::aes(x = Var1, y = Var2, fill = value)) +
    ggplot2::geom_tile(color = "white", linewidth = 0.5) +
    scale_fill_insper(palette = "diverging_insper", discrete = FALSE) +
    theme_insper() +
    ggplot2::theme(
      axis.text.x = ggplot2::element_text(angle = 45, hjust = 1),
      axis.title = ggplot2::element_blank(),
      panel.grid = ggplot2::element_blank()
    ) +
    ggplot2::labs(
      title = title,
      subtitle = subtitle,
      caption = caption,
      fill = "Correlation"
    )

  if (show_values) {
    p <- p + ggplot2::geom_text(
      ggplot2::aes(label = round(value, 2)),
      color = "white",
      size = 3
    )
  }

  return(p)
}
