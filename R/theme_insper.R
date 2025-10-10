#' Insper Custom ggplot2 Theme
#'
#' Creates a custom ggplot2 theme based on Insper's visual identity and branding.
#' This theme provides a clean, professional appearance with customizable grid
#' lines and border options, using Insper's color palette and typography.
#'
#' @param base_size Numeric. Base font size for all text elements in points.
#'   Default is 12. All other text sizes are calculated relative to this value.
#' @param font_title Character. Font family to use for plot titles and subtitles.
#'   Default is "DIN Alternate". Must be a font available in the system.
#' @param font_text Character. Font family to use for all other text elements
#'   (axis labels, legend text, etc.). Default is "DIN Alternate".
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
#' @seealso \code{\link[ggplot2]{theme_minimal}}, \code{\link[ggplot2]{theme}}
#' @importFrom ggplot2 element_blank element_line element_rect element_text unit theme theme_minimal rel margin %+replace%
#' @export
theme_insper <- function(
    base_size = 12,
    font_title = "DIN Alternate",
    font_text = "DIN Alternate",
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
