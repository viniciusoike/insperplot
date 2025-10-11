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

    # Reds - Updated to match Insper's primary red (#E4002B)
    `reds1` = "#E4002B",  # Primary Insper Red
    `reds2` = "#FCA5A8",  # Light red
    `reds3` = "#A50020",  # Dark red

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
    # Support both old color group names and new palette names
    pattern <- switch(palette,
                      "grays" = "gray",
                      "grays_seq" = "gray",
                      "reds" = "red",
                      "reds_seq" = "red",
                      "oranges" = "orange",
                      "oranges_seq" = "orange",
                      "magentas" = "magenta",
                      "teals" = "teal",
                      "teals_seq" = "teal",
                      "qualitative_main" = "^(reds1|oranges1|teals1|gray_meddark)",
                      "qualitative_bright" = "^(reds1|oranges1|teals1|magentas)",
                      "qualitative_contrast" = "^(reds1|oranges2|teals1|magentas1|gray_meddark)",
                      stop("Invalid palette. Choose: all, grays, reds, oranges, magentas, teals, or palette names like reds_seq, qualitative_main, etc.")
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

#' Import Insper Fonts from Google Fonts
#'
#' Loads Insper's recommended fonts (EB Garamond and Barlow) from Google Fonts
#' using the showtext package. This allows using custom fonts without installing
#' them locally on your system.
#'
#' @param enable Logical. If TRUE (default), automatically enables showtext for
#'   rendering. If FALSE, fonts are registered but you must call
#'   \code{showtext::showtext_auto()} manually.
#' @param verbose Logical. If TRUE (default), prints status messages about font
#'   loading.
#'
#' @return Invisibly returns TRUE if fonts loaded successfully, FALSE otherwise.
#'
#' @details
#' This function provides an alternative to installing fonts locally on your
#' system. It uses the \pkg{showtext} package to load fonts directly from
#' Google Fonts each R session.
#'
#' **Two ways to use Insper fonts:**
#'
#' 1. **Local Installation (permanent)**: Download and install fonts from
#'    \url{https://fonts.google.com} on your system. Use
#'    \code{\link{check_insper_fonts}()} to verify installation.
#'
#' 2. **Remote Loading (per-session)**: Use this function to load fonts from
#'    Google Fonts for the current session only. Fonts must be loaded each
#'    time you start R.
#'
#' The package attempts to load fonts automatically when loaded via
#' \code{library(insperplot)}. If automatic loading fails, call this function
#' manually.
#'
#' @family utilities
#' @seealso \code{\link{check_insper_fonts}}
#' @export
#' @examples
#' \dontrun{
#' # Load Insper fonts from Google Fonts
#' import_insper_fonts()
#'
#' # Now create plots with custom fonts
#' library(ggplot2)
#' ggplot(mtcars, aes(wt, mpg)) +
#'   geom_point() +
#'   theme_insper()
#' }
import_insper_fonts <- function(enable = TRUE, verbose = TRUE) {

  # Check if showtext and sysfonts are available
  has_showtext <- requireNamespace("showtext", quietly = TRUE)
  has_sysfonts <- requireNamespace("sysfonts", quietly = TRUE)

  if (!has_showtext || !has_sysfonts) {
    if (verbose) {
      cli::cli_alert_warning("Packages {.pkg showtext} and {.pkg sysfonts} required to import fonts")
      cli::cli_alert_info("Install with: {.code install.packages(c('showtext', 'sysfonts'))}")
      cli::cli_alert_info("Or install fonts locally - see {.code ?check_insper_fonts}")
    }
    return(invisible(FALSE))
  }

  # Try to import fonts from Google Fonts
  tryCatch({
    # Import EB Garamond (serif, for titles)
    sysfonts::font_add_google("EB Garamond", "EB Garamond")

    # Import Barlow (sans-serif, for body text)
    sysfonts::font_add_google("Barlow", "Barlow")

    # Enable showtext for rendering if requested
    if (enable) {
      showtext::showtext_auto()
    }

    # Set package option to track font loading status
    options(insperplot.fonts_loaded = TRUE)

    if (verbose) {
      cli::cli_alert_success("Insper fonts loaded from Google Fonts")
      cli::cli_bullets(c(
        "v" = "EB Garamond (serif) - for titles",
        "v" = "Barlow (sans-serif) - for body text"
      ))
    }

    return(invisible(TRUE))

  }, error = function(e) {
    if (verbose) {
      cli::cli_alert_danger("Failed to load fonts from Google Fonts")
      cli::cli_alert_info("Error: {e$message}")
      cli::cli_alert_info("Alternative: Install fonts locally - see {.code ?check_insper_fonts}")
    }
    return(invisible(FALSE))
  })
}


#' Check Insper Font Availability
#'
#' Checks if recommended Insper fonts are available (either installed locally
#' or loaded via \code{\link{import_insper_fonts}}) and provides setup
#' instructions if they're missing.
#'
#' @param verbose Logical. If TRUE, prints detailed information about font status.
#'   Default is TRUE.
#' @return Invisibly returns a named logical vector indicating which fonts are available.
#'
#' @details
#' The recommended fonts are free Google Fonts:
#' \itemize{
#'   \item **EB Garamond**: Classical serif font for titles
#'   \item **Barlow**: Modern sans-serif font for body text
#' }
#'
#' **Two ways to use these fonts:**
#'
#' **Option A - Local Installation (permanent, recommended for development):**
#' \enumerate{
#'   \item Visit \url{https://fonts.google.com}
#'   \item Search for "EB Garamond" and "Barlow"
#'   \item Download and install fonts on your system
#'   \item Restart R/RStudio
#' }
#'
#' **Option B - Remote Loading (per-session, recommended for scripts/reproducibility):**
#' \enumerate{
#'   \item Install showtext: \code{install.packages(c("showtext", "sysfonts"))}
#'   \item Load fonts: \code{import_insper_fonts()}
#'   \item Fonts available for current R session
#' }
#'
#' If fonts are unavailable, plots automatically fall back to system defaults
#' (serif/sans).
#'
#' @family utilities
#' @seealso \code{\link{import_insper_fonts}}
#' @export
#' @examples
#' # Check font availability
#' check_insper_fonts()
check_insper_fonts <- function(verbose = TRUE) {

  # Check if fonts loaded via import_insper_fonts()
  fonts_imported <- isTRUE(getOption("insperplot.fonts_loaded", FALSE))

  # Get list of locally installed fonts (platform-specific)
  available_fonts <- try(systemfonts::system_fonts()$family, silent = TRUE)

  if (inherits(available_fonts, "try-error")) {
    if (verbose) {
      cli::cli_alert_warning("Could not detect system fonts. Install {.pkg systemfonts} for font checking.")
    }
    return(invisible(c("EB Garamond" = fonts_imported, "Barlow" = fonts_imported)))
  }

  # Check for recommended fonts (locally installed)
  has_garamond <- any(grepl("EB Garamond|Garamond", available_fonts, ignore.case = TRUE))
  has_barlow <- any(grepl("Barlow", available_fonts, ignore.case = TRUE))

  # Fonts available if either imported OR installed locally
  garamond_available <- has_garamond || fonts_imported
  barlow_available <- has_barlow || fonts_imported

  font_status <- c("EB Garamond" = garamond_available, "Barlow" = barlow_available)

  if (verbose) {
    cli::cli_h2("Insper Font Status")

    if (fonts_imported) {
      cli::cli_alert_success("Fonts loaded via {.fun import_insper_fonts} (current session)")
    }

    if (has_garamond) {
      cli::cli_alert_success("EB Garamond (serif) installed locally")
    } else if (!fonts_imported) {
      cli::cli_alert_danger("EB Garamond (serif) not found")
    }

    if (has_barlow) {
      cli::cli_alert_success("Barlow (sans-serif) installed locally")
    } else if (!fonts_imported) {
      cli::cli_alert_danger("Barlow (sans-serif) not found")
    }

    if (!garamond_available || !barlow_available) {
      cli::cli_h3("Font Setup Options")

      cli::cli_alert_info("Option A - Local Install (permanent):")
      cli::cli_ol(c(
        "Visit {.url https://fonts.google.com}",
        "Search for: {.strong EB Garamond} and {.strong Barlow}",
        "Download and install fonts on your system",
        "Restart R/RStudio"
      ))

      cli::cli_alert_info("Option B - Remote Load (per-session):")
      cli::cli_ol(c(
        "Install packages: {.code install.packages(c('showtext', 'sysfonts'))}",
        "Load fonts: {.code import_insper_fonts()}"
      ))

      cli::cli_alert_info("Plots will use system fallback fonts until setup complete")
    } else {
      cli::cli_alert_success("All recommended fonts are available!")
    }
  }

  invisible(font_status)
}
