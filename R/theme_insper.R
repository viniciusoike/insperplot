#' Insper Custom ggplot2 Theme
#'
#' Creates a custom ggplot2 theme based on Insper's visual identity and branding.
#' This theme provides a clean, professional appearance with customizable grid
#' lines and border options, using Insper's color palette and typography.
#'
#' @param base_size Numeric. Base font size for all text elements in points.
#'   Default is 12. All other text sizes are calculated relative to this value.
#' @param font_title Character. Font family to use for plot titles and subtitles.
#'   Default is "Georgia" (serif, from Insper's official template). The theme
#'   automatically detects font availability and falls back to "EB Garamond",
#'   then "Playfair Display", then "serif" if unavailable.
#' @param font_text Character. Font family to use for all other text elements
#'   (axis labels, legend text, etc.). Default is "Inter" (sans-serif, from
#'   Insper's official template). Falls back to "Arial" then "sans" if unavailable.
#' @param grid Logical. Whether to display major grid lines. If TRUE, shows
#'   dashed grid lines in light gray. If FALSE, removes all grid lines.
#'   Default is TRUE.
#' @param border Character. Type of plot border to display. Must be one of:
#'   \itemize{
#'     \item "none" - No border or axis lines (default)
#'     \item "half" - Shows axis lines with ticks but no full border
#'     \item "closed" - Shows a complete rectangular border around the plot area
#'   }
#' @param align Character. Alignment of title and caption. Must be one of:
#'   \itemize{
#'     \item "panel" - Align to the plot panel area (default)
#'     \item "plot" - Align to the entire plot area including margins
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
#'   \item Custom color scheme using get_insper_colors() function
#'   \item Consistent spacing and typography hierarchy
#' }
#'
#' **Font Setup:**
#'
#' The theme uses fonts based on Insper's official template:
#' \itemize{
#'   \item Georgia (serif, system font) for titles - falls back to EB Garamond,
#'         then Playfair Display
#'   \item Inter (sans-serif, Google Font) for body text - falls back to Arial
#' }
#'
#' To install or check fonts, see \code{\link{setup_insper_fonts}} and
#' \code{\link{import_insper_fonts}}.
#'
#' If fonts are unavailable, the theme automatically falls back through the
#' chain and ultimately to system defaults ("serif" and "sans") without errors.
#'
#' The function validates input parameters and will throw an error if invalid
#' values are provided for \code{grid} or \code{border} arguments.
#'
#' @examplesIf has_insper_fonts()
#' library(ggplot2)
#'
#' # Default
#' ggplot(mtcars, aes(x = wt, y = mpg)) +
#'   geom_point() +
#'   theme_insper()
#'
#' # Minimal — no grid, clean background
#' ggplot(mtcars, aes(x = wt, y = mpg)) +
#'   geom_point() +
#'   theme_insper(grid = FALSE)
#'
#' # Presentation — larger text for slides
#' ggplot(mtcars, aes(x = wt, y = mpg)) +
#'   geom_point() +
#'   theme_insper(base_size = 16, grid = FALSE)
#'
#' # Print / PDF — closed border, smaller text
#' ggplot(mtcars, aes(x = wt, y = mpg)) +
#'   geom_point() +
#'   theme_insper(base_size = 11, border = "closed")
#'
#' @family themes
#' @seealso \code{\link[ggplot2]{theme_minimal}}, \code{\link[ggplot2]{theme}}, \code{\link{setup_insper_fonts}}, \code{\link{import_insper_fonts}}
#' @importFrom ggplot2 element_blank element_line element_rect element_text unit theme theme_minimal rel margin %+replace% theme_sub_axis theme_sub_legend theme_sub_panel theme_sub_plot theme_sub_strip
#' @export
theme_insper <- function(
  base_size = 12,
  font_title = "Georgia",
  font_text = "Inter",
  grid = TRUE,
  border = "none",
  align = "panel",
  ...
) {
  # Input validation ----
  if (!is.logical(grid)) {
    cli::cli_abort("Argument `grid` must be one of `TRUE` or `FALSE`.")
  }

  valid_align <- c("panel", "plot")
  if (!align %in% valid_align) {
    cli::cli_abort(c(
      "{.arg align} must be one of {.val panel} or {.val plot}",
      "x" = "You supplied: {.val {align}}"
    ))
  }

  valid_border <- c("none", "half", "closed")
  if (!any(border %in% valid_border)) {
    cli::cli_abort(
      "Argument `border` must be one of 'none', 'half', or 'closed'."
    )
  }

  # Font detection and fallback ----
  font_title <- detect_font(
    font_title,
    fallback_chain = c("EB Garamond", "Playfair Display", "serif")
  )
  font_text <- detect_font(
    font_text,
    fallback_chain = c("Arial", "sans")
  )

  # Colors ----
  off_white <- get_insper_colors("off_white")
  black <- get_insper_colors("black")

  # Conditional grid theme ----
  grid_theme <- if (grid) {
    theme_sub_panel(
      grid.major = element_line(
        linewidth = 0.35,
        color = get_insper_colors("gray_light")
      )
    )
  } else {
    theme_sub_panel(grid.major = element_blank())
  }

  # Conditional border theme ----
  border_theme <- if (border == "half") {
    theme_sub_axis(
      line = element_line(),
      ticks = element_line(color = get_insper_colors("gray_dark")),
      ticks.length = unit(7, "pt")
    )
  } else if (border == "closed") {
    theme_sub_panel(border = element_rect(color = black, fill = NA)) +
      theme_sub_axis(
        ticks = element_line(color = get_insper_colors("gray_dark")),
        ticks.length = unit(7, "pt")
      )
  } else {
    theme()
  }

  # Build full theme ----
  full_theme <- theme(
    text = element_text(family = font_text, size = rel(1)),
    complete = TRUE
  ) +
    theme_sub_panel(grid.minor = element_blank()) +
    theme_sub_plot(
      margin = margin(10, 15, 10, 15),
      title = element_text(
        size = rel(1.4),
        family = font_title,
        color = black,
        hjust = 0,
        margin = margin(b = 5)
      ),
      subtitle = element_text(
        size = rel(0.8),
        family = font_text,
        color = get_insper_colors("gray_meddark"),
        hjust = 0,
        margin = margin(t = 3, b = 5)
      ),
      caption = element_text(
        size = rel(0.5),
        color = "gray40",
        hjust = 0,
        margin = margin(t = 3)
      ),
      title.position = align,
      caption.position = align
    ) +
    theme_sub_legend(
      position = "top",
      direction = "horizontal",
      title = element_text(face = "bold")
    ) +
    theme_sub_axis(
      text = element_text(size = rel(0.8), color = "gray10"),
      title = element_text(size = rel(1), color = black)
    ) +
    theme_sub_strip(text = element_text(size = rel(1), face = "bold")) +
    grid_theme +
    border_theme

  # Return final theme ----
  theme_minimal(base_size = base_size, paper = off_white, ...) %+replace%
    full_theme
}


# Helper Functions --------------------------------------------------------

#' @keywords internal
#' @noRd
detect_font <- function(font_name, fallback_chain = "sans") {
  if (!requireNamespace("systemfonts", quietly = TRUE)) {
    return(fallback_chain[length(fallback_chain)])
  }

  tryCatch(
    {
      available_fonts <- unique(systemfonts::system_fonts()$family)

      # Returns exact match, or first grepl match (handles variants like "Inter 18pt")
      resolve_font <- function(name) {
        if (name %in% available_fonts) return(name)
        matches <- available_fonts[grepl(name, available_fonts, ignore.case = TRUE)]
        if (length(matches) > 0) return(matches[1])
        NULL
      }

      resolved <- resolve_font(font_name)
      if (!is.null(resolved)) return(resolved)

      for (fallback_font in fallback_chain) {
        if (fallback_font %in% c("serif", "sans", "mono")) {
          return(fallback_font)
        }
        resolved <- resolve_font(fallback_font)
        if (!is.null(resolved)) return(resolved)
      }
    },
    error = function(e) {
      return(fallback_chain[length(fallback_chain)])
    }
  )

  return(fallback_chain[length(fallback_chain)])
}
