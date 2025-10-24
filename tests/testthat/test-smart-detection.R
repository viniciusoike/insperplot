# Tests for Smart Detection Helper Functions (v2.0.0)

# Tests for is_valid_color() -----------------------------------------------

test_that("is_valid_color() recognizes valid hex colors", {
  expect_true(is_valid_color("#FF0000"))
  expect_true(is_valid_color("#00ff00"))
  expect_true(is_valid_color("#0000FF"))
  expect_true(is_valid_color("#FFFFFF"))
  expect_true(is_valid_color("#000000"))
})

test_that("is_valid_color() recognizes hex colors with alpha", {
  expect_true(is_valid_color("#FF0000FF"))
  expect_true(is_valid_color("#00ff00AA"))
  expect_true(is_valid_color("#0000FF80"))
})

test_that("is_valid_color() recognizes 3-digit hex colors", {
  expect_true(is_valid_color("#F00"))
  expect_true(is_valid_color("#0F0"))
  expect_true(is_valid_color("#00F"))
  expect_true(is_valid_color("#FFF"))
})

test_that("is_valid_color() recognizes named R colors", {
  expect_true(is_valid_color("blue"))
  expect_true(is_valid_color("red"))
  expect_true(is_valid_color("green"))
  expect_true(is_valid_color("steelblue"))
  expect_true(is_valid_color("cornflowerblue"))
  expect_true(is_valid_color("white"))
  expect_true(is_valid_color("black"))
})

test_that("is_valid_color() rejects invalid color names", {
  expect_false(is_valid_color("bleu"))  # Typo
  expect_false(is_valid_color("Species"))  # Column name
  expect_false(is_valid_color("gear"))  # Column name
  expect_false(is_valid_color("notacolor"))
})

test_that("is_valid_color() rejects invalid hex patterns", {
  expect_false(is_valid_color("#FF"))  # Too short
  expect_false(is_valid_color("#FFFF"))  # Invalid length
  expect_false(is_valid_color("#FFFFF"))  # Invalid length
  expect_false(is_valid_color("#FFFFFFFFF"))  # Too long
  expect_false(is_valid_color("FF0000"))  # Missing #
  expect_false(is_valid_color("#GG0000"))  # Invalid hex characters
})

test_that("is_valid_color() handles edge cases", {
  expect_false(is_valid_color(""))  # Empty string
  expect_false(is_valid_color(c("blue", "red")))  # Vector length > 1
  expect_false(is_valid_color(NULL))
  expect_false(is_valid_color(NA))
  expect_false(is_valid_color(123))  # Not character
})


# Tests for detect_aesthetic_type() ----------------------------------------

test_that("detect_aesthetic_type() detects missing parameters", {
  test_fn <- function(color = NULL) {
    color_quo <- rlang::enquo(color)
    detect_aesthetic_type(color_quo, "color")
  }

  result <- test_fn()
  expect_equal(result$type, "missing")
})

test_that("detect_aesthetic_type() detects static hex colors", {
  test_fn <- function(color) {
    color_quo <- rlang::enquo(color)
    detect_aesthetic_type(color_quo, "color")
  }

  result <- test_fn("#FF0000")
  expect_equal(result$type, "static_color")
  expect_equal(result$value, "#FF0000")
})

test_that("detect_aesthetic_type() detects static named colors", {
  test_fn <- function(color) {
    color_quo <- rlang::enquo(color)
    detect_aesthetic_type(color_quo, "color")
  }

  result <- test_fn("blue")
  expect_equal(result$type, "static_color")
  expect_equal(result$value, "blue")

  result2 <- test_fn("steelblue")
  expect_equal(result2$type, "static_color")
  expect_equal(result2$value, "steelblue")
})

test_that("detect_aesthetic_type() errors on invalid color strings", {
  test_fn <- function(color) {
    color_quo <- rlang::enquo(color)
    detect_aesthetic_type(color_quo, "color")
  }

  expect_error(test_fn("bleu"), "not a valid color")
  expect_error(test_fn("notacolor"), "not a valid color")
})

test_that("detect_aesthetic_type() detects variable mapping (bare symbol)", {
  test_fn <- function(data, color) {
    color_quo <- rlang::enquo(color)
    detect_aesthetic_type(color_quo, "color", data)
  }

  result <- test_fn(mtcars, cyl)
  expect_equal(result$type, "variable_mapping")
})

test_that("detect_aesthetic_type() detects variable mapping (expression)", {
  test_fn <- function(data, color) {
    color_quo <- rlang::enquo(color)
    detect_aesthetic_type(color_quo, "color", data)
  }

  result <- test_fn(mtcars, factor(cyl))
  expect_equal(result$type, "variable_mapping")
})

