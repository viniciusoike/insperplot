test_that("scale_color_insper_d returns discrete scale", {
  scale <- scale_color_insper_d()
  expect_s3_class(scale, "ScaleDiscrete")
  expect_s3_class(scale, "Scale")
})

test_that("scale_color_insper_c returns continuous scale", {
  scale <- scale_color_insper_c()
  expect_s3_class(scale, "Scale")
})

test_that("scale_fill_insper_d returns discrete scale", {
  scale <- scale_fill_insper_d()
  expect_s3_class(scale, "ScaleDiscrete")
  expect_s3_class(scale, "Scale")
})

test_that("scale_fill_insper_c returns continuous scale", {
  scale <- scale_fill_insper_c()
  expect_s3_class(scale, "Scale")
})

test_that("scale_colour_insper_d is alias for scale_color_insper_d", {
  expect_identical(scale_colour_insper_d, scale_color_insper_d)
})

test_that("scale_colour_insper_c is alias for scale_color_insper_c", {
  expect_identical(scale_colour_insper_c, scale_color_insper_c)
})

test_that("discrete scales accept different palettes", {
  expect_no_error(scale_color_insper_d(palette = "reds"))
  expect_no_error(scale_color_insper_d(palette = "main"))
  expect_no_error(scale_fill_insper_d(palette = "bright"))
  expect_no_error(scale_fill_insper_d(palette = "categorical"))
})

test_that("continuous scales accept different palettes", {
  expect_no_error(scale_color_insper_c(palette = "reds"))
  expect_no_error(scale_color_insper_c(palette = "teals"))
  expect_no_error(scale_fill_insper_c(palette = "red_teal"))
})

test_that("scales accept reverse parameter", {
  expect_no_error(scale_color_insper_d(reverse = TRUE))
  expect_no_error(scale_color_insper_d(reverse = FALSE))
  expect_no_error(scale_fill_insper_c(reverse = TRUE))
  expect_no_error(scale_fill_insper_c(reverse = FALSE))
})

test_that("discrete scales can be added to ggplot", {
  skip_if_not_installed("ggplot2")

  p_color <- ggplot2::ggplot(mtcars, ggplot2::aes(x = wt, y = mpg, color = factor(cyl))) +
    ggplot2::geom_point() +
    scale_color_insper_d()
  expect_s3_class(p_color, "ggplot")

  p_fill <- ggplot2::ggplot(mtcars, ggplot2::aes(x = factor(cyl), fill = factor(cyl))) +
    ggplot2::geom_bar() +
    scale_fill_insper_d()
  expect_s3_class(p_fill, "ggplot")
})

test_that("continuous scales can be added to ggplot", {
  skip_if_not_installed("ggplot2")

  # Continuous color scale
  p1 <- ggplot2::ggplot(mtcars, ggplot2::aes(x = wt, y = mpg, color = mpg)) +
    ggplot2::geom_point() +
    scale_color_insper_c(palette = "reds")
  expect_s3_class(p1, "ggplot")

  # Continuous fill scale
  p2 <- ggplot2::ggplot(mtcars, ggplot2::aes(x = wt, y = mpg, fill = mpg)) +
    ggplot2::geom_tile() +
    scale_fill_insper_c(palette = "teals")
  expect_s3_class(p2, "ggplot")
})
