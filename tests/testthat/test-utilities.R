# Tests for format_num_br() - unified formatting function

test_that("format_num_br formats basic numbers correctly", {
  result <- format_num_br(1234.56, digits = 2)
  expect_type(result, "character")
  expect_match(result, "1\\.234,56")
})

test_that("format_num_br handles default digits (0)", {
  result <- format_num_br(1234)
  expect_match(result, "1\\.234")
  expect_no_match(result, ",")
})

test_that("format_num_br formats currency correctly", {
  result <- format_num_br(1234.56, currency = TRUE, digits = 2)
  expect_type(result, "character")
  expect_match(result, "R\\$")
  expect_match(result, "1\\.234,56")
})

test_that("format_num_br formats currency with no decimals", {
  result <- format_num_br(1234, currency = TRUE)
  expect_match(result, "R\\$ 1\\.234")
})

test_that("format_num_br handles large currency numbers", {
  result <- format_num_br(1234567.89, currency = TRUE, digits = 2)
  expect_match(result, "R\\$ 1\\.234\\.567,89")
})

test_that("format_num_br formats percentages correctly", {
  result <- format_num_br(0.1234, percent = TRUE, digits = 1)
  expect_type(result, "character")
  expect_match(result, "12,3%")
})

test_that("format_num_br percentage digits parameter works", {
  result1 <- format_num_br(0.1234, percent = TRUE, digits = 1)
  result2 <- format_num_br(0.1234, percent = TRUE, digits = 2)
  expect_match(result1, "12,3%")
  expect_match(result2, "12,34%")
})

test_that("format_num_br handles percentage edge cases", {
  expect_match(format_num_br(0, percent = TRUE), "0%")
  expect_match(format_num_br(1, percent = TRUE), "100%")
})

test_that("format_num_br handles large numbers", {
  result <- format_num_br(1234567890, digits = 0)
  expect_match(result, "1\\.234\\.567\\.890")
})

test_that("format_num_br handles negative numbers", {
  expect_type(format_num_br(-1234.56, digits = 2), "character")
  expect_match(format_num_br(-1234.56, digits = 2), "-")
  expect_match(format_num_br(-1234.56, digits = 2), "1\\.234,56")
})

test_that("format_num_br handles zero correctly", {
  expect_type(format_num_br(0), "character")
  expect_match(format_num_br(0, currency = TRUE), "R\\$")
  expect_match(format_num_br(0, percent = TRUE), "0%")
})

test_that("format_num_br passes additional args to scales::number", {
  # Test with suffix parameter
  result <- format_num_br(1234, suffix = " km")
  expect_match(result, "1\\.234 km")
})

# Tests for save_insper_plot()

test_that("save_insper_plot accepts parameters", {
  skip_if_not_installed("ggplot2")
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(x = wt, y = mpg)) +
    ggplot2::geom_point()
  temp_file <- tempfile(fileext = ".png")
  expect_no_error(save_insper_plot(p, temp_file))
  expect_true(file.exists(temp_file))
  unlink(temp_file)
})

test_that("save_insper_plot respects dimensions", {
  skip_if_not_installed("ggplot2")
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(x = wt, y = mpg)) +
    ggplot2::geom_point()
  temp_file <- tempfile(fileext = ".png")
  expect_no_error(save_insper_plot(p, temp_file, width = 8, height = 6))
  expect_true(file.exists(temp_file))
  unlink(temp_file)
})

test_that("save_insper_plot handles different file formats", {
  skip_if_not_installed("ggplot2")
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(x = wt, y = mpg)) +
    ggplot2::geom_point()

  # PNG
  temp_png <- tempfile(fileext = ".png")
  expect_no_error(save_insper_plot(p, temp_png))
  expect_true(file.exists(temp_png))
  unlink(temp_png)

  # PDF
  temp_pdf <- tempfile(fileext = ".pdf")
  expect_no_error(save_insper_plot(p, temp_pdf))
  expect_true(file.exists(temp_pdf))
  unlink(temp_pdf)
})
