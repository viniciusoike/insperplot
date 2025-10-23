#' Visualize All Individual Insper Colors
#'
#' Display all individual named colors (reds1, teals1, etc.) as a visual grid.
#' To extract colors by name for use in plots, use \code{\link{get_insper_colors}} instead.
#' To see palettes, use \code{\link{show_insper_palette}}.
#'
#' @param color_family Optional filter: "all", "reds", "oranges", "magentas",
#'   "teals", "grays", "basic". Default "all".
#' @return A ggplot2 object showing the colors
#'
#' @details
#' This function creates a visual display of individual colors available in the
#' Insper color system. These are atomic color units (like reds1, teals2) that
#' can be extracted using \code{\link{get_insper_colors}}.
#'
#' For palette visualization (collections of colors used in scales), use
#' \code{\link{show_insper_palette}} instead.
#'
#' @family colors
#' @seealso \code{\link{get_insper_colors}}, \code{\link{show_insper_palette}}, \code{\link{list_palettes}}
#' @export
#' @examples
#' # Show all individual colors
#' show_insper_colors()
#'
#' # Show only reds
#' show_insper_colors("reds")
#'
#' # Show only grays
#' show_insper_colors("grays")
show_insper_colors <- function(color_family = "all") {
  # Define variables to avoid R CMD check NOTE
  name <- hex <- text_color <- NULL

  cols <- insper_individual_colors

  if (color_family != "all") {
    pattern <- switch(color_family,
      "reds" = "^reds[0-9]",
      "oranges" = "^oranges[0-9]",
      "magentas" = "^magentas[0-9]",
      "teals" = "^teals[0-9]",
      "grays" = "^gray",
      "basic" = "^(white|black|off_white)",
      cli::cli_abort(c(
        "x" = "Invalid color family: {.val {color_family}}",
        "i" = "Choose: all, reds, oranges, magentas, teals, grays, basic"
      ))
    )
    cols <- cols[grepl(pattern, names(cols))]
  }

  # Create data frame for plotting
  df <- data.frame(
    name = names(cols),
    hex = as.character(cols),
    x = seq_along(cols),
    stringsAsFactors = FALSE
  )

  # Determine text color (white on dark, black on light)
  df$text_color <- ifelse(
    grDevices::col2rgb(df$hex)[1,] * 0.299 +
    grDevices::col2rgb(df$hex)[2,] * 0.587 +
    grDevices::col2rgb(df$hex)[3,] * 0.114 > 128,
    "black", "white"
  )

  # Create plot
  ggplot2::ggplot(df, ggplot2::aes(x = x, y = 1, fill = hex)) +
    ggplot2::geom_tile(width = 0.9, height = 0.9, color = "black") +
    ggplot2::scale_fill_identity() +
    ggplot2::geom_text(
      ggplot2::aes(label = paste0(name, "\n", hex), color = text_color),
      size = 3, fontface = "bold"
    ) +
    ggplot2::scale_color_identity() +
    ggplot2::theme_void() +
    ggplot2::labs(
      title = paste("Insper Individual Colors:", tools::toTitleCase(color_family)),
      subtitle = "Use get_insper_colors('name') to extract by name"
    ) +
    ggplot2::theme(
      plot.title = ggplot2::element_text(hjust = 0.5, size = 14, face = "bold"),
      plot.subtitle = ggplot2::element_text(hjust = 0.5, size = 10),
      plot.margin = ggplot2::margin(10, 10, 10, 10)
    )
}


