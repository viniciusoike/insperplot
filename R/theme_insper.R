#' Insper Custom ggplot2 Theme
#'
#' Creates a custom ggplot2 theme based on Insper's visual identity and branding.
#' This theme provides a clean, professional appearance with customizable grid
#' lines and border options, using Insper's color palette and typography.
#'
#' @param base_size Numeric. Base font size for all text elements in points.
#'   Default is 12. All other text sizes are calculated relative to this value.
#' @param font_title Character. Font family to use for plot titles and subtitles.
#'   Default is "EB Garamond" (serif). The theme automatically detects font
#'   availability and falls back to "serif" if unavailable.
#' @param font_text Character. Font family to use for all other text elements
#'   (axis labels, legend text, etc.). Default is "Barlow" (sans-serif).
#'   Falls back to "sans" if unavailable.
#' @param grid Logical. Whether to display major grid lines. If TRUE, shows
#'   dashed grid lines in light gray. If FALSE, removes all grid lines.
#'   Default is TRUE.
#' @param border Character. Type of plot border to display. Must be one of:
#'   \itemize{
#'     \item "none" - No border or axis lines (default)
#'     \item "half" - Shows axis lines with ticks but no full border
#'     \item "closed" - Shows a complete rectangular border around the plot area
#'   }
#' @param ... Additional arguments passed to \code{theme_minimal()}.
#'
#' @return A ggplot2 theme object that can be added to ggplot objects using the
#'   \code{+} operator.
#'
#' @details
#' The theme applies Insper's visual identity through:
#' \itemize{
#'   \item Off-white background color for both plot and panel
#'   \item Horizontal legend positioned at the top
#'   \item Bold legend titles
#'   \item Custom color scheme using insper_col() function
#'   \item Consistent spacing and typography hierarchy
#' }
#'
#' **Font Setup:**
#'
#' The theme uses two custom fonts by default:
#' \itemize{
#'   \item EB Garamond (serif) for titles
#'   \item Barlow (sans-serif) for body text
#' }
#'
#' To use these fonts, you have two options:
#' \enumerate{
#'   \item Install fonts locally - see \code{\link{check_insper_fonts}()}
#'   \item Load fonts remotely - use \code{\link{import_insper_fonts}()}
#' }
#'
#' If fonts are unavailable, the theme automatically falls back to system
#' defaults ("serif" and "sans") without errors.
#'
#' The function validates input parameters and will throw an error if invalid
#' values are provided for \code{grid} or \code{border} arguments.
#'
#' @examples
#' \dontrun{
#' library(ggplot2)
#'
#' # Basic usage with default settings
#' ggplot(mtcars, aes(x = wt, y = mpg)) +
#'   geom_point() +
#'   theme_insper()
#'
#' # Without grid lines and with closed border
#' ggplot(mtcars, aes(x = wt, y = mpg)) +
#'   geom_point() +
#'   theme_insper(grid = FALSE, border = "closed")
#'
#' # Custom font size
#' ggplot(mtcars, aes(x = wt, y = mpg)) +
#'   geom_point() +
#'   theme_insper(base_size = 14)
#' }
#'
#' @family themes
#' @seealso \code{\link[ggplot2]{theme_minimal}}, \code{\link[ggplot2]{theme}}, \code{\link{import_insper_fonts}}, \code{\link{check_insper_fonts}}
#' @importFrom ggplot2 element_blank element_line element_rect element_text unit theme theme_minimal rel margin %+replace%
#' @export
theme_insper <- function(
    base_size = 12,
    font_title = "EB Garamond",
    font_text = "Barlow",
    grid = TRUE,
    border = "none",
    ...) {

  # Input validation ----
  # Check that grid parameter is logical (TRUE/FALSE)
  if (!is.logical(grid)) {
    cli::cli_abort("Argument `grid` must be one of `TRUE` or `FALSE`.")
  }

  # Validate border parameter against allowed values
  valid_border <- c("none", "half", "closed")
  if (!any(border %in% valid_border)) {
    cli::cli_abort("Argument `border` must be one of 'none', 'half', or 'closed'.")
  }

  # Font detection and fallback ----
  # Detect if custom fonts are available, fall back to system defaults if not
  font_title <- detect_font(font_title, fallback = "serif")
  font_text <- detect_font(font_text, fallback = "sans")

  # Base theme configuration ----
  # Define the core theme elements that apply regardless of options
  theme_base <- theme(
    # Text styling
    text = element_text(family = font_text, size = rel(1)),

    # Background colors using Insper's off-white
    plot.background = element_rect(fill = insper_col("off_white"), color = insper_col("off_white")),
    panel.background = element_rect(fill = insper_col("off_white"), color = insper_col("off_white")),

    # Remove minor grid lines (always off)
    panel.grid.minor = element_blank(),

    # Plot spacing and margins
    plot.margin = margin(20, 15, 20, 15),

    # Legend configuration
    legend.position = "top",           # Position legend at top of plot
    legend.direction = "horizontal",   # Arrange legend items horizontally
    legend.title = element_text(face = "bold"),

    # Axis styling
    # Note: axis.ticks are commented out in base theme, applied conditionally based on border
    axis.text = element_text(size = rel(1), color = "gray10"),
    axis.title = element_text(size = rel(1), color = insper_col("black")),

    # Title and subtitle styling
    plot.title = element_text(
      size = rel(1.8),                        # 80% larger than base size
      family = font_title,                    # Use title font
      color = insper_col("black"),
      hjust = 0                               # Left-align title
    ),
    plot.subtitle = element_text(
      size = rel(0.9),                        # 10% smaller than base size
      family = font_title,                    # Use title font
      color = insper_col("gray_meddark"),
      hjust = 0                               # Left-align subtitle
    ),

    # Caption styling (bottom right)
    plot.caption = element_text(size = rel(0.8), color = "gray40", hjust = 1),

    # Facet strip styling
    # strip.background is commented out - uses default
    strip.text = element_text(size = rel(1), face = "bold"),

    # Mark theme as complete (replaces all elements from base theme)
    complete = TRUE
  )

  # Conditional grid configuration ----
  # Add or remove major grid lines based on grid parameter
  if (grid) {
    theme_base <- theme_base + theme(
      panel.grid.major = element_line(
        linewidth = 0.35,                     # Thin lines
        linetype = "dashed",                  # Dashed style
        color = insper_col("gray_light")      # Light gray color
      )
    )
  } else {
    theme_base <- theme_base + theme(panel.grid.major = element_blank())
  }

  # Conditional border configuration ----
  # Apply different border styles based on border parameter
  if (border == "half") {
    # Show axis lines with ticks but no full border
    theme_base <- theme_base + theme(
      axis.line = element_line(),                           # Add axis lines
      axis.ticks = element_line(color = insper_col("gray_dark")),
      axis.ticks.length = unit(7, "pt")                     # 7 point tick length
    )
  }

  if (border == "closed") {
    # Show complete rectangular border around plot area
    theme_base <- theme_base + theme(
      panel.border = element_rect(color = insper_col("black"), fill = NA),
      axis.ticks = element_line(color = insper_col("gray_dark")),
      axis.ticks.length = unit(7, "pt")                     # 7 point tick length
    )
  }

  # Return combined theme ----
  # Start with theme_minimal as base, then replace with custom elements
  # The %+replace% operator replaces matching elements rather than adding to them
  theme_minimal(base_size = base_size, ...) %+replace%
    theme_base
}


