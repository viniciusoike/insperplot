test_that("get_insper_colors returns all colors when no args", {
  cols <- get_insper_colors()
  expect_type(cols, "character")
  expect_true(length(cols) > 0)
  expect_true(all(grepl("^#|^gray", cols)))
})

test_that("get_insper_colors can extract specific colors", {
  red <- get_insper_colors("reds1")
  expect_length(red, 1)
  expect_equal(unname(red), "#E4002B")

  # Test multiple colors
  multiple <- get_insper_colors("reds1", "teals1")
  expect_length(multiple, 2)
  expect_equal(unname(multiple[1]), "#E4002B")
  expect_equal(unname(multiple[2]), "#009491")
})

test_that("get_insper_colors returns named vector", {
  cols <- get_insper_colors("reds1", "teals1")
  expect_named(cols, c("reds1", "teals1"))
})

test_that("show_insper_colors creates a ggplot", {
  skip_if_not_installed("ggplot2")
  p <- show_insper_colors()
  expect_s3_class(p, "ggplot")
})

test_that("show_insper_colors accepts color families", {
  skip_if_not_installed("ggplot2")
  expect_s3_class(show_insper_colors("reds"), "ggplot")
  expect_s3_class(show_insper_colors("grays"), "ggplot")
  expect_s3_class(show_insper_colors("all"), "ggplot")
})

test_that("insper_pal returns valid palettes", {
  pal <- insper_pal("main")
  expect_type(pal, "character")
  expect_true(all(grepl("^#", pal)))
  expect_true(length(pal) > 0)
})

test_that("insper_pal validates palette names", {
  expect_error(insper_pal("invalid_palette"), "not found")
})

test_that("insper_pal reverse parameter works", {
  pal_normal <- insper_pal("reds")
  pal_reverse <- insper_pal("reds", reverse = TRUE)
  expect_equal(pal_normal, rev(pal_reverse))
})

test_that("insper_pal continuous type works", {
  pal <- insper_pal("reds", n = 10, type = "continuous")
  expect_length(pal, 10)
  expect_true(all(grepl("^#", pal)))
})

test_that("insper_pal discrete type works", {
  pal <- insper_pal("reds", n = 2, type = "discrete")
  expect_length(pal, 2)

  # Test that it warns when requesting more colors than available
  expect_warning(insper_pal("reds", n = 20, type = "discrete"), "Not enough colors")
})

test_that("insper_pal n parameter defaults to palette length", {
  pal1 <- insper_pal("main")
  pal2 <- insper_pal("main", n = NULL)
  expect_equal(pal1, pal2)
})

test_that("show_insper_palette creates a ggplot with default palette", {
  skip_if_not_installed("ggplot2")
  p <- show_insper_palette()
  expect_s3_class(p, "ggplot")
})

test_that("show_insper_palette accepts palette names", {
  skip_if_not_installed("ggplot2")
  expect_s3_class(show_insper_palette("reds"), "ggplot")
  expect_s3_class(show_insper_palette("grays"), "ggplot")
  expect_s3_class(show_insper_palette("oranges"), "ggplot")
  expect_s3_class(show_insper_palette("main"), "ggplot")
  expect_s3_class(show_insper_palette("teals"), "ggplot")
})

test_that("show_insper_palette errors on invalid palette", {
  expect_error(show_insper_palette("invalid"), "not found")
})

# Tests for get_palette_colors()
test_that("get_palette_colors returns all colors when n is NULL", {
  pal <- get_palette_colors("main")
  expect_type(pal, "character")
  expect_true(all(grepl("^#", pal)))
  expect_true(length(pal) > 0)
  expect_equal(length(pal), 6)  # main palette has 6 colors
})

test_that("get_palette_colors can extract n colors", {
  pal <- get_palette_colors("reds", n = 3)
  expect_length(pal, 3)
  expect_true(all(grepl("^#", pal)))
})

test_that("get_palette_colors reverse parameter works", {
  pal_normal <- get_palette_colors("reds")
  pal_reverse <- get_palette_colors("reds", reverse = TRUE)
  expect_equal(pal_normal, rev(pal_reverse))
})

test_that("get_palette_colors warns when n exceeds palette length", {
  expect_warning(get_palette_colors("reds", n = 20), "Not enough colors")
  # Check it still returns the requested number
  suppressWarnings({
    pal <- get_palette_colors("reds", n = 20)
    expect_length(pal, 20)
  })
})

test_that("get_palette_colors validates palette names", {
  expect_error(get_palette_colors("invalid_palette"), "not found")
})

test_that("get_palette_colors works with different palettes", {
  # Sequential
  expect_type(get_palette_colors("reds"), "character")
  expect_type(get_palette_colors("oranges"), "character")
  expect_type(get_palette_colors("teals"), "character")
  expect_type(get_palette_colors("grays"), "character")

  # Diverging
  expect_type(get_palette_colors("red_teal"), "character")
  expect_type(get_palette_colors("diverging"), "character")

  # Qualitative
  expect_type(get_palette_colors("bright"), "character")
  expect_type(get_palette_colors("contrast"), "character")
  expect_type(get_palette_colors("categorical"), "character")
})

test_that("get_palette_colors returns hex codes only (discrete mode)", {
  pal <- get_palette_colors("main", n = 3)
  # Should return first 3 colors from palette, not interpolated
  expect_length(pal, 3)
  expect_true(all(grepl("^#[0-9A-F]{6}$", pal)))
})
