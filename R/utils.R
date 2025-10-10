#' Extract Insper Colors
#'
#' Extract hex codes from the Insper color palette
#'
#' @param ... Character names of colors. If none provided, returns all colors.
#' @return Named character vector of hex codes
#' @family colors
#' @seealso \code{\link{insper_pal}}, \code{\link{show_insper_palette}}
#' @export
#' @examples
#' insper_col()
#' insper_col("reds1", "teals1")
insper_col <- function(...) {
  cols <- c(

    # Basic
    `white` = "#ffffff",
    `off_white` = "#fefefe",
    `black` = "#000000",

    # Grays
    `gray_dark` = "gray20",
    `gray_meddark` = "#414042",
    `gray_med` = "#BCBEC0",
    `gray_light` = "#E6E7E8",

    # Reds
    `reds1` = "#C4161C",
    `reds2` = "#E80724",
    `reds3` = "#F69679",

    # Oranges
    `oranges1` = "#F15A22",
    `oranges2` = "#F58220",
    `oranges3` = "#FAA61A",

    # Magentas
    `magentas1` = "#A62B4D",
    `magentas2` = "#C43150",
    `magentas3` = "#EE2A5D",

    # Teals
    `teals1` = "#009491",
    `teals2` = "#27A5A2",
    `teals3` = "#3CBFAE"
  )

  if (length(list(...)) == 0) {
    return(cols)
  } else {
    return(cols[c(...)])
  }
}


#' Show Insper Color Palette
#'
#' Display the Insper color palette visually
#'
#' @param palette Character string specifying palette subset ("all", "grays", "reds", "oranges", "magentas", "teals")
#' @return A ggplot2 object showing the color palette
#' @family colors
#' @seealso \code{\link{insper_col}}, \code{\link{insper_pal}}
#' @export
#' @examples
#' show_insper_palette()
#' show_insper_palette("reds")
show_insper_palette <- function(palette = "all") {
  cols <- insper_col()

  if (palette != "all") {
    pattern <- switch(palette,
                      "grays" = "gray",
                      "reds" = "red",
                      "oranges" = "orange",
                      "magentas" = "magenta",
                      "teals" = "teal",
                      stop("Invalid palette. Choose: all, grays, reds, oranges, magentas, teals")
    )
    cols <- cols[grepl(pattern, names(cols))]

    df <- data.frame(
      color = names(cols),
      hex = as.character(cols),
      y = 1,
      x = seq_along(cols),
      reverse_col = factor(rep(0, length(cols)))
    )

  } else {
    df <- data.frame(
      color = names(cols),
      hex = as.character(cols),
      y = c(1, 1, 1, 2, 2, 2, 2, rep(3:6, each = 3)),
      x = c(1, 2, 3, 1, 2, 3, 4, rep(1:3, 4)),
      reverse_col = factor(c(1, 1, 0, 0, 0, 1, 1, rep(0, 12)))
    )
  }

  ggplot2::ggplot(df, ggplot2::aes(x = x, y = y, fill = hex)) +
    ggplot2::geom_tile(width = 0.9, height = 0.9, color = "black") +
    ggplot2::scale_fill_identity() +
    ggplot2::geom_text(
      ggplot2::aes(label = paste0(color, "\n", hex), color = reverse_col),
      size = 3,
      fontface = "bold") +
    ggplot2::scale_color_manual(values = c("white", "black")) +
    ggplot2::guides(color = "none") +
    ggplot2::theme_void() +
    ggplot2::labs(title = paste("Insper Color Palette:", tools::toTitleCase(palette))) +
    ggplot2::theme(plot.title = ggplot2::element_text(hjust = 0.5, size = 14),
                   plot.background = ggplot2::element_rect(fill = "gray90"))
}

#' Save Insper Plot
#'
#' Enhanced ggsave with institutional defaults
#'
#' @param plot ggplot object
#' @param filename File name
#' @param width Plot width in inches
#' @param height Plot height in inches
#' @param dpi Resolution
#' @param ... Additional arguments passed to ggsave
#' @family utilities
#' @seealso \code{\link[ggplot2]{ggsave}}
#' @export
save_insper_plot <- function(plot, filename, width = height * 1.618, height = 6, dpi = 300, ...) {

  ggplot2::ggsave(
    filename = filename,
    plot = plot,
    width = width,
    height = height,
    dpi = dpi,
    bg = "white",
    ...
  )

  message("Plot saved: ", filename)
}

#' Insper Caption
#'
#' Standardized caption formatting with institutional attribution
#'
#' @param text Caption text
#' @param source Data source
#' @param date Date of analysis
#' @param lang Language for labels ("pt" for Portuguese, "en" for English). Default is "pt"
#' @return Formatted caption string
#' @family utilities
#' @importFrom lubridate month
#' @export
insper_caption <- function(text = NULL, source = NULL, date = NULL, lang = "pt") {

  caption_parts <- c()

  if (!is.null(text)) {
    caption_parts <- c(caption_parts, text)
  }

  if (!is.null(source)) {
    prefix_source <- ifelse(lang == "pt", "Fonte:", "Source:")
    caption_parts <- c(caption_parts, paste(prefix_source, source))
  }

  if (!is.null(date)) {
    if (!inherits(date, "Date")) {
      date = Sys.Date()
      cli::cli_warn("Invalid date supplied. Using current day with {.fun Sys.Date()}.")
    }
    caption_parts <- c(caption_parts, paste("Insper |", format(date, "%B %Y")))
  }

  return(paste(caption_parts, collapse = " | "))
}

#' Format Brazilian Currency
#'
#' Format numbers as Brazilian Real currency
#'
#' @param x Numeric vector
#' @param symbol Include R$ symbol
#' @return Formatted character vector
#' @family utilities
#' @export
format_brl <- function(x, symbol = TRUE) {

  formatted <- scales::comma(x, big.mark = ".", decimal.mark = ",")

  if (symbol) {
    formatted <- paste("R$", formatted)
  }

  return(formatted)
}

#' Format Brazilian Percentage
#'
#' Format numbers as Brazilian-style percentages
#'
#' @param x Numeric vector (proportion, not percentage)
#' @param digits Number of decimal places
#' @return Formatted character vector
#' @family utilities
#' @export
format_percent_br <- function(x, digits = 1) {

  formatted <- scales::percent(x, accuracy = 10^(-digits), decimal.mark = ",")

  return(formatted)
}


#' Format Brazilian Numbers
#'
#' Format numbers in Brazilian style with decimal comma and thousand separator
#'
#' @param x Numeric vector
#' @param digits Number of decimal places
#' @return Formatted character vector
#' @family utilities
#' @export
format_num_br <- function(x, digits = NULL) {

  if (is.null(digits)) {
    formatted <- scales::comma(x, big.mark = ".", decimal.mark = ",")
  } else {
    formatted <- scales::comma(x, accuracy = 10^(-digits), big.mark = ".", decimal.mark = ",")
  }

  return(formatted)
}
