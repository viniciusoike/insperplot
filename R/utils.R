#' Save Insper Plot
#'
#' Enhanced ggsave with institutional defaults and ragg device support
#'
#' @param plot ggplot object
#' @param filename File name
#' @param width Plot width in inches
#' @param height Plot height in inches
#' @param dpi Resolution
#' @param asp_ratio Aspect ratio (width / height). Default is the golden ratio (1.618).
#'   Used only when \code{width} is not supplied directly.
#' @param unit Units for \code{width} and \code{height}. Default \code{"cm"}.
#'   Passed to \code{\link[ggplot2]{ggsave}}.
#' @param device Graphics device to use. If NULL (default), automatically uses
#'   ragg::agg_png() for PNG files when ragg is installed, otherwise falls back
#'   to ggplot2 defaults. You can override by passing a device function.
#' @param ... Additional arguments passed to ggsave
#'
#' @details
#' This function automatically uses the ragg device for PNG output when available,
#' which provides better font rendering and eliminates DPI issues. Install the
#' \pkg{ragg} package and set the RStudio backend to AGG for best results.
#'
#' @family utilities
#' @seealso \code{\link[ggplot2]{ggsave}}
#' @export
save_insper_plot <- function(
  plot,
  filename,
  asp_ratio = 1.618,
  width = height * asp_ratio,
  height = 8,
  dpi = 300,
  device = NULL,
  unit = "cm",
  ...
) {
  # Validate that plot is a ggplot object
  if (!ggplot2::is_ggplot(plot)) {
    cli::cli_abort(c(
      "{.arg plot} must be a ggplot object",
      "x" = "You supplied an object of class {.cls {class(plot)}}",
      "i" = "Create a plot using ggplot2 or insperplot functions first"
    ))
  }

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
    unit = unit,
    ...
  )

  message("Plot saved: ", filename)
}

#' Format Brazilian Numbers
#'
#' Format numbers in Brazilian style with decimal comma and thousand separator.
#' Supports currency and percentage formatting.
#'
#' @param x Numeric vector
#' @param digits Number of decimal places (default 0)
#' @param percent Logical. If TRUE, formats as percentage (multiplies by 100, adds \% suffix)
#' @param currency Logical. If TRUE, formats as Brazilian Real currency
#' @param ... Additional arguments passed to \code{\link[scales]{number}}
#' @return Formatted character vector
#' @family utilities
#' @export
#' @examples
#' # Basic number formatting
#' format_num_br(1234.56, digits = 2)
#'
#' # Currency formatting
#' format_num_br(1234.56, currency = TRUE, digits = 2)
#'
#' # Percentage formatting
#' format_num_br(0.1234, percent = TRUE, digits = 1)
#' format_num_br(0.1234, percent = TRUE, digits = 2)
format_num_br <- function(
  x,
  digits = 0,
  percent = FALSE,
  currency = FALSE,
  ...
) {
  if (!is.numeric(x)) {
    cli::cli_abort("{.arg x} must be numeric")
  }
  if (percent) {
    return(scales::number(
      x * 100,
      accuracy = 10^(-digits),
      big.mark = ".",
      decimal.mark = ",",
      suffix = "%",
      ...
    ))
  }

  if (currency) {
    return(scales::number(
      x,
      accuracy = 10^(-digits),
      big.mark = ".",
      decimal.mark = ",",
      prefix = "R$ ",
      ...
    ))
  }

  scales::number(
    x,
    accuracy = 10^(-digits),
    big.mark = ".",
    decimal.mark = ",",
    ...
  )
}

