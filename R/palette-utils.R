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
      "reds", "oranges", "teals", "grays",
      # Diverging
      "red_teal", "red_teal_ext", "diverging",
      # Qualitative
      "bright", "contrast", "categorical", "accent"
    ),
    type = c(
      "qualitative",  # main
      rep("sequential", 4),
      rep("diverging", 3),
      rep("qualitative", 4)
    ),
    n_colors = c(
      6,  # main
      5, 5, 5, 5,  # sequential
      5, 11, 5,  # diverging
      6, 6, 8, 5  # qualitative
    ),
    recommended_use = c(
      "Primary brand colors for categorical data",
      "Intensity scales (light to dark red)",
      "Intensity scales (light to dark orange)",
      "Intensity scales (light to dark teal)",
      "Intensity scales (light to dark gray)",
      "Diverging data (negative/positive, red/teal)",
      "Extended diverging palette (11 colors)",
      "Classic diverging palette (teal/gray/red)",
      "Bright categorical colors (high contrast)",
      "High contrast categorical colors",
      "8-color categorical palette",
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


#' Extract Individual Insper Colors
#'
#' Extract hex codes for individual named colors (e.g., "reds1", "teals2").
#' For palette extraction, use \code{\link{insper_pal}} instead.
#'
#' @param ... Character names of colors. If none provided, returns all individual colors.
#' @return Named character vector of hex codes
#'
#' @details
#' This function extracts individual named colors from the Insper color system.
#' To see what colors are available, use \code{\link{show_insper_colors}}.
#' To extract palette colors (for scales), use \code{\link{insper_pal}}.
#'
#' Available individual colors:
#' \itemize{
#'   \item Basic: white, off_white, black
#'   \item Grays: gray_light, gray_med, gray_meddark, gray_dark
#'   \item Reds: reds1 (primary), reds2, reds3
#'   \item Oranges: oranges1, oranges2, oranges3
#'   \item Magentas: magentas1, magentas2, magentas3
#'   \item Teals: teals1, teals2, teals3
#' }
#'
#' @family colors
#' @seealso \code{\link{show_insper_colors}}, \code{\link{insper_pal}}, \code{\link{list_palettes}}
#' @export
#' @examples
#' # Get specific colors by name
#' get_insper_colors("reds1", "teals1")
#'
#' # Get all individual colors
#' all_colors <- get_insper_colors()
#' head(all_colors)
#'
#' # Use in plots
#' library(ggplot2)
#' ggplot(mtcars, aes(wt, mpg)) +
#'   geom_point(color = get_insper_colors("teals1"))
get_insper_colors <- function(...) {
  if (length(list(...)) == 0) {
    return(insper_individual_colors)
  } else {
    requested <- c(...)
    missing <- setdiff(requested, names(insper_individual_colors))
    if (length(missing) > 0) {
      cli::cli_abort(c(
        "x" = "Colors not found: {.val {missing}}",
        "i" = "Use {.fn show_insper_colors} to see available colors"
      ))
    }
    return(insper_individual_colors[requested])
  }
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