#' Visualize Insper Color Palettes
#'
#' Display color palettes used by scale_*_insper_*() functions.
#' To see individual colors, use \code{\link{show_insper_colors}}.
#'
#' @param palette Character. Name of palette or "all". Use \code{\link{list_palettes}}
#'   to see available options. Default "all".
#' @return A ggplot2 object
#'
#' @details
#' This function visualizes the palettes that are used by ggplot2 scale functions
#' like \code{\link{scale_fill_insper_d}} and \code{\link{scale_color_insper_c}}.
#'
#' Available palettes: main, reds, oranges, teals, grays, red_teal, red_teal_ext,
#' diverging, bright, contrast, categorical, accent.
#'
#' @family colors
#' @seealso \code{\link{list_palettes}}, \code{\link{insper_pal}}, \code{\link{show_insper_colors}}
#' @export
#' @examples
#' # Show single palette
#' show_insper_palette("reds")
#' show_insper_palette("red_teal")
#'
#' # Show all palettes
#' show_insper_palette()
#' show_insper_palette("all")
show_insper_palette <- function(palette = "all") {
  # Define variables to avoid R CMD check NOTE
  position <- hex <- NULL

  if (palette == "all") {
    # Show all palettes using existing function
    return(show_palette_types())
  }

  # Validate palette name
  if (!palette %in% names(insper_palettes)) {
    available <- paste(names(insper_palettes), collapse = ", ")
    cli::cli_abort(c(
      "x" = "Palette {.val {palette}} not found.",
      "i" = "Available: {available}",
      "i" = "See {.fn list_palettes} for details"
    ))
  }

  # Get palette colors
  colors <- insper_palettes[[palette]]

  # Get palette info
  pal_info <- list_palettes()
  pal_data <- pal_info[pal_info$name == palette, ]

  # Create plot data
  df <- data.frame(
    position = seq_along(colors),
    hex = colors,
    stringsAsFactors = FALSE
  )

  # Create plot
  ggplot2::ggplot(df, ggplot2::aes(x = position, y = 1, fill = hex)) +
    ggplot2::geom_tile(width = 0.9, height = 1, color = "white", linewidth = 1) +
    ggplot2::scale_fill_identity() +
    ggplot2::geom_text(
      ggplot2::aes(label = hex),
      size = 3, fontface = "bold", angle = 90, color = "white"
    ) +
    ggplot2::theme_void() +
    ggplot2::labs(
      title = paste0("Palette: ", palette),
      subtitle = paste0(
        tools::toTitleCase(pal_data$type), " | ",
        pal_data$n_colors, " colors | ",
        pal_data$recommended_use
      )
    ) +
    ggplot2::theme(
      plot.title = ggplot2::element_text(hjust = 0.5, size = 14, face = "bold"),
      plot.subtitle = ggplot2::element_text(hjust = 0.5, size = 10),
      plot.margin = ggplot2::margin(10, 10, 10, 10)
    )
}