#' Download Insper Fonts from Google Fonts
#'
#' Downloads Insper's recommended fonts (Inter, EB Garamond, and Playfair
#' Display) from Google Fonts. Fonts are saved locally, making them permanently
#' available across R sessions via the systemfonts registry.
#'
#' @param dir Directory to save fonts. Default \code{"~/fonts"} saves fonts
#'   permanently. Use \code{tempdir()} for session-only use.
#' @param verbose Logical. If TRUE (default), prints status messages.
#'
#' @return Invisibly returns a named logical vector: TRUE for each font that was
#'   downloaded, FALSE for fonts already installed (skipped).
#'
#' @details
#' Only missing fonts are downloaded. Uses
#' \code{\link[systemfonts]{get_from_google_fonts}}, which integrates natively
#' with the ragg rendering pipeline -- no DPI conflicts, no per-session loading.
#'
#' After downloading, restart R so new fonts are picked up by the font registry.
#' Use \code{\link{setup_insper_fonts}} to verify the result.
#'
#' @family utilities
#' @seealso \code{\link{setup_insper_fonts}},
#'   \code{\link[systemfonts]{get_from_google_fonts}}
#' @importFrom stats setNames
#' @export
#' @examples
#' \dontrun{
#' # Download missing Insper fonts (saved permanently to ~/fonts)
#' import_insper_fonts()
#'
#' # Session-only download
#' import_insper_fonts(dir = tempdir())
#' }
import_insper_fonts <- function(dir = "~/fonts", verbose = TRUE) {
  fonts <- c("Inter", "EB Garamond", "Playfair Display")

  available <- tryCatch(
    systemfonts::system_fonts()$family,
    error = function(e) character(0)
  )

  already_installed <- vapply(
    fonts,
    function(f) any(grepl(f, available, ignore.case = TRUE)),
    logical(1)
  )

  to_download <- fonts[!already_installed]

  if (length(to_download) == 0) {
    if (verbose) {
      cli::cli_alert_success("All Insper fonts are already installed")
    }
    return(invisible(setNames(rep(FALSE, length(fonts)), fonts)))
  }

  if (verbose) {
    cli::cli_alert_info(
      "Downloading {length(to_download)} font{?s}: {.val {to_download}}"
    )
  }

  downloaded <- setNames(rep(FALSE, length(fonts)), fonts)

  for (font in to_download) {
    result <- tryCatch(
      systemfonts::get_from_google_fonts(font, dir = dir),
      error = function(e) {
        if (verbose) {
          cli::cli_alert_danger("Failed to download {.val {font}}: {e$message}")
        }
        FALSE
      }
    )
    downloaded[font] <- isTRUE(result)
    if (verbose && isTRUE(result)) {
      cli::cli_alert_success("Downloaded {.val {font}}")
    }
  }

  if (verbose) {
    if (any(downloaded)) {
      cli::cli_alert_info("Fonts saved to {.path {dir}}")
      cli::cli_alert_info(
        "Restart R to make new fonts available in the font registry"
      )
    } else if (length(to_download) > 0) {
      cli::cli_alert_warning(
        "No fonts were downloaded - check your internet connection"
      )
    }
  }

  invisible(downloaded)
}


