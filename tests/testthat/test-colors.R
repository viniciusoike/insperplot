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
