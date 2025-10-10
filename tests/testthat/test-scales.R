test_that("scale_color_insper returns discrete scale by default", {
  scale <- scale_color_insper()
  expect_s3_class(scale, "ScaleDiscrete")
  expect_s3_class(scale, "Scale")
})

test_that("scale_color_insper works with discrete=FALSE", {
  scale <- scale_color_insper(discrete = FALSE)
  expect_s3_class(scale, "Scale")
})

test_that("scale_fill_insper returns discrete scale by default", {
  scale <- scale_fill_insper()
  expect_s3_class(scale, "ScaleDiscrete")
  expect_s3_class(scale, "Scale")
})

test_that("scale_fill_insper works with discrete=FALSE", {
  scale <- scale_fill_insper(discrete = FALSE)
  expect_s3_class(scale, "Scale")
})

test_that("scale_colour_insper is alias for scale_color_insper", {
  expect_identical(scale_colour_insper, scale_color_insper)
})

test_that("scales accept different palettes", {
  expect_no_error(scale_color_insper(palette = "reds"))
  expect_no_error(scale_color_insper(palette = "main"))
  expect_no_error(scale_fill_insper(palette = "bright"))
  expect_no_error(scale_fill_insper(palette = "categorical"))
})

test_that("scales accept reverse parameter", {
  expect_no_error(scale_color_insper(reverse = TRUE))
  expect_no_error(scale_color_insper(reverse = FALSE))
  expect_no_error(scale_fill_insper(reverse = TRUE))
  expect_no_error(scale_fill_insper(reverse = FALSE))
})

test_that("scales can be added to ggplot", {
  skip_if_not_installed("ggplot2")

  p_color <- ggplot2::ggplot(mtcars, ggplot2::aes(x = wt, y = mpg, color = factor(cyl))) +
    ggplot2::geom_point() +
    scale_color_insper()
  expect_s3_class(p_color, "ggplot")

  p_fill <- ggplot2::ggplot(mtcars, ggplot2::aes(x = factor(cyl), fill = factor(cyl))) +
    ggplot2::geom_bar() +
    scale_fill_insper()
  expect_s3_class(p_fill, "ggplot")
})

test_that("scales work with different palette types", {
  skip_if_not_installed("ggplot2")

  # Discrete color scale
  p1 <- ggplot2::ggplot(mtcars, ggplot2::aes(x = wt, y = mpg, color = factor(cyl))) +
    ggplot2::geom_point() +
    scale_color_insper(palette = "reds", discrete = TRUE)
  expect_s3_class(p1, "ggplot")

  # Continuous color scale
  p2 <- ggplot2::ggplot(mtcars, ggplot2::aes(x = wt, y = mpg, color = mpg)) +
    ggplot2::geom_point() +
    scale_color_insper(palette = "reds", discrete = FALSE)
  expect_s3_class(p2, "ggplot")
})