test_that("detect_aesthetic_type() detects continuous vs discrete variables", {
  test_fn <- function(data, color) {
    color_quo <- rlang::enquo(color)
    detect_aesthetic_type(color_quo, "color", data)
  }

  # Continuous variable (numeric, not factor)
  result_cont <- test_fn(mtcars, hp)
  expect_equal(result_cont$type, "variable_mapping")
  expect_true(result_cont$is_continuous)

  # Discrete variable (factor)
  result_disc <- test_fn(iris, Species)
  expect_equal(result_disc$type, "variable_mapping")
  expect_false(result_disc$is_continuous)

  # Discrete variable (factorized numeric)
  result_disc2 <- test_fn(mtcars, factor(cyl))
  expect_equal(result_disc2$type, "variable_mapping")
  expect_false(result_disc2$is_continuous)
})

test_that("detect_aesthetic_type() handles column name = color name edge case", {
  # Create data with column named "red"
  df <- data.frame(red = 1:5, blue = 6:10, value = rnorm(10))

  test_fn <- function(data, color) {
    color_quo <- rlang::enquo(color)
    detect_aesthetic_type(color_quo, "color", data)
  }

  # Bare symbol = variable mapping (uses column)
  result_var <- test_fn(df, red)
  expect_equal(result_var$type, "variable_mapping")
  expect_true(result_var$is_continuous)

  # String = static color (uses color)
  result_static <- test_fn(df, "red")
  expect_equal(result_static$type, "static_color")
  expect_equal(result_static$value, "red")
})

test_that("detect_aesthetic_type() works without data argument", {
  test_fn <- function(color) {
    color_quo <- rlang::enquo(color)
    detect_aesthetic_type(color_quo, "color", data = NULL)
  }

  # Variable mapping detected, but can't determine if continuous
  result <- test_fn(cyl)
  expect_equal(result$type, "variable_mapping")
  expect_false(result$is_continuous)  # Defaults to FALSE without data
})


# Tests for warn_palette_ignored() -----------------------------------------

test_that("warn_palette_ignored() warns when palette specified with static color", {
  aesthetic_type <- list(type = "static_color", value = "blue")

  expect_warning(
    warn_palette_ignored(aesthetic_type, palette = "bright", param_name = "fill"),
    "palette.*ignored"
  )

  expect_warning(
    warn_palette_ignored(aesthetic_type, palette = "categorical", param_name = "color"),
    "palette.*ignored"
  )
})

test_that("warn_palette_ignored() does NOT warn when palette is NULL", {
  aesthetic_type <- list(type = "static_color", value = "blue")

  expect_no_warning(
    warn_palette_ignored(aesthetic_type, palette = NULL, param_name = "fill")
  )
})

test_that("warn_palette_ignored() does NOT warn with variable mapping", {
  aesthetic_type <- list(type = "variable_mapping", is_continuous = FALSE)

  expect_no_warning(
    warn_palette_ignored(aesthetic_type, palette = "bright", param_name = "fill")
  )

  expect_no_warning(
    warn_palette_ignored(aesthetic_type, palette = "categorical", param_name = "color")
  )
})

test_that("warn_palette_ignored() does NOT warn when palette is missing", {
  aesthetic_type <- list(type = "missing")

  expect_no_warning(
    warn_palette_ignored(aesthetic_type, palette = "bright", param_name = "fill")
  )
})


# Integration tests --------------------------------------------------------

test_that("Smart detection workflow works end-to-end", {
  # Simulate a simplified plot function using smart detection
  smart_plot <- function(data, x, y, color = NULL, palette = "categorical") {
    color_quo <- rlang::enquo(color)
    color_type <- detect_aesthetic_type(color_quo, "color", data)
    warn_palette_ignored(color_type, palette, "color")

    list(
      type = color_type$type,
      value = color_type$value %||% NA,
      is_continuous = color_type$is_continuous %||% FALSE
    )
  }

  # Test 1: Missing parameter
  result1 <- smart_plot(mtcars, wt, mpg)
  expect_equal(result1$type, "missing")

  # Test 2: Static color
  result2 <- smart_plot(mtcars, wt, mpg, color = "blue")
  expect_equal(result2$type, "static_color")
  expect_equal(result2$value, "blue")

  # Test 3: Variable mapping (discrete)
  result3 <- smart_plot(mtcars, wt, mpg, color = factor(cyl))
  expect_equal(result3$type, "variable_mapping")
  expect_false(result3$is_continuous)

  # Test 4: Variable mapping (continuous)
  result4 <- smart_plot(mtcars, wt, mpg, color = hp)
  expect_equal(result4$type, "variable_mapping")
  expect_true(result4$is_continuous)

  # Test 5: Palette warning with static color
  expect_warning(
    smart_plot(mtcars, wt, mpg, color = "blue", palette = "bright"),
    "palette.*ignored"
  )
})

test_that("Smart detection handles common R color names", {
  # Test a sample of universally-recognized R color names
  # These are guaranteed to work across all R versions
  sample_colors <- c(
    "white", "black", "red", "green", "blue",
    "yellow", "cyan", "magenta", "gray", "grey",
    "orange", "purple", "pink", "brown", "tan"
  )

  for (col in sample_colors) {
    result <- is_valid_color(col)
    expect_true(result, info = paste("Failed for color:", col))
  }
})
