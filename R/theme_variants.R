#' Insper Minimal Theme (Experimental)
#'
#' A minimal variant of \code{\link{theme_insper}} with no grid lines and no
#' borders, emphasizing clean simplicity. This is a convenience wrapper around
#' \code{theme_insper()} with specific defaults.
#'
#' @param base_size Numeric. Base font size for all text elements in points.
#'   Default is 12.
#' @param font_title Character. Font family for titles. Default is "EB Garamond".
#' @param font_text Character. Font family for body text. Default is "Barlow".
#' @param ... Additional arguments passed to \code{\link{theme_insper}}.
#'
#' @return A ggplot2 theme object.
#'
#' @details
#' This theme is ideal for presentations or publications where a clean,
#' uncluttered appearance is desired. It removes all grid lines and borders,
#' letting the data speak for itself.
#'
#' **Note:** This is an experimental convenience function. For full control and
#' customization, use \code{\link{theme_insper}} directly with
#' \code{grid = FALSE} and \code{border = "none"}.
#'
#' @examples
#' \dontrun{
#' library(ggplot2)
#'
#' # Minimal theme for clean plots
#' ggplot(mtcars, aes(x = wt, y = mpg)) +
#'   geom_point() +
#'   labs(title = "Clean Minimal Style") +
#'   theme_insper_minimal()
#'
#' # For more control, use theme_insper() directly:
#' ggplot(mtcars, aes(x = wt, y = mpg)) +
#'   geom_point() +
#'   theme_insper(grid = FALSE, border = "none")
#' }
#'
#' @seealso \code{\link{theme_insper}} for the main theme function with full
#'   customization options.
#'
#' @family themes
#' @export
theme_insper_minimal <- function(
  base_size = 12,
  font_title = "EB Garamond",
  font_text = "Barlow",
  ...
) {
  theme_insper(
    base_size = base_size,
    font_title = font_title,
    font_text = font_text,
    grid = FALSE,
    border = "none",
    ...
  )
}


#' Insper Presentation Theme (Experimental)
#'
#' A presentation-optimized variant of \code{\link{theme_insper}} with larger
#' text sizes, no grid, and high contrast for better visibility on slides.
#' This is a convenience wrapper around \code{theme_insper()} with specific
#' defaults.
#'
#' @param base_size Numeric. Base font size for all text elements in points.
#'   Default is 16 (larger than standard for better readability on slides).
#' @param font_title Character. Font family for titles. Default is "EB Garamond".
#' @param font_text Character. Font family for body text. Default is "Barlow".
#' @param ... Additional arguments passed to \code{\link{theme_insper}}.
#'
#' @return A ggplot2 theme object.
#'
#' @details
#' This theme is optimized for presentation slides and projected displays where
#' larger text and minimal visual clutter improve readability. The increased
#' base font size ensures text is legible from a distance.
#'
#' **Note:** This is an experimental convenience function. For full control and
#' customization, use \code{\link{theme_insper}} directly with appropriate
#' \code{base_size} and parameters.
#'
#' @examples
#' \dontrun{
#' library(ggplot2)
#'
#' # Presentation-ready plot
#' ggplot(mtcars, aes(x = wt, y = mpg)) +
#'   geom_point(size = 3) +
#'   labs(title = "Large Text for Presentations") +
#'   theme_insper_presentation()
#'
#' # For more control, use theme_insper() directly:
#' ggplot(mtcars, aes(x = wt, y = mpg)) +
#'   geom_point() +
#'   theme_insper(base_size = 16, grid = FALSE)
#' }
#'
#' @seealso \code{\link{theme_insper}} for the main theme function with full
#'   customization options.
#'
#' @family themes
#' @export
theme_insper_presentation <- function(
  base_size = 16,
  font_title = "EB Garamond",
  font_text = "Barlow",
  ...
) {
  theme_insper(
    base_size = base_size,
    font_title = font_title,
    font_text = font_text,
    grid = FALSE,
    border = "none",
    ...
  )
}


#' Insper Print Theme (Experimental)
#'
#' A print-optimized variant of \code{\link{theme_insper}} with a closed border
#' and subtle grid lines, ideal for PDF output and printed documents. This is a
#' convenience wrapper around \code{theme_insper()} with specific defaults.
#'
#' @param base_size Numeric. Base font size for all text elements in points.
#'   Default is 11 (slightly smaller for print).
#' @param font_title Character. Font family for titles. Default is "EB Garamond".
#' @param font_text Character. Font family for body text. Default is "Barlow".
#' @param ... Additional arguments passed to \code{\link{theme_insper}}.
#'
#' @return A ggplot2 theme object.
#'
#' @details
#' This theme is optimized for printed documents and PDF output. The closed
#' border provides clear plot boundaries, and the subtle grid helps with value
#' estimation. The slightly reduced font size works well in print where
#' resolution is higher.
#'
#' **Note:** This is an experimental convenience function. For full control and
#' customization, use \code{\link{theme_insper}} directly with
#' \code{border = "closed"} and \code{grid = TRUE}.
#'
#' @examples
#' \dontrun{
#' library(ggplot2)
#'
#' # Print-ready plot
#' p <- ggplot(mtcars, aes(x = wt, y = mpg)) +
#'   geom_point() +
#'   labs(title = "Optimized for Print") +
#'   theme_insper_print()
#'
#' # Save for print
#' ggsave("plot.pdf", p, width = 7, height = 5)
#'
#' # For more control, use theme_insper() directly:
#' ggplot(mtcars, aes(x = wt, y = mpg)) +
#'   geom_point() +
#'   theme_insper(base_size = 11, border = "closed", grid = TRUE)
#' }
#'
#' @seealso \code{\link{theme_insper}} for the main theme function with full
#'   customization options.
#'
#' @family themes
#' @export
theme_insper_print <- function(
  base_size = 11,
  font_title = "EB Garamond",
  font_text = "Barlow",
  ...
) {
  theme_insper(
    base_size = base_size,
    font_title = font_title,
    font_text = font_text,
    grid = TRUE,
    border = "closed",
    ...
  )
}
