#' Show Insper Colors
#'
#' Extract hex codes from the Insper color palette. This is a utility function
#' for retrieving color values, NOT a plotting function.
#'
#' @param ... Character names of colors. If none provided, returns all colors.
#' @return Named character vector of hex codes
#' @family colors
#' @seealso \code{\link{insper_pal}}, \code{\link{show_insper_palette}}
#' @note This is a color extraction utility, not a plotting function. For creating
#'   bar plots, use \code{\link{insper_barplot}} or \code{ggplot2::geom_col()}.
#' @export
#' @examples
#' # Get all colors
#' show_insper_colors()
#'
#' # Get specific colors
#' show_insper_colors("reds1", "teals1")
#'
#' # Use in plots
#' library(ggplot2)
#' ggplot(mtcars, aes(wt, mpg)) +
#'   geom_point(color = show_insper_colors("teals1"))
show_insper_colors <- function(...) {
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
    `reds1` = "#E4002B", # Primary Insper Red
    `reds2` = "#FCA5A8", # Light red
    `reds3` = "#A50020", # Dark red

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


#' Extract Insper Colors (Deprecated)
#'
#' This function has been renamed to \code{\link{show_insper_colors}} for clarity.
#'
#' @param ... Character names of colors. If none provided, returns all colors.
#' @return Named character vector of hex codes
#' @keywords internal
#' @export
insper_col <- function(...) {
  .Deprecated(
    new = "show_insper_colors()",
    msg = "insper_col() is deprecated and will be removed in a future version. Please use show_insper_colors() instead."
  )
  show_insper_colors(...)
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
  cols <- show_insper_colors()

  if (palette != "all") {
    # Support both old color group names and new palette names
    pattern <- switch(
      palette,
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
      stop(
        "Invalid palette. Choose: all, grays, reds, oranges, magentas, teals, or palette names like reds_seq, qualitative_main, etc."
      )
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
      fontface = "bold"
    ) +
    ggplot2::scale_color_manual(values = c("white", "black")) +
    ggplot2::guides(color = "none") +
    ggplot2::theme_void() +
    ggplot2::labs(
      title = paste("Insper Color Palette:", tools::toTitleCase(palette))
    ) +
    ggplot2::theme(
      plot.title = ggplot2::element_text(hjust = 0.5, size = 14),
      plot.background = ggplot2::element_rect(fill = "gray90")
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
  height = 6,
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
#' Loads Insper's recommended fonts (EB Garamond and Barlow) from Google Fonts
#' using the showtext package. This allows using custom fonts without installing
#' them locally on your system.
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
      cli::cli_alert_warning(
        "Could not detect system fonts. Install {.pkg systemfonts} for font checking."
      )
    }
    return(invisible(c(
      "EB Garamond" = fonts_imported,
      "Barlow" = fonts_imported
    )))
  }

  # Check for recommended fonts (locally installed)
  has_garamond <- any(grepl(
    "EB Garamond|Garamond",
    available_fonts,
    ignore.case = TRUE
  ))
  has_barlow <- any(grepl("Barlow", available_fonts, ignore.case = TRUE))

  # Fonts available if either imported OR installed locally
  garamond_available <- has_garamond || fonts_imported
  barlow_available <- has_barlow || fonts_imported

  font_status <- c(
    "EB Garamond" = garamond_available,
    "Barlow" = barlow_available
  )

  if (verbose) {
    cli::cli_h2("Insper Font Status")

    if (fonts_imported) {
      cli::cli_alert_success(
        "Fonts loaded via {.fun import_insper_fonts} (current session)"
      )
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
      cli::cli_h3("Font Setup Needed")

      cli::cli_alert_warning("Fonts not found. Run the setup wizard:")
      cli::cli_code("setup_insper_fonts()")
      cli::cli_text("")

      cli::cli_alert_info("Or install manually:")
      cli::cli_ol(c(
        "Visit {.url https://fonts.google.com}",
        "Search for: {.strong EB Garamond} and {.strong Barlow}",
        "Download and install fonts on your system",
        "Restart R/RStudio"
      ))

      cli::cli_alert_info(
        "Plots will use system fallback fonts (serif/sans) until fonts are installed"
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

      cli::cli_alert_success("You're all set! ragg will work automatically with ggsave()")
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
      has_garamond <- any(grepl("EB Garamond|Garamond", available_fonts, ignore.case = TRUE))
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
    if (fonts_installed) "v" else "x" ~ "Insper fonts installed locally: {.strong {if(fonts_installed) 'YES' else 'NO'}}",
    if (has_ragg) "v" else "x" ~ "ragg package installed: {.strong {if(has_ragg) 'YES' else 'NO'}}",
    if (fonts_imported) "i" else " " ~ "Fonts loaded via showtext: {.strong {if(fonts_imported) 'YES (not recommended)' else 'NO'}}"
  ))
  cli::cli_text("")

  # Provide recommendations
  if (setup_status$setup_complete) {
    cli::cli_alert_success("Excellent! Your setup is optimal.")
    cli::cli_text("")
    cli::cli_h3("You're ready to create beautiful plots!")
    cli::cli_text("Example:")
    cli::cli_code("library(ggplot2)")
    cli::cli_code("ggplot(mtcars, aes(wt, mpg)) + geom_point() + theme_insper()")
    cli::cli_text("")
    if (Sys.getenv("RSTUDIO") == "1") {
      cli::cli_alert_info("Don't forget to set RStudio graphics backend to AGG:")
      cli::cli_text("{.strong Tools > Global Options > General > Graphics > Backend > AGG}")
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
      cli::cli_alert_info("After installing, run {.code check_insper_fonts()} to verify")
      cli::cli_text("")
      step_num <- step_num + 1
    }

    # Step 2: Install ragg if needed
    if (!has_ragg) {
      cli::cli_h3("Step {step_num}: Install ragg Package")
      cli::cli_code("install.packages('ragg')")
      cli::cli_text("")
      cli::cli_alert_info("After installing, run {.code use_ragg_device()} for setup")
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
