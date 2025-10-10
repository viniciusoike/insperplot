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
