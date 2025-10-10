#' List Available Insper Color Palettes
#'
#' Returns information about all available Insper color palettes, including
#' their type (sequential, diverging, or qualitative), number of colors, and
#' recommended use cases.
#'
#' @param type Character. Filter palettes by type. One of "all", "sequential",
#'   "diverging", or "qualitative". Default is "all".
#' @param names_only Logical. If TRUE, returns only palette names as a character
#'   vector. If FALSE, returns a data frame with detailed information. Default is FALSE.
#'
#' @return If `names_only = FALSE`, returns a data frame with columns:
#'   \itemize{
#'     \item **name**: Palette name
#'     \item **type**: Palette type (sequential, diverging, or qualitative)
#'     \item **n_colors**: Number of colors in the palette
#'     \item **recommended_use**: Description of recommended use case
#'   }
#'   If `names_only = TRUE`, returns a character vector of palette names.
#'
#' @details
#' Insper palettes are organized into three types:
#' \itemize{
#'   \item **Sequential**: For ordered data (e.g., low to high values)
#'   \item **Diverging**: For data with a meaningful midpoint (e.g., negative/positive)
#'   \item **Qualitative**: For categorical data with no inherent order
#' }
#'
#' @family colors
#' @export
#' @examples
#' # List all palettes
#' list_palettes()
#'
#' # List only sequential palettes
#' list_palettes(type = "sequential")
#'
#' # Get just the names
#' list_palettes(names_only = TRUE)
list_palettes <- function(type = c("all", "sequential", "diverging", "qualitative"),
                          names_only = FALSE) {

  type <- match.arg(type)

  # Define palette metadata
  palette_info <- data.frame(
    name = c(
      # Main
      "main",
      # Sequential
      "reds_seq", "oranges_seq", "teals_seq", "grays_seq",
      # Diverging
      "diverging_red_teal", "diverging_red_teal_extended", "diverging_insper",
      # Qualitative
      "qualitative_main", "qualitative_bright", "qualitative_contrast",
      "categorical", "bright", "contrast", "accent"
    ),
    type = c(
      "qualitative",  # main
      rep("sequential", 4),
      rep("diverging", 3),
      rep("qualitative", 7)
    ),
    n_colors = c(
      6,  # main
      5, 5, 5, 5,  # sequential
      5, 11, 5,  # diverging
      6, 6, 6, 8, 5, 5, 5  # qualitative
    ),
    recommended_use = c(
      "Primary Insper brand colors",
      "Intensity scales (light to dark red)",
      "Intensity scales (light to dark orange)",
      "Intensity scales (light to dark teal)",
      "Intensity scales (light to dark gray)",
      "Diverging data (negative/positive, red/teal)",
      "Extended diverging palette (11 colors)",
      "Classic diverging palette (teal/gray/red)",
      "Main categorical palette (6 distinct colors)",
      "Bright categorical colors (high contrast)",
      "High contrast categorical colors",
      "8-color categorical palette",
      "Legacy bright palette",
      "Legacy contrast palette",
      "Accent colors for highlights"
    ),
    stringsAsFactors = FALSE
  )

  # Filter by type
  if (type != "all") {
    palette_info <- palette_info[palette_info$type == type, ]
  }

  # Return
  if (names_only) {
    return(palette_info$name)
  } else {
    return(palette_info)
  }
}