#' Check Insper Font and Graphics Setup
#'
#' Checks whether recommended Insper fonts are available and reports the status
#' of the ragg graphics device. Use \code{\link{import_insper_fonts}} to
#' download any missing fonts.
#'
#' @param verbose Logical. If TRUE (default), prints a detailed status report.
#'   Use FALSE to check status silently via the return value.
#'
#' @return Invisibly returns a named logical vector indicating which fonts are
#'   available: Georgia, Inter, EB Garamond, and Playfair Display.
#'
#' @details
#' \strong{Required fonts} (needed for correct rendering):
#' \itemize{
#'   \item \strong{Georgia}: System serif font for titles (usually pre-installed)
#'   \item \strong{Inter}: Sans-serif font for body text (Google Font)
#' }
#'
#' \strong{Optional fallback fonts} (only used when Georgia is unavailable):
#' \itemize{
#'   \item \strong{EB Garamond}: Serif title fallback (Google Font)
#'   \item \strong{Playfair Display}: Serif title alternative (Google Font)
#' }
#'
#' Run \code{import_insper_fonts()} to download any missing fonts. For best
#' rendering quality, install the \pkg{ragg} package and set the RStudio
#' graphics backend to AGG.
#'
#' @family utilities
#' @seealso \code{\link{import_insper_fonts}}
#' @export
#' @examples
#' \dontrun{
#' setup_insper_fonts()
#' }
setup_insper_fonts <- function(verbose = TRUE) {
  available_fonts <- tryCatch(
    systemfonts::system_fonts()$family,
    error = function(e) character(0)
  )

  check <- function(pattern) {
    length(available_fonts) > 0 &&
      any(grepl(pattern, available_fonts, ignore.case = TRUE))
  }

  font_status <- c(
    "Georgia" = check("Georgia"),
    "Inter" = check("Inter"),
    "EB Garamond" = check("EB Garamond|Garamond"),
    "Playfair Display" = check("Playfair Display|Playfair")
  )

  if (!verbose) {
    return(invisible(font_status))
  }

  # Georgia + Inter are required; EB Garamond + Playfair Display are optional
  # fallbacks only used when Georgia is unavailable.
  core_ok <- font_status["Georgia"] && font_status["Inter"]

  has_ragg <- requireNamespace("ragg", quietly = TRUE)

  cli::cli_h2("Insper Font Status")

  font_bullets <- c(
    if (font_status["Georgia"]) {
      c("v" = "Georgia (serif, title font) - system font")
    } else {
      c("x" = "Georgia (serif) not found - will use fallbacks")
    },
    if (font_status["Inter"]) {
      c("v" = "Inter (sans-serif, body text) available")
    } else {
      c("x" = "Inter (sans-serif, body text) not found")
    },
    if (font_status["EB Garamond"]) {
      c("v" = "EB Garamond (serif, title fallback) available")
    } else {
      c("!" = "EB Garamond not found (optional)")
    },
    if (font_status["Playfair Display"]) {
      c("v" = "Playfair Display (serif, title fallback) available")
    } else {
      c("!" = "Playfair Display not found (optional)")
    }
  )
  cli::cli_bullets(font_bullets)
  cli::cli_text("")

  if (core_ok) {
    cli::cli_alert_success(
      "Core fonts available \u2014 plots will render correctly."
    )
    if (!font_status["EB Garamond"] || !font_status["Playfair Display"]) {
      cli::cli_alert_info(
        "Optional fallback fonts can be downloaded with {.code import_insper_fonts()}"
      )
    }
  } else {
    cli::cli_alert_warning(
      "Core fonts missing \u2014 run {.code import_insper_fonts()} to download."
    )
  }

  cli::cli_text("")
  if (has_ragg) {
    cli::cli_alert_success("{.pkg ragg} is installed")
    if (Sys.getenv("RSTUDIO") == "1") {
      cli::cli_alert_info(
        "Set RStudio backend to AGG: {.strong Tools > Global Options > General > Graphics > Backend > AGG}"
      )
    }
  } else {
    cli::cli_alert_warning(
      "{.pkg ragg} not installed - for best font rendering:"
    )
    cli::cli_code("install.packages('ragg')")
  }

  invisible(font_status)
}