#' Save Insper Plot
#'
#' Enhanced ggsave with institutional defaults and ragg device support
#'
#' @param plot ggplot object
#' @param filename File name
#' @param width Plot width in inches
#' @param height Plot height in inches
#' @param dpi Resolution
#' @param device Graphics device to use. If NULL (default), automatically uses
#'   ragg::agg_png() for PNG files when ragg is installed, otherwise falls back
#'   to ggplot2 defaults. You can override by passing a device function.
#' @param ... Additional arguments passed to ggsave
#'
#' @details
#' This function automatically uses the ragg device for PNG output when available,
#' which provides better font rendering and eliminates DPI issues. To set up ragg,
#' see \code{\link{use_ragg_device}}.
#'
#' @family utilities
#' @seealso \code{\link[ggplot2]{ggsave}}, \code{\link{use_ragg_device}}
#' @export
save_insper_plot <- function(
  plot,
  filename,
  width = height * 1.618,
  height = 4.3,
  dpi = 300,
  device = NULL,
  ...
) {
  # Auto-detect ragg for PNG files if device not specified
  if (is.null(device) && grepl("\\.png$", filename, ignore.case = TRUE)) {
    if (requireNamespace("ragg", quietly = TRUE)) {
      device <- ragg::agg_png
      if (interactive()) {
        message("Using ragg device for high-quality output")
      }
    }
  }

  ggplot2::ggsave(
    filename = filename,
    plot = plot,
    width = width,
    height = height,
    dpi = dpi,
    device = device,
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
insper_caption <- function(
  text = NULL,
  source = NULL,
  date = NULL,
  lang = "pt"
) {
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
      cli::cli_warn(
        "Invalid date supplied. Using current day with {.fun Sys.Date()}."
      )
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
    formatted <- scales::comma(
      x,
      accuracy = 10^(-digits),
      big.mark = ".",
      decimal.mark = ","
    )
  }

  return(formatted)
}

#' Import Insper Fonts from Google Fonts
#'
#' Loads Insper's recommended fonts (Inter, EB Garamond, and Playfair Display)
#' from Google Fonts using the showtext package. This allows using custom fonts
#' without installing them locally on your system.
#'
#' @param enable Logical. If TRUE, automatically enables showtext for
#'   rendering. If FALSE (default, recommended), fonts are registered but you must call
#'   \code{showtext::showtext_auto()} manually. **Warning**: Enabling showtext can cause
#'   DPI conflicts - consider using local font installation with ragg device instead.
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
import_insper_fonts <- function(enable = FALSE, verbose = TRUE) {
  # Check if showtext and sysfonts are available
  has_showtext <- requireNamespace("showtext", quietly = TRUE)
  has_sysfonts <- requireNamespace("sysfonts", quietly = TRUE)

  if (!has_showtext || !has_sysfonts) {
    if (verbose) {
      cli::cli_alert_warning(
        "Packages {.pkg showtext} and {.pkg sysfonts} required to import fonts"
      )
      cli::cli_alert_info(
        "Install with: {.code install.packages(c('showtext', 'sysfonts'))}"
      )
      cli::cli_alert_info(
        "Or install fonts locally - see {.code ?check_insper_fonts}"
      )
    }
    return(invisible(FALSE))
  }

  # Try to import fonts from Google Fonts
  tryCatch(
    {
      # Import Inter (sans-serif, for body text - official template)
      sysfonts::font_add_google("Inter", "Inter")

      # Import EB Garamond (serif, fallback for titles)
      sysfonts::font_add_google("EB Garamond", "EB Garamond")

      # Import Playfair Display (serif, alternative for titles)
      sysfonts::font_add_google("Playfair Display", "Playfair Display")

      # Enable showtext for rendering if requested
      if (enable) {
        showtext::showtext_auto()
      }

      # Set package option to track font loading status
      options(insperplot.fonts_loaded = TRUE)

      if (verbose) {
        cli::cli_alert_success("Insper fonts loaded from Google Fonts")
        cli::cli_bullets(c(
          "v" = "Inter (sans-serif) - for body text",
          "v" = "EB Garamond (serif) - for titles (fallback)",
          "v" = "Playfair Display (serif) - for titles (alternative)"
        ))
        cli::cli_alert_info("Georgia (system font) used as primary title font")
      }

      return(invisible(TRUE))
    },
    error = function(e) {
      if (verbose) {
        cli::cli_alert_danger("Failed to load fonts from Google Fonts")
        cli::cli_alert_info("Error: {e$message}")
        cli::cli_alert_info(
          "Alternative: Install fonts locally - see {.code ?check_insper_fonts}"
        )
      }
      return(invisible(FALSE))
    }
  )
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
#' The recommended fonts based on Insper's official template:
#' \itemize{
#'   \item **Georgia**: System serif font for titles (primary)
#'   \item **Inter**: Modern sans-serif font for body text (Google Font)
#'   \item **EB Garamond**: Classical serif font for titles (fallback, Google Font)
#'   \item **Playfair Display**: Elegant serif font for titles (alternative, Google Font)
#' }
#'
#' **Two ways to use these fonts:**
#'
#' **Option A - Local Installation (permanent, recommended for development):**
#' \enumerate{
#'   \item Visit \url{https://fonts.google.com}
#'   \item Search for "Inter", "EB Garamond", and "Playfair Display"
#'   \item Download and install fonts on your system
#'   \item Restart R/RStudio
#'   \item Note: Georgia is typically pre-installed on most systems
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
      cli::cli_alert_warning(
        "Could not detect system fonts. Install {.pkg systemfonts} for font checking."
      )
    }
    return(invisible(c(
      "Georgia" = FALSE,
      "Inter" = fonts_imported,
      "EB Garamond" = fonts_imported,
      "Playfair Display" = fonts_imported
    )))
  }

  # Check for recommended fonts (locally installed)
  has_georgia <- any(grepl("Georgia", available_fonts, ignore.case = TRUE))
  has_inter <- any(grepl("Inter", available_fonts, ignore.case = TRUE))
  has_garamond <- any(grepl(
    "EB Garamond|Garamond",
    available_fonts,
    ignore.case = TRUE
  ))
  has_playfair <- any(grepl(
    "Playfair Display|Playfair",
    available_fonts,
    ignore.case = TRUE
  ))

  # Fonts available if either imported OR installed locally
  georgia_available <- has_georgia # System font, not imported via showtext
  inter_available <- has_inter || fonts_imported
  garamond_available <- has_garamond || fonts_imported
  playfair_available <- has_playfair || fonts_imported

  font_status <- c(
    "Georgia" = georgia_available,
    "Inter" = inter_available,
    "EB Garamond" = garamond_available,
    "Playfair Display" = playfair_available
  )

  if (verbose) {
    cli::cli_h2("Insper Font Status")

    if (fonts_imported) {
      cli::cli_alert_success(
        "Fonts loaded via {.fun import_insper_fonts} (current session)"
      )
    }

    # Georgia (system font, primary for titles)
    if (has_georgia) {
      cli::cli_alert_success(
        "Georgia (serif, primary for titles) - system font"
      )
    } else {
      cli::cli_alert_warning("Georgia (serif) not found - will use fallbacks")
    }

    # Inter (body text from official template)
    if (has_inter) {
      cli::cli_alert_success("Inter (sans-serif, body text) installed locally")
    } else if (fonts_imported) {
      cli::cli_alert_success("Inter (sans-serif, body text) loaded via import")
    } else {
      cli::cli_alert_danger("Inter (sans-serif, body text) not found")
    }

    # EB Garamond (title fallback)
    if (has_garamond) {
      cli::cli_alert_success(
        "EB Garamond (serif, title fallback) installed locally"
      )
    } else if (fonts_imported) {
      cli::cli_alert_success(
        "EB Garamond (serif, title fallback) loaded via import"
      )
    } else {
      cli::cli_alert_warning("EB Garamond (serif, title fallback) not found")
    }

    # Playfair Display (title alternative)
    if (has_playfair) {
      cli::cli_alert_success(
        "Playfair Display (serif, title alternative) installed locally"
      )
    } else if (fonts_imported) {
      cli::cli_alert_success(
        "Playfair Display (serif, title alternative) loaded via import"
      )
    } else {
      cli::cli_alert_warning(
        "Playfair Display (serif, title alternative) not found"
      )
    }

    all_available <- all(c(
      georgia_available,
      inter_available,
      garamond_available,
      playfair_available
    ))

    if (!all_available) {
      cli::cli_h3("Font Setup Needed")

      cli::cli_alert_warning("Some fonts not found. Run the setup wizard:")
      cli::cli_code("setup_insper_fonts()")
      cli::cli_text("")

      cli::cli_alert_info("Or install manually:")
      cli::cli_ol(c(
        "Visit {.url https://fonts.google.com}",
        "Search for: {.strong Inter}, {.strong EB Garamond}, and {.strong Playfair Display}",
        "Download and install fonts on your system",
        "Restart R/RStudio",
        "Note: Georgia is typically pre-installed on most systems"
      ))

      cli::cli_alert_info(
        "Plots will use system fallback fonts until fonts are installed"
      )
    } else {
      cli::cli_alert_success("All recommended fonts are available!")
      cli::cli_text("")

      # Check ragg and provide recommendation
      has_ragg <- requireNamespace("ragg", quietly = TRUE)
      if (!has_ragg) {
        cli::cli_alert_info("For best results, also install {.pkg ragg}:")
        cli::cli_code("install.packages('ragg')")
        cli::cli_text("Then run: {.code use_ragg_device()}")
      }
    }
  }

  invisible(font_status)
}

