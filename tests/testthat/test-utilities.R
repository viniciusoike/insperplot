test_that("format_brl formats currency correctly", {
  result <- format_brl(1234.56)
  expect_type(result, "character")
  expect_match(result, "R\\$")
  expect_match(result, "1\\.23")
})

test_that("format_brl handles large numbers", {
  result <- format_brl(1234567.89)
  expect_match(result, "1\\.234\\.56")
})

test_that("format_brl symbol parameter works", {
  with_symbol <- format_brl(1000, symbol = TRUE)
  without_symbol <- format_brl(1000, symbol = FALSE)
  expect_match(with_symbol, "R\\$")
  expect_no_match(without_symbol, "R\\$")
})

test_that("format_brl handles zero and negative numbers", {
  expect_type(format_brl(0), "character")
  expect_type(format_brl(-1234.56), "character")
  expect_match(format_brl(-1234.56), "-")
})

test_that("format_percent_br formats correctly", {
  result <- format_percent_br(0.1234)
  expect_type(result, "character")
  expect_match(result, "12,3%")
})

test_that("format_percent_br digits parameter works", {
  result1 <- format_percent_br(0.1234, digits = 1)
  result2 <- format_percent_br(0.1234, digits = 2)
  expect_match(result1, "12,3%")
  expect_match(result2, "12,34%")
})

test_that("format_percent_br handles edge cases", {
  expect_type(format_percent_br(0), "character")
  expect_type(format_percent_br(1), "character")
  expect_match(format_percent_br(1), "100")
})

test_that("format_num_br uses Brazilian format", {
  result <- format_num_br(1234.56, digits = 2)
  expect_match(result, "1\\.234,56")
})

test_that("format_num_br handles default digits", {
  result <- format_num_br(1234)
  expect_type(result, "character")
  expect_match(result, "1\\.234")
})

test_that("format_num_br handles large numbers", {
  result <- format_num_br(1234567890, digits = 0)
  expect_match(result, "1\\.234\\.567\\.890")
})

test_that("insper_caption builds caption string", {
  caption <- insper_caption(text = "Test", source = "Data")
  expect_type(caption, "character")
  expect_match(caption, "Test")
  expect_match(caption, "Data")
})

test_that("insper_caption handles NULL inputs", {
  expect_no_error(insper_caption(text = NULL))
  expect_no_error(insper_caption(source = NULL))
  expect_no_error(insper_caption(date = NULL))
})

test_that("insper_caption formats date correctly", {
  date <- as.Date("2025-01-15")
  caption <- insper_caption(date = date)
  expect_match(caption, "Insper")
  expect_match(caption, "2025")
})

test_that("insper_caption lang parameter works", {
  caption_pt <- insper_caption(source = "Test", lang = "pt")
  caption_en <- insper_caption(source = "Test", lang = "en")
  expect_match(caption_pt, "Fonte:")
  expect_match(caption_en, "Source:")
})

test_that("insper_caption combines multiple elements", {
  caption <- insper_caption(
    text = "Test text",
    source = "Test source",
    date = as.Date("2025-01-15")
  )
  expect_match(caption, "Test text")
  expect_match(caption, "Test source")
  expect_match(caption, "Insper")
  expect_match(caption, "\\|")
})

test_that("insper_caption warns on invalid date", {
  expect_warning(insper_caption(date = "not a date"), "Invalid date")
})

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