#' Check if string is a valid color
#'
#' Validates hex colors and named colors recognized by R's graphics device.
#' Used internally by smart detection functions to distinguish between
#' static color strings and column names.
#'
#' @param x Character vector of length 1
#'
#' @return Logical. TRUE if x is a valid color specification, FALSE otherwise.
#' @keywords internal
#' @examples
#' \dontrun{
#' is_valid_color("blue")         # TRUE
#' is_valid_color("#FF0000")      # TRUE
#' is_valid_color("#FF0000FF")    # TRUE (with alpha)
#' is_valid_color("bleu")         # FALSE
#' is_valid_color("Species")      # FALSE
#' }
is_valid_color <- function(x) {
  if (!is.character(x) || length(x) != 1) {
    return(FALSE)
  }

  # Check hex color pattern (#RGB, #RRGGBB, #RRGGBBAA)
  # Must check hex BEFORE col2rgb because col2rgb is too permissive
  if (grepl("^#", x)) {
    # For hex colors, only accept standard formats
    return(grepl("^#([0-9A-Fa-f]{3}|[0-9A-Fa-f]{6}|[0-9A-Fa-f]{8})$", x))
  }

  # Check if grDevices recognizes it as a named color
  tryCatch(
    {
      grDevices::col2rgb(x)
      return(TRUE)
    },
    error = function(e) {
      return(FALSE)
    }
  )
}

#' Detect if aesthetic parameter is static color or variable mapping
#'
#' Intelligently determines whether a user-provided aesthetic parameter (color/fill)
#' is a static color string ("blue", "#FF0000") or a variable mapping (column name
#' or expression). This enables intuitive API where both use cases work naturally.
#'
#' @param quo Quosure from rlang::enquo()
#' @param param_name Character. Parameter name for error messages (e.g., "color", "fill")
#' @param data Data frame to evaluate variable in (optional). If provided, enables
#'   detection of continuous vs discrete variables.
#'
#' @return List with:
#'   \itemize{
#'     \item type: "missing", "static_color", or "variable_mapping"
#'     \item value: The static color value (if type = "static_color")
#'     \item is_continuous: Logical (if type = "variable_mapping" and data provided)
#'   }
#'
#' @keywords internal
#' @examples
#' \dontrun{
#' # In a function context:
#' my_plot <- function(data, x, y, color = NULL) {
#'   color_quo <- rlang::enquo(color)
#'   color_type <- detect_aesthetic_type(color_quo, "color", data)
#'
#'   if (color_type$type == "static_color") {
#'     # Use static color
#'     geom_point(color = color_type$value)
#'   } else if (color_type$type == "variable_mapping") {
#'     # Use aes() mapping
#'     geom_point(aes(color = {{color}}))
#'   }
#' }
#' }
detect_aesthetic_type <- function(quo, param_name = "parameter", data = NULL) {
  # Check if parameter was not provided
  if (rlang::quo_is_null(quo)) {
    return(list(type = "missing"))
  }

  expr <- rlang::quo_get_expr(quo)

  # Check if it's a string literal (static color)
  if (is.character(expr) && length(expr) == 1) {
    if (is_valid_color(expr)) {
      return(list(type = "static_color", value = expr))
    } else {
      cli::cli_abort(c(
        "{.arg {param_name}} = {.val {expr}} is not a valid color",
        "i" = "Use a bare column name for variable mapping: {.code {param_name} = column_name}",
        "i" = "Or use a valid color name/hex code: {.code {param_name} = \"blue\"}",
        "i" = "See {.code colors()} for valid color names"
      ))
    }
  }

  # It's a variable mapping (symbol or expression)
  # Detect if continuous or discrete
  if (!is.null(data)) {
    # Try to evaluate in data context to detect variable type
    tryCatch(
      {
        var_vals <- rlang::eval_tidy(quo, rlang::as_data_mask(data))
        is_continuous <- is.numeric(var_vals) && !is.factor(var_vals)
      },
      error = function(e) {
        # If evaluation fails, default to discrete
        # This can happen with complex expressions
        is_continuous <- FALSE
      }
    )
  } else {
    is_continuous <- FALSE # Can't determine without data
  }

  return(list(
    type = "variable_mapping",
    is_continuous = is_continuous
  ))
}

