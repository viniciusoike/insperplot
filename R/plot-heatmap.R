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
#' @examplesIf has_insper_fonts()
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