#' Get Colors from Insper Palettes
#'
#' Interactive function to explore and extract colors from Insper palettes.
#' This is a more user-friendly alternative to `insper_pal()` with additional
#' features for discovery and exploration.
#'
#' @param palette Character. Name of the palette. Use `list_palettes()` to see
#'   available options. If NULL, returns information about all palettes.
#' @param n Integer. Number of colors to return. If NULL, returns all colors
#'   from the palette. For sequential palettes, colors are interpolated if n
#'   exceeds the palette size.
#' @param show_hex Logical. If TRUE (default), displays hex codes alongside
#'   color names.
#' @param reverse Logical. If TRUE, reverses the palette order. Default is FALSE.
#'
#' @return Named character vector of hex color codes.
#'
#' @family colors
#' @seealso \code{\link{list_palettes}}, \code{\link{insper_pal}}, \code{\link{show_insper_palette}}
#' @export
#' @examples
#' # Explore all palettes
#' get_insper_colors()
#'
#' # Get colors from a specific palette
#' get_insper_colors("reds_seq")
#'
#' # Get first 3 colors
#' get_insper_colors("qualitative_main", n = 3)
#'
#' # Reverse palette
#' get_insper_colors("diverging_red_teal", reverse = TRUE)
get_insper_colors <- function(palette = NULL, n = NULL, show_hex = TRUE, reverse = FALSE) {

  if (is.null(palette)) {
    # Show overview of all palettes
    cli::cli_h2("Insper Color Palettes")
    cli::cli_text("Use {.fn list_palettes} for detailed information")
    cli::cli_text("")

    pal_info <- list_palettes()

    for (pal_type in c("sequential", "diverging", "qualitative")) {
      type_pals <- pal_info[pal_info$type == pal_type, ]
      cli::cli_h3(tools::toTitleCase(pal_type))
      for (i in 1:nrow(type_pals)) {
        cli::cli_li("{.strong {type_pals$name[i]}}: {type_pals$recommended_use[i]} ({type_pals$n_colors[i]} colors)")
      }
      cli::cli_text("")
    }

    cli::cli_alert_info("Get colors with: {.code get_insper_colors('palette_name')}")
    return(invisible(NULL))
  }

  # Get palette colors
  colors <- insper_pal(palette, n = n, reverse = reverse)

  if (show_hex) {
    # Print colors with hex codes
    cli::cli_h3("Palette: {palette}")
    for (i in seq_along(colors)) {
      cli::cli_li("{.strong Color {i}}: {colors[i]}")
    }
  }

  invisible(colors)
}


#' Show All Palette Types with Examples
#'
#' Creates a visual display of all Insper palette types (sequential, diverging,
#' and qualitative) with example plots showing recommended use cases.
#'
#' @param save_plot Logical. If TRUE, saves the plot to a file. Default is FALSE.
#' @param filename Character. Filename for saving the plot. Only used if
#'   `save_plot = TRUE`. Default is "insper_palettes.png".
#'
#' @return A ggplot2 object showing all palette types.
#'
#' @family colors
#' @importFrom ggplot2 aes
#' @export
#' @examples
#' \dontrun{
#' # Display all palette types
#' show_palette_types()
#'
#' # Save to file
#' show_palette_types(save_plot = TRUE, filename = "my_palettes.png")
#' }
show_palette_types <- function(save_plot = FALSE, filename = "insper_palettes.png") {
  # Define variables to avoid R CMD check NOTE
  position <- palette <- color <- NULL

  # Get palette information
  pal_info <- list_palettes()

  # Create data for visualization
  plot_data <- data.frame()

  for (i in 1:nrow(pal_info)) {
    pal_name <- pal_info$name[i]
    pal_colors <- insper_pal(pal_name)

    temp_df <- data.frame(
      palette = pal_name,
      type = pal_info$type[i],
      color = pal_colors,
      position = seq_along(pal_colors),
      stringsAsFactors = FALSE
    )

    plot_data <- rbind(plot_data, temp_df)
  }

  # Create plot
  p <- ggplot2::ggplot(plot_data, ggplot2::aes(x = position, y = palette, fill = color)) +
    ggplot2::geom_tile(color = "white", linewidth = 1) +
    ggplot2::scale_fill_identity() +
    ggplot2::facet_wrap(~type, scales = "free_y", ncol = 1) +
    ggplot2::theme_minimal() +
    ggplot2::labs(
      title = "Insper Color Palettes",
      subtitle = "Organized by type: Sequential, Diverging, and Qualitative",
      x = NULL,
      y = NULL
    ) +
    ggplot2::theme(
      axis.text.x = ggplot2::element_blank(),
      axis.ticks = ggplot2::element_blank(),
      panel.grid = ggplot2::element_blank(),
      strip.text = ggplot2::element_text(face = "bold", size = 12),
      plot.title = ggplot2::element_text(face = "bold", size = 16),
      plot.subtitle = ggplot2::element_text(size = 11, color = "gray40")
    )

  if (save_plot) {
    ggplot2::ggsave(filename, p, width = 10, height = 12, dpi = 300)
    message("Palette chart saved: ", filename)
  }

  return(p)
}