#' Warn if palette specified with static aesthetic
#'
#' Educates users when they specify a palette parameter but use a static color
#' instead of a variable mapping. The palette parameter only applies to variable
#' mappings (discrete or continuous scales), not static colors.
#'
#' @param aesthetic_type List returned from detect_aesthetic_type()
#' @param palette Character or NULL. The palette argument value
#' @param param_name Character. Name of the aesthetic parameter ("color" or "fill")
#'
#' @return NULL (called for side effect of warning)
#' @keywords internal
#' @examples
#' \dontrun{
#' # This will warn
#' warn_palette_ignored(
#'   list(type = "static_color", value = "blue"),
#'   palette = "bright",
#'   param_name = "fill"
#' )
#' # Warning: `palette` argument ignored when `fill` is a static color
#'
#' # This will NOT warn (palette is used)
#' warn_palette_ignored(
#'   list(type = "variable_mapping"),
#'   palette = "bright",
#'   param_name = "fill"
#' )
#' }
warn_palette_ignored <- function(aesthetic_type, palette, param_name) {
  if (!is.null(palette) && aesthetic_type$type == "static_color") {
    cli::cli_warn(c(
      "{.arg palette} argument ignored when {.arg {param_name}} is a static color",
      "i" = "The {.arg palette} parameter only applies when {.arg {param_name}} is a variable mapping",
      "i" = "Remove {.code palette = {.val {palette}}} or use a variable for {.arg {param_name}}"
    ))
  }
}

#' Check Whether Insper Fonts Are Available
#'
#' Returns \code{TRUE} when the session is interactive and at least one primary
#' Insper font (Georgia or Inter) is registered in the system font catalogue.
#' Intended for use with \code{@examplesIf} in package documentation.
#'
#' @return Logical scalar.
#' @family utilities
#' @keywords internal
#' @export
has_insper_fonts <- function() {
  # Only run examples in interactive sessions
  # (fonts may be detected but not work with CMD check's graphics device)
  if (!interactive()) {
    return(FALSE)
  }

  # Check if systemfonts package is available
  if (!requireNamespace("systemfonts", quietly = TRUE)) {
    return(FALSE)
  }

  # Try to detect if primary fonts are available
  tryCatch(
    {
      fonts <- systemfonts::system_fonts()$family
      # Check for at least one of the primary fonts (Georgia or Inter)
      any(grepl("Georgia|Inter", fonts, ignore.case = TRUE))
    },
    error = function(e) FALSE
  )
}

#' Calculate Relative Luminance of a Color
#'
#' @param hex_color Character. Hex color code (e.g., "#E4002B")
#' @return Numeric. Relative luminance value between 0 (black) and 1 (white)
#' @noRd
#' @keywords internal
calculate_luminance <- function(hex_color) {
  # Convert hex to RGB
  rgb_vals <- grDevices::col2rgb(hex_color)[, 1] / 255

  # Apply sRGB gamma correction
  rgb_linear <- ifelse(
    rgb_vals <= 0.03928,
    rgb_vals / 12.92,
    ((rgb_vals + 0.055) / 1.055)^2.4
  )

  # Calculate relative luminance (ITU-R BT.709)
  luminance <- 0.2126 *
    rgb_linear[1] +
    0.7152 * rgb_linear[2] +
    0.0722 * rgb_linear[3]

  return(luminance)
}

#' Choose Contrasting Text Color for Background
#'
#' @param bg_color Character. Background hex color code
#' @param dark_color Character. Text color for light backgrounds. Default "#2C2C2C"
#' @param light_color Character. Text color for dark backgrounds. Default "white"
#' @param threshold Numeric. Luminance threshold (0-1). Default 0.5
#' @return Character. Either dark_color or light_color based on background luminance
#' @noRd
#' @keywords internal
get_contrast_text_color <- function(
  bg_color,
  dark_color = "#2C2C2C",
  light_color = "white",
  threshold = 0.5
) {
  luminance <- calculate_luminance(bg_color)

  # If background is light (high luminance), use dark text
  # If background is dark (low luminance), use light text
  if (luminance > threshold) {
    return(dark_color)
  } else {
    return(light_color)
  }
}
