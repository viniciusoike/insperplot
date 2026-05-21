# Palette metadata ----

palette_metadata <- function() {
  data.frame(
    name = c(
      "main",
      "reds", "oranges", "teals", "grays",
      "red_teal", "red_teal_ext", "diverging",
      "bright", "contrast", "categorical",
      "accent_red", "accent_teal",
      "categorical_ito", "categorical_tab", "categorical_set"
    ),
    type = c(
      "qualitative",
      rep("sequential", 4),
      rep("diverging", 3),
      rep("qualitative", 3),
      rep("accent", 2),
      rep("qualitative", 3)
    ),
    n_colors = c(
      6,
      5, 5, 5, 5,
      5, 11, 5,
      6, 6, 8,
      6, 6,
      8, 10, 9
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
}


# Individual colors (internal) ----

#' @keywords internal
#' @noRd
get_insper_colors <- function(...) {
  if (length(list(...)) == 0) {
    return(insper_individual_colors)
  }
  requested <- c(...)
  missing <- setdiff(requested, names(insper_individual_colors))
  if (length(missing) > 0) {
    cli::cli_abort(c(
      "x" = "Colors not found: {.val {missing}}",
      "i" = "Individual colors: reds1-5, oranges1-5, teals1-5, grays, white, black, off_white"
    ))
  }
  insper_individual_colors[requested]
}


# insper_palette() ----

#' Get an Insper Color Palette
#'
#' Returns a named character vector of hex color codes from an Insper palette.
#' When printed interactively, displays a visual color swatch. The result
#' behaves as a plain character vector and can be used directly anywhere
#' colors are accepted.
#'
#' @param palette Character. Palette name. Use \code{\link{show_insper_palettes}}
#'   to see all options.
#' @param n Integer or NULL. Number of colors to return. If NULL (default),
#'   returns all colors in the palette. If \code{n} exceeds the palette size,
#'   colors are recycled with a warning.
#' @param reverse Logical. If TRUE, reverses the color order. Default FALSE.
#'
#' @return An object of class \code{insper_palette} (a named character vector of
#'   hex codes). Printing displays a visual swatch. Use \code{as.character()} to
#'   strip the class if needed.
#'
#' @details
#' Available palettes by type:
#' \itemize{
#'   \item \strong{Qualitative}: main, bright, contrast, categorical,
#'     categorical_ito, categorical_tab, categorical_set
#'   \item \strong{Sequential}: reds, oranges, teals, grays
#'   \item \strong{Diverging}: red_teal, red_teal_ext, diverging
#'   \item \strong{Accent}: accent_red, accent_teal
#' }
#'
#' @family colors
#' @seealso \code{\link{show_insper_palettes}},
#'   \code{\link{scale_color_insper_d}}, \code{\link{scale_color_insper_c}}
#' @export
#' @examples
#' # Get all colors from a palette
#' insper_palette("main")
#'
#' # Subset to n colors
#' insper_palette("reds", n = 3)
#'
#' # Reverse order
#' insper_palette("red_teal", reverse = TRUE)
#'
#' # Use directly in a plot
#' library(ggplot2)
#' ggplot(mtcars, aes(wt, mpg)) +
#'   geom_point(color = insper_palette("reds", n = 1))
#'
#' # Use in manual scales
#' ggplot(iris, aes(Sepal.Length, Sepal.Width, color = Species)) +
#'   geom_point() +
#'   scale_color_manual(values = insper_palette("main", n = 3))
insper_palette <- function(palette = "main", n = NULL, reverse = FALSE) {
  if (!palette %in% names(insper_palettes)) {
    cli::cli_abort(c(
      "Palette {.val {palette}} not found.",
      "i" = "Use {.fn show_insper_palettes} to see available palettes."
    ))
  }

  colors <- insper_palettes[[palette]]

  if (reverse) colors <- rev(colors)

  if (!is.null(n)) {
    if (n > length(colors)) {
      cli::cli_warn(
        "Palette {.val {palette}} has {length(colors)} colors but {n} requested — recycling."
      )
      colors <- rep(colors, length.out = n)
    } else {
      colors <- colors[seq_len(n)]
    }
  }

  structure(colors, class = c("insper_palette", "character"), palette = palette)
}

#' @export
print.insper_palette <- function(x, ...) {
  position <- hex <- NULL  # R CMD check

  n <- length(x)
  df <- data.frame(
    position = seq_len(n),
    hex = as.character(x),
    stringsAsFactors = FALSE
  )

  p <- ggplot2::ggplot(df, ggplot2::aes(x = position, y = 1, fill = hex)) +
    ggplot2::geom_tile(
      width = 0.9, height = 1,
      color = "white", linewidth = 1
    ) +
    ggplot2::scale_fill_identity() +
    ggplot2::geom_text(
      ggplot2::aes(label = hex),
      size = 3, fontface = "bold", angle = 90, color = "white"
    ) +
    ggplot2::theme_void() +
    ggplot2::labs(title = paste0("Insper palette: ", attr(x, "palette"))) +
    ggplot2::theme(
      plot.title = ggplot2::element_text(hjust = 0.5, size = 13, face = "bold"),
      plot.margin = ggplot2::margin(10, 10, 10, 10)
    )

  print(p)
  invisible(x)
}

#' @export
as.character.insper_palette <- function(x, ...) {
  x <- unclass(x)
  attributes(x) <- NULL
  x
}


# show_insper_palettes() ----

#' Show All Insper Color Palettes
#'
#' Displays all Insper palettes as a stacked swatch grid, optionally filtered
#' by type. Invisibly returns a data frame of palette metadata.
#'
#' @param type Character. Filter by palette type. One of \code{"all"},
#'   \code{"sequential"}, \code{"diverging"}, \code{"qualitative"}, or
#'   \code{"accent"}. Default \code{"all"}.
#'
#' @return Invisibly returns a data frame with columns \code{name},
#'   \code{type}, \code{n_colors}, and \code{recommended_use}.
#'
#' @family colors
#' @seealso \code{\link{insper_palette}}, \code{\link{scale_color_insper_d}}
#' @export
#' @examples
#' # Show all palettes
#' show_insper_palettes()
#'
#' # Show only sequential palettes
#' show_insper_palettes("sequential")
#'
#' # Capture metadata
#' meta <- show_insper_palettes()
show_insper_palettes <- function(
  type = c("all", "sequential", "diverging", "qualitative", "accent")
) {
  hex <- position <- palette <- NULL  # R CMD check

  type <- match.arg(type)

  meta <- palette_metadata()
  if (type != "all") {
    meta <- meta[meta$type == type, ]
  }

  rows <- lapply(seq_len(nrow(meta)), function(i) {
    pal_name <- meta$name[i]
    colors <- insper_palettes[[pal_name]]
    data.frame(
      palette = pal_name,
      position = seq_along(colors),
      hex = colors,
      stringsAsFactors = FALSE
    )
  })
  df <- do.call(rbind, rows)
  df$palette <- factor(df$palette, levels = rev(meta$name))

  p <- ggplot2::ggplot(df, ggplot2::aes(x = position, y = palette, fill = hex)) +
    ggplot2::geom_tile(width = 0.9, height = 0.8, color = "white", linewidth = 0.5) +
    ggplot2::scale_fill_identity() +
    ggplot2::scale_x_continuous(expand = ggplot2::expansion(add = 0.5)) +
    ggplot2::theme_minimal(base_size = 10) +
    ggplot2::theme(
      axis.title = ggplot2::element_blank(),
      axis.text.x = ggplot2::element_blank(),
      panel.grid = ggplot2::element_blank(),
      axis.text.y = ggplot2::element_text(hjust = 1, size = 9),
      plot.title = ggplot2::element_text(hjust = 0.5, face = "bold")
    ) +
    ggplot2::labs(title = "Insper Color Palettes")

  print(p)
  invisible(meta)
}