#' Configure ragg Graphics Device
#'
#' Helper function to check if ragg is installed and provide setup instructions.
#' The ragg package provides high-quality graphics devices that work seamlessly
#' with system fonts, eliminating DPI issues and per-session font loading.
#'
#' @param set_rstudio Logical. If TRUE and running in RStudio, provides instructions
#'   to set ragg as the default graphics device. Default is TRUE.
#' @param verbose Logical. If TRUE, prints detailed information about ragg status
#'   and setup. Default is TRUE.
#'
#' @return Invisibly returns TRUE if ragg is installed, FALSE otherwise.
#'
#' @details
#' **Why ragg?**
#'
#' The ragg package (based on Anti-Grain Geometry) is the modern standard for
#' R graphics in 2025. It provides:
#' \itemize{
#'   \item Direct access to all system fonts (no per-session loading)
#'   \item No DPI conflicts (unlike showtext)
#'   \item Better performance (~2x faster than cairo)
#'   \item Cross-platform consistency
#'   \item Automatic use by \code{ggsave()} when installed
#' }
#'
#' **Setup Steps:**
#'
#' 1. Install ragg: \code{install.packages("ragg")}
#' 2. In RStudio: Tools > Global Options > General > Graphics > Backend > AGG
#' 3. Restart R session
#'
#' After setup, all plots will use ragg automatically, including IDE preview
#' and \code{ggsave()} output.
#'
#' @family utilities
#' @seealso \code{\link{setup_insper_fonts}}, \code{\link{save_insper_plot}}
#' @export
#' @examples
#' # Check ragg installation status
#' use_ragg_device()
use_ragg_device <- function(set_rstudio = TRUE, verbose = TRUE) {
  # Check if ragg is installed
  has_ragg <- requireNamespace("ragg", quietly = TRUE)

  if (verbose) {
    cli::cli_h2("ragg Graphics Device Status")

    if (has_ragg) {
      cli::cli_alert_success("{.pkg ragg} is installed")

      # Check if running in RStudio
      if (set_rstudio && Sys.getenv("RSTUDIO") == "1") {
        cli::cli_h3("RStudio Setup")
        cli::cli_alert_info("To set ragg as your default graphics device:")
        cli::cli_ol(c(
          "Go to: {.strong Tools > Global Options > General > Graphics}",
          "Set {.strong Backend} to {.strong AGG}",
          "Click {.strong OK} and restart R session"
        ))
      }

      cli::cli_h3("Benefits")
      cli::cli_bullets(c(
        "v" = "Direct access to all system fonts",
        "v" = "No DPI conflicts (unlike showtext)",
        "v" = "Better performance (~2x faster)",
        "v" = "Automatically used by {.fun ggsave}"
      ))

      cli::cli_alert_success(
        "You're all set! ragg will work automatically with ggsave()"
      )
    } else {
      cli::cli_alert_danger("{.pkg ragg} is not installed")
      cli::cli_h3("Installation")
      cli::cli_alert_info("Install ragg with:")
      cli::cli_code("install.packages('ragg')")

      cli::cli_h3("Why ragg?")
      cli::cli_bullets(c(
        "*" = "Modern standard for R graphics (2025)",
        "*" = "No font loading overhead - uses system fonts directly",
        "*" = "Eliminates DPI issues with showtext",
        "*" = "Better quality and performance"
      ))
    }
  }

  invisible(has_ragg)
}