# Helper Functions --------------------------------------------------------

#' Detect Font Availability with Fallback
#'
#' Internal helper function to detect if a font is available and provide
#' fallback if not. Checks both loaded fonts (via showtext) and system fonts.
#'
#' @param font_name Character. Name of font to check
#' @param fallback Character. Fallback font if requested font unavailable
#'
#' @return Character. Either the requested font (if available) or fallback
#' @keywords internal
#' @noRd
detect_font <- function(font_name, fallback = "sans") {

  # First check if fonts loaded via import_insper_fonts()
  fonts_imported <- isTRUE(getOption("insperplot.fonts_loaded", FALSE))

  # If fonts imported via showtext, use the requested font
  if (fonts_imported) {
    return(font_name)
  }

  # Otherwise check if font is installed locally (requires systemfonts)
  has_systemfonts <- requireNamespace("systemfonts", quietly = TRUE)

  if (has_systemfonts) {
    tryCatch({
      available_fonts <- systemfonts::system_fonts()$family
      font_available <- any(grepl(font_name, available_fonts, ignore.case = TRUE))

      if (font_available) {
        return(font_name)
      }
    }, error = function(e) {
      # If error checking fonts, use fallback silently
      return(fallback)
    })
  }

  # If font not found, use fallback
  return(fallback)
}
