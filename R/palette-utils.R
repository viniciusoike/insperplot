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
list_palettes <- function(type = c("all", "sequential", "diverging", "qualitative", "accent"),
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
      "bright", "contrast", "categorical",
      # Accent palettes
      "accent_red", "accent_teal",
      # Additional categorical palettes
      "categorical_ito", "categorical_tab", "categorical_set"
    ),
    type = c(
      "qualitative",  # main
      rep("sequential", 4),
      rep("diverging", 3),
      rep("qualitative", 3),
      rep("accent", 2),
      rep("qualitative", 3)
    ),
    n_colors = c(
      6,  # main
      5, 5, 5, 5,  # sequential
      5, 11, 5,  # diverging
      6, 6, 8,  # qualitative
      6, 6,  # accent
      8, 10, 9  # categorical variants
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
      "Accent palette with red emphasis",
      "Accent palette with teal emphasis",
      "Okabe-Ito colorblind-safe palette",
      "Tableau 10 categorical palette",
      "ColorBrewer Set1 palette"
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


#' Extract Hex Codes from Insper Color Palettes
#'
#' Extract hex color codes from Insper palettes for use in custom plots.
#' This function provides direct access to palette colors, similar to
#' \code{RColorBrewer::brewer.pal()}.
#'
#' @param palette Character string indicating palette name. Use
#'   \code{\link{list_palettes}} to see available palettes. Common palettes
#'   include "main", "reds", "oranges", "teals", "grays", "red_teal", "bright",
#'   "contrast", "categorical".
#' @param n Number of colors to return. If \code{NULL} (default), returns all
#'   colors in the palette. If \code{n} exceeds the palette size, colors will
#'   be recycled with a warning.
#' @param reverse Logical. If \code{TRUE}, reverses the order of colors.
#'   Default is \code{FALSE}.
#'
#' @return Character vector of hex color codes.
#'
#' @details
#' This function extracts colors from Insper palettes in discrete mode, meaning
#' it returns the actual palette colors (possibly recycled) rather than
#' interpolating new colors. For continuous color interpolation in ggplot2,
#' use \code{\link{scale_color_insper_c}} or \code{\link{scale_fill_insper_c}}.
#'
#' To explore available palettes visually, use \code{\link{show_insper_palette}}.
#' To list all available palettes with metadata, use \code{\link{list_palettes}}.
#'
#' @family colors
#' @seealso \code{\link{get_insper_colors}} for individual colors,
#'   \code{\link{list_palettes}} to see all palettes,
#'   \code{\link{show_insper_palette}} to visualize palettes,
#'   \code{\link{scale_color_insper_d}} for ggplot2 discrete scales
#' @export
#' @examples
#' # Get 5 colors from the reds sequential palette
#' get_palette_colors("reds", n = 5)
#'
#' # Get all colors from the main palette
#' get_palette_colors("main")
#'
#' # Get colors in reverse order
#' get_palette_colors("teals", n = 3, reverse = TRUE)
#'
#' # Use in base R plots
#' colors <- get_palette_colors("bright", n = 3)
#' barplot(1:3, col = colors)
#'
#' # Use in ggplot2 manual scales
#' library(ggplot2)
#' ggplot(iris, aes(Sepal.Length, Sepal.Width, color = Species)) +
#'   geom_point() +
#'   scale_color_manual(values = get_palette_colors("main", n = 3))
get_palette_colors <- function(palette, n = NULL, reverse = FALSE) {
  # Call internal insper_pal function with discrete type
  insper_pal(palette = palette, n = n, type = "discrete", reverse = reverse)
}