#' Interactive Setup Wizard for Insper Fonts and Graphics
#'
#' Interactive guide to set up insperplot with optimal font and graphics device
#' configuration. This function checks your system and provides step-by-step
#' instructions for the best setup.
#'
#' @param check_only Logical. If TRUE, only checks current setup without providing
#'   interactive guidance. Default is FALSE.
#'
#' @return Invisibly returns a list with setup status:
#'   \itemize{
#'     \item fonts_installed: Are Insper fonts installed locally?
#'     \item ragg_installed: Is ragg package installed?
#'     \item setup_complete: Is setup complete and optimal?
#'   }
#'
#' @details
#' This function provides an interactive wizard that:
#' \enumerate{
#'   \item Checks if Insper fonts (EB Garamond, Barlow) are installed locally
#'   \item Checks if ragg package is installed
#'   \item Provides tailored setup instructions based on your system
#'   \item Guides you to the optimal configuration
#' }
#'
#' **Recommended Setup (Best Performance):**
#' \enumerate{
#'   \item Install Insper fonts locally from Google Fonts
#'   \item Install ragg package
#'   \item Set RStudio graphics backend to AGG
#' }
#'
#' This setup provides:
#' \itemize{
#'   \item No DPI conflicts
#'   \item No per-session font loading
#'   \item Best rendering quality
#'   \item Optimal performance
#' }
#'
#' @family utilities
#' @seealso \code{\link{check_insper_fonts}}, \code{\link{use_ragg_device}}
#' @export
#' @examples
#' # Run interactive setup wizard
#' setup_insper_fonts()
#'
#' # Check current setup status
#' setup_insper_fonts(check_only = TRUE)
setup_insper_fonts <- function(check_only = FALSE) {
  # Check current status
  fonts_imported <- isTRUE(getOption("insperplot.fonts_loaded", FALSE))
  has_ragg <- requireNamespace("ragg", quietly = TRUE)
  has_systemfonts <- requireNamespace("systemfonts", quietly = TRUE)

  # Check for locally installed fonts
  fonts_installed <- FALSE
  if (has_systemfonts) {
    available_fonts <- try(systemfonts::system_fonts()$family, silent = TRUE)
    if (!inherits(available_fonts, "try-error")) {
      has_garamond <- any(grepl(
        "EB Garamond|Garamond",
        available_fonts,
        ignore.case = TRUE
      ))
      has_barlow <- any(grepl("Barlow", available_fonts, ignore.case = TRUE))
      fonts_installed <- has_garamond && has_barlow
    }
  }

  setup_status <- list(
    fonts_installed = fonts_installed,
    ragg_installed = has_ragg,
    setup_complete = fonts_installed && has_ragg
  )

  if (check_only) {
    return(invisible(setup_status))
  }

  # Interactive wizard
  cli::cli_h1("insperplot Setup Wizard")
  cli::cli_text("")

  # Status overview
  cli::cli_h2("Current Status")
  cli::cli_bullets(c(
    if (fonts_installed) {
      "v"
    } else {
      "x" ~
        "Insper fonts installed locally: {.strong {if(fonts_installed) 'YES' else 'NO'}}"
    },
    if (has_ragg) {
      "v"
    } else {
      "x" ~ "ragg package installed: {.strong {if(has_ragg) 'YES' else 'NO'}}"
    },
    if (fonts_imported) {
      "i"
    } else {
      " " ~
        "Fonts loaded via showtext: {.strong {if(fonts_imported) 'YES (not recommended)' else 'NO'}}"
    }
  ))
  cli::cli_text("")

  # Provide recommendations
  if (setup_status$setup_complete) {
    cli::cli_alert_success("Excellent! Your setup is optimal.")
    cli::cli_text("")
    cli::cli_h3("You're ready to create beautiful plots!")
    cli::cli_text("Example:")
    cli::cli_code("library(ggplot2)")
    cli::cli_code(
      "ggplot(mtcars, aes(wt, mpg)) + geom_point() + theme_insper()"
    )
    cli::cli_text("")
    if (Sys.getenv("RSTUDIO") == "1") {
      cli::cli_alert_info(
        "Don't forget to set RStudio graphics backend to AGG:"
      )
      cli::cli_text(
        "{.strong Tools > Global Options > General > Graphics > Backend > AGG}"
      )
    }
  } else {
    cli::cli_h2("Setup Steps")
    cli::cli_text("")

    step_num <- 1

    # Step 1: Install fonts if needed
    if (!fonts_installed) {
      cli::cli_h3("Step {step_num}: Install Insper Fonts Locally")
      cli::cli_ol(c(
        "Visit {.url https://fonts.google.com}",
        "Search for {.strong EB Garamond} and download/install",
        "Search for {.strong Barlow} and download/install",
        "Restart R/RStudio after installation"
      ))
      cli::cli_text("")
      cli::cli_alert_info(
        "After installing, run {.code check_insper_fonts()} to verify"
      )
      cli::cli_text("")
      step_num <- step_num + 1
    }

    # Step 2: Install ragg if needed
    if (!has_ragg) {
      cli::cli_h3("Step {step_num}: Install ragg Package")
      cli::cli_code("install.packages('ragg')")
      cli::cli_text("")
      cli::cli_alert_info(
        "After installing, run {.code use_ragg_device()} for setup"
      )
      cli::cli_text("")
      step_num <- step_num + 1
    }

    # Step 3: Configure RStudio
    if (Sys.getenv("RSTUDIO") == "1") {
      cli::cli_h3("Step {step_num}: Configure RStudio Graphics")
      cli::cli_ol(c(
        "Go to: {.strong Tools > Global Options > General > Graphics}",
        "Set {.strong Backend} to {.strong AGG}",
        "Click {.strong OK} and restart R session"
      ))
      cli::cli_text("")
    }

    cli::cli_rule()
    cli::cli_h3("Why This Setup?")
    cli::cli_bullets(c(
      "v" = "No DPI conflicts (unlike showtext)",
      "v" = "No per-session font loading overhead",
      "v" = "Better rendering quality and performance",
      "v" = "Cross-platform consistency",
      "v" = "Modern best practice (2025)"
    ))
  }

  invisible(setup_status)
}
