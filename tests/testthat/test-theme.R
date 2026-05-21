test_that("theme_insper returns a theme object", {
  theme <- theme_insper()
  expect_s3_class(theme, "theme")
  expect_s3_class(theme, "gg")
})

test_that("theme_insper accepts base_size parameter", {
  expect_no_error(theme_insper(base_size = 10))
  expect_no_error(theme_insper(base_size = 14))
  expect_no_error(theme_insper(base_size = 18))
})

test_that("theme_insper grid parameter works", {
  expect_no_error(theme_insper(grid = TRUE))
  expect_no_error(theme_insper(grid = FALSE))
  expect_error(theme_insper(grid = "invalid"), "must be one of")
})

test_that("theme_insper border parameter validates correctly", {
  expect_no_error(theme_insper(border = "none"))
  expect_no_error(theme_insper(border = "half"))
  expect_no_error(theme_insper(border = "closed"))
  expect_error(theme_insper(border = "invalid"), "must be one of")
})

test_that("theme_insper accepts font parameters", {
  expect_no_error(theme_insper(font_title = "Arial"))
  expect_no_error(theme_insper(font_text = "Helvetica"))
  expect_no_error(theme_insper(font_title = "Arial", font_text = "Helvetica"))
})

test_that("theme_insper can be added to a ggplot", {
  skip_if_not_installed("ggplot2")
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(x = wt, y = mpg)) +
    ggplot2::geom_point() +
    theme_insper()
  expect_s3_class(p, "ggplot")
})

# Error condition tests ----

test_that("theme_insper validates base_size parameter", {
  # base_size must be numeric
  expect_no_error(theme_insper(base_size = 12))
  expect_no_error(theme_insper(base_size = 8))
  expect_no_error(theme_insper(base_size = 20))
})

test_that("theme_insper validates grid parameter type", {
  # grid must be logical, not character
  expect_error(theme_insper(grid = "yes"), "must be one of")
  expect_error(theme_insper(grid = "true"), "must be one of")
  expect_error(theme_insper(grid = 1), "must be one of")
  expect_error(theme_insper(grid = NULL), "must be one of")
})

test_that("theme_insper validates border parameter values", {
  # Test all valid values work
  expect_no_error(theme_insper(border = "none"))
  expect_no_error(theme_insper(border = "half"))
  expect_no_error(theme_insper(border = "closed"))

  # Test invalid values error
  expect_error(theme_insper(border = "full"), "must be one of")
  expect_error(theme_insper(border = "complete"), "must be one of")
  expect_error(theme_insper(border = TRUE), "must be one of")
  expect_error(theme_insper(border = 1), "must be one of")
})

test_that("theme_insper validates align parameter values", {
  # Test valid values
  expect_no_error(theme_insper(align = "panel"))
  expect_no_error(theme_insper(align = "plot"))

  # Test invalid values
  expect_error(theme_insper(align = "center"), "must be one of")
  expect_error(theme_insper(align = "left"), "must be one of")
  expect_error(theme_insper(align = "invalid"), "must be one of")
})

test_that("theme_insper border options produce different themes", {
  theme_none <- theme_insper(border = "none")
  theme_half <- theme_insper(border = "half")
  theme_closed <- theme_insper(border = "closed")

  # All should be theme objects
  expect_s3_class(theme_none, "theme")
  expect_s3_class(theme_half, "theme")
  expect_s3_class(theme_closed, "theme")

  # They should be different from each other
  expect_false(identical(theme_none, theme_half))
  expect_false(identical(theme_none, theme_closed))
  expect_false(identical(theme_half, theme_closed))
})

test_that("theme_insper grid option affects theme elements", {
  theme_grid <- theme_insper(grid = TRUE)
  theme_no_grid <- theme_insper(grid = FALSE)

  expect_s3_class(theme_grid, "theme")
  expect_s3_class(theme_no_grid, "theme")
  expect_false(identical(theme_grid, theme_no_grid))
})

test_that("theme_insper align option affects theme elements", {
  theme_panel <- theme_insper(align = "panel")
  theme_plot <- theme_insper(align = "plot")

  expect_s3_class(theme_panel, "theme")
  expect_s3_class(theme_plot, "theme")
  expect_false(identical(theme_panel, theme_plot))
})

test_that("theme_insper accepts custom font names", {
  # Should not error even with non-existent fonts (will fall back)
  expect_no_error(theme_insper(font_title = "NonExistentFont"))
  expect_no_error(theme_insper(font_text = "AnotherFakeFont"))
  expect_no_error(theme_insper(font_title = "FakeTitle", font_text = "FakeText"))
})

test_that("theme_insper multiple parameters work together", {
  # Test combining multiple parameters
  expect_no_error(theme_insper(
    base_size = 14,
    grid = FALSE,
    border = "closed",
    align = "plot"
  ))

  expect_no_error(theme_insper(
    base_size = 10,
    font_title = "Arial",
    font_text = "Helvetica",
    grid = TRUE,
    border = "half"
  ))
})

# Font fallback logic tests ----

test_that("detect_font returns font when available on system", {
  detect_font <- insperplot:::detect_font

  result <- detect_font("Georgia", c("Arial", "sans"))
  # Georgia is a system font on macOS/Windows; falls back gracefully otherwise
  expect_type(result, "character")
  expect_length(result, 1)
  expect_true(result %in% c("Georgia", "Arial", "sans"))
})

test_that("detect_font returns fallback when font unavailable", {
  detect_font <- insperplot:::detect_font

  result <- detect_font(
    "ThisFontDefinitelyDoesNotExist12345",
    c("AnotherNonExistentFont", "sans")
  )
  expect_equal(result, "sans")
})

test_that("detect_font recognizes generic font families", {
  detect_font <- insperplot:::detect_font

  expect_equal(detect_font("NonExistentFont", c("serif")), "serif")
  expect_equal(detect_font("NonExistentFont", c("sans")), "sans")
  expect_equal(detect_font("NonExistentFont", c("mono")), "mono")
})

test_that("detect_font handles fallback chain correctly", {
  detect_font <- insperplot:::detect_font

  result <- detect_font(
    "NonExistent",
    c("AlsoNonExistent", "StillNonExistent", "serif")
  )
  expect_type(result, "character")
  expect_length(result, 1)
})

test_that("detect_font handles systemfonts not available gracefully", {
  detect_font <- insperplot:::detect_font

  result <- detect_font("SomeFont", c("Fallback", "sans"))
  expect_type(result, "character")
  expect_length(result, 1)
})

