# Tests for get_insper_colors() (internal) ----

test_that("get_insper_colors returns all colors when no args", {
  cols <- insperplot:::get_insper_colors()
  expect_type(cols, "character")
  expect_true(length(cols) > 0)
})

test_that("get_insper_colors extracts specific colors by name", {
  red <- insperplot:::get_insper_colors("reds1")
  expect_length(red, 1)
  expect_equal(unname(red), "#E4002B")

  both <- insperplot:::get_insper_colors("reds1", "teals1")
  expect_length(both, 2)
  expect_named(both, c("reds1", "teals1"))
})

test_that("get_insper_colors errors on unknown names", {
  expect_error(insperplot:::get_insper_colors("notacolor"), "not found")
})


# Tests for insper_pal() (internal, used by scales) ----

test_that("insper_pal returns valid hex palette", {
  pal <- insperplot:::insper_pal("main")
  expect_type(pal, "character")
  expect_true(all(grepl("^#", pal)))
  expect_true(length(pal) > 0)
})

test_that("insper_pal validates palette names", {
  expect_error(insperplot:::insper_pal("invalid_palette"), "not found")
})

test_that("insper_pal reverse parameter works", {
  pal_normal  <- insperplot:::insper_pal("reds")
  pal_reverse <- insperplot:::insper_pal("reds", reverse = TRUE)
  expect_equal(pal_normal, rev(pal_reverse))
})

test_that("insper_pal continuous type interpolates colors", {
  pal <- insperplot:::insper_pal("reds", n = 10, type = "continuous")
  expect_length(pal, 10)
  expect_true(all(grepl("^#", pal)))
})

test_that("insper_pal warns when n exceeds palette size", {
  expect_warning(insperplot:::insper_pal("reds", n = 20, type = "discrete"), "Not enough colors")
})

test_that("insper_pal n=NULL returns full palette", {
  pal1 <- insperplot:::insper_pal("main")
  pal2 <- insperplot:::insper_pal("main", n = NULL)
  expect_equal(pal1, pal2)
})


# Tests for insper_palette() ----

test_that("insper_palette returns insper_palette class", {
  pal <- insper_palette("main")
  expect_s3_class(pal, "insper_palette")
  expect_s3_class(pal, "character")
})

test_that("insper_palette is a character vector", {
  pal <- insper_palette("reds")
  expect_true(is.character(pal))
  expect_true(all(grepl("^#", pal)))
})

test_that("insper_palette n parameter subsets colors", {
  pal <- insper_palette("reds", n = 3)
  expect_length(pal, 3)
})

test_that("insper_palette reverse parameter works", {
  normal  <- insper_palette("reds")
  reversed <- insper_palette("reds", reverse = TRUE)
  expect_equal(as.character(normal), rev(as.character(reversed)))
})

test_that("insper_palette warns and recycles when n exceeds palette size", {
  expect_warning(insper_palette("reds", n = 20), "recycling")
  suppressWarnings({
    pal <- insper_palette("reds", n = 20)
    expect_length(pal, 20)
  })
})

test_that("insper_palette errors on unknown palette", {
  expect_error(insper_palette("not_a_palette"), "not found")
})

test_that("as.character strips insper_palette class", {
  pal <- insper_palette("main")
  plain <- as.character(pal)
  expect_type(plain, "character")
  expect_false(inherits(plain, "insper_palette"))
})

test_that("insper_palette print method returns a ggplot invisibly", {
  skip_if_not_installed("ggplot2")
  pal <- insper_palette("main")
  # Capture print output — should not error
  expect_no_error(capture.output(print(pal)))
})

test_that("insper_palette works with all named palettes", {
  palettes <- names(insperplot:::insper_palettes)
  for (p in palettes) {
    expect_s3_class(insper_palette(p), "insper_palette")
  }
})


# Tests for show_insper_palettes() ----

test_that("show_insper_palettes returns metadata data frame invisibly", {
  skip_if_not_installed("ggplot2")
  result <- show_insper_palettes()
  expect_s3_class(result, "data.frame")
  expect_named(result, c("name", "type", "n_colors", "recommended_use"))
})

test_that("show_insper_palettes type filter works", {
  skip_if_not_installed("ggplot2")
  seq_meta <- show_insper_palettes("sequential")
  expect_true(all(seq_meta$type == "sequential"))

  div_meta <- show_insper_palettes("diverging")
  expect_true(all(div_meta$type == "diverging"))
})

test_that("show_insper_palettes errors on invalid type", {
  expect_error(show_insper_palettes("invalid"), "should be one of")
})
