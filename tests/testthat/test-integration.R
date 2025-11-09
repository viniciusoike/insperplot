# Integration tests for combining plot functions, themes, and scales
# These tests verify that different components work together correctly

test_that("barplot + theme_insper + scale_fill_insper_d works", {
  skip_if_not_installed("ggplot2")
  df <- data.frame(
    category = c("A", "B", "C"),
    value = c(10, 20, 15),
    group = c("X", "Y", "Z")
  )

  p <- insper_barplot(df, x = category, y = value, fill = group) +
    theme_insper(grid = FALSE, border = "half") +
    scale_fill_insper_d("main")

  expect_s3_class(p, "ggplot")

  # Should be able to build the plot without errors
  expect_no_error(ggplot2::ggplot_build(p))
})

test_that("scatterplot + theme variants + scale_color_insper_d works", {
  skip_if_not_installed("ggplot2")

  # Test with theme_insper_minimal
  p1 <- insper_scatterplot(iris, x = Sepal.Length, y = Sepal.Width, color = Species) +
    theme_insper_minimal() +
    scale_color_insper_d("bright")
  expect_s3_class(p1, "ggplot")
  expect_no_error(ggplot2::ggplot_build(p1))

  # Test with theme_insper_presentation
  p2 <- insper_scatterplot(iris, x = Sepal.Length, y = Sepal.Width, color = Species) +
    theme_insper_presentation() +
    scale_color_insper_d("contrast")
  expect_s3_class(p2, "ggplot")
  expect_no_error(ggplot2::ggplot_build(p2))

  # Test with theme_insper_print
  p3 <- insper_scatterplot(iris, x = Sepal.Length, y = Sepal.Width, color = Species) +
    theme_insper_print() +
    scale_color_insper_d("categorical")
  expect_s3_class(p3, "ggplot")
  expect_no_error(ggplot2::ggplot_build(p3))
})

test_that("timeseries + theme + continuous scale works", {
  skip_if_not_installed("ggplot2")
  df <- data.frame(
    time = 1:100,
    value = cumsum(rnorm(100)),
    intensity = seq(0, 1, length.out = 100)
  )

  p <- insper_timeseries(df, x = time, y = value, color = intensity) +
    theme_insper(grid = TRUE, border = "none") +
    scale_color_insper_c("reds")

  expect_s3_class(p, "ggplot")
  expect_no_error(ggplot2::ggplot_build(p))
})

test_that("area plot + theme + labs works", {
  skip_if_not_installed("ggplot2")
  df <- data.frame(time = 1:50, value = cumsum(rnorm(50)))

  p <- insper_area(df, x = time, y = value) +
    theme_insper(base_size = 14, border = "closed") +
    ggplot2::labs(
      title = "Test Title",
      subtitle = "Test Subtitle",
      caption = insper_caption("Test Source", lang = "en")
    )

  expect_s3_class(p, "ggplot")
  expect_no_error(ggplot2::ggplot_build(p))
})

test_that("boxplot + theme + scale + coord_flip works", {
  skip_if_not_installed("ggplot2")

  p <- insper_boxplot(iris, x = Species, y = Sepal.Length, fill = Species) +
    theme_insper_minimal() +
    scale_fill_insper_d("teals") +
    ggplot2::coord_flip()

  expect_s3_class(p, "ggplot")
  expect_no_error(ggplot2::ggplot_build(p))
})

test_that("violin + theme + scale + facet works", {
  skip_if_not_installed("ggplot2")

  p <- insper_violin(iris, x = Species, y = Sepal.Length, fill = Species) +
    theme_insper(grid = FALSE) +
    scale_fill_insper_d("oranges")

  expect_s3_class(p, "ggplot")
  expect_no_error(ggplot2::ggplot_build(p))
})

test_that("heatmap + theme + continuous scale works", {
  skip_if_not_installed("ggplot2")
  cor_mat <- cor(mtcars[, 1:5])

  p <- insper_heatmap(cor_mat, show_values = TRUE) +
    theme_insper(base_size = 10) +
    scale_fill_insper_c("red_teal")

  expect_s3_class(p, "ggplot")
  expect_no_error(ggplot2::ggplot_build(p))
})

test_that("histogram + theme + scale works", {
  skip_if_not_installed("ggplot2")

  p <- insper_histogram(mtcars, x = mpg, bin_method = "sturges") +
    theme_insper_print() +
    ggplot2::labs(title = "MPG Distribution")

  expect_s3_class(p, "ggplot")
  expect_no_error(ggplot2::ggplot_build(p))
})

test_that("density + theme + scale works", {
  skip_if_not_installed("ggplot2")

  p <- insper_density(iris, x = Sepal.Length, fill = Species) +
    theme_insper(grid = TRUE, border = "half") +
    scale_fill_insper_d("grays")

  expect_s3_class(p, "ggplot")
  expect_no_error(ggplot2::ggplot_build(p))
})

test_that("multiple plots can use same theme and scale", {
  skip_if_not_installed("ggplot2")

  # Define reusable theme and scale
  my_theme <- theme_insper(base_size = 12, grid = FALSE)
  my_scale <- scale_fill_insper_d("main")

  # Create multiple plots with same styling
  p1 <- insper_barplot(
    data.frame(x = c("A", "B"), y = c(1, 2), g = c("X", "Y")),
    x = x, y = y, fill = g
  ) + my_theme + my_scale

  p2 <- insper_boxplot(iris, x = Species, y = Sepal.Length, fill = Species) +
    my_theme + my_scale

  expect_s3_class(p1, "ggplot")
  expect_s3_class(p2, "ggplot")
  expect_no_error(ggplot2::ggplot_build(p1))
  expect_no_error(ggplot2::ggplot_build(p2))
})

test_that("plot + theme + scale + save_insper_plot workflow", {
  skip_if_not_installed("ggplot2")

  p <- insper_scatterplot(mtcars, x = wt, y = mpg, color = factor(cyl)) +
    theme_insper(base_size = 14) +
    scale_color_insper_d("contrast") +
    ggplot2::labs(
      title = "Fuel Efficiency vs Weight",
      caption = insper_caption("mtcars dataset", lang = "en")
    )

  temp_file <- tempfile(fileext = ".png")
  expect_no_error(save_insper_plot(p, temp_file, width = 8, height = 6))
  expect_true(file.exists(temp_file))
  unlink(temp_file)
})

test_that("plot with all formatting utilities works", {
  skip_if_not_installed("ggplot2")

  # Create data with Brazilian-formatted labels
  df <- data.frame(
    category = c("A", "B", "C"),
    value = c(1234.56, 2345.67, 3456.78)
  )

  df$label <- format_num_br(df$value, currency = TRUE, digits = 2)

  p <- insper_barplot(df, x = category, y = value, text = FALSE) +
    ggplot2::geom_text(
      ggplot2::aes(label = label),
      vjust = -0.5,
      family = "sans"
    ) +
    theme_insper() +
    ggplot2::labs(
      title = "Valores em Reais",
      caption = insper_caption("Dados fictícios", lang = "pt")
    )

  expect_s3_class(p, "ggplot")
  expect_no_error(ggplot2::ggplot_build(p))
})

test_that("combining diverging scale with area plot works", {
  skip_if_not_installed("ggplot2")

  df <- data.frame(
    time = rep(1:20, 2),
    value = c(cumsum(rnorm(20)), cumsum(rnorm(20))),
    group = rep(c("Positive", "Negative"), each = 20)
  )

  p <- insper_area(df, x = time, y = value, fill = group) +
    theme_insper_minimal() +
    scale_fill_insper_d("diverging")

  expect_s3_class(p, "ggplot")
  expect_no_error(ggplot2::ggplot_build(p))
})

test_that("theme alignment options work with titled plots", {
  skip_if_not_installed("ggplot2")

  p1 <- insper_scatterplot(mtcars, x = wt, y = mpg) +
    theme_insper(align = "panel") +
    ggplot2::labs(title = "Panel Aligned")

  p2 <- insper_scatterplot(mtcars, x = wt, y = mpg) +
    theme_insper(align = "plot") +
    ggplot2::labs(title = "Plot Aligned")

  expect_s3_class(p1, "ggplot")
  expect_s3_class(p2, "ggplot")
  expect_no_error(ggplot2::ggplot_build(p1))
  expect_no_error(ggplot2::ggplot_build(p2))
})

test_that("all plot functions work with theme_insper and custom fonts", {
  skip_if_not_installed("ggplot2")

  # Use fallback fonts that should work everywhere
  custom_theme <- theme_insper(
    font_title = "sans",
    font_text = "sans",
    base_size = 11
  )

  # Test each plot function
  df <- data.frame(x = 1:10, y = rnorm(10), g = rep(c("A", "B"), 5))

  plots <- list(
    insper_barplot(df, x = factor(x), y = y) + custom_theme,
    insper_scatterplot(df, x = x, y = y) + custom_theme,
    insper_timeseries(df, x = x, y = y) + custom_theme,
    insper_area(df, x = x, y = y) + custom_theme,
    insper_boxplot(df, x = g, y = y) + custom_theme,
    insper_violin(df, x = g, y = y) + custom_theme,
    insper_histogram(df, x = y) + custom_theme,
    insper_density(df, x = y) + custom_theme
  )

  for (p in plots) {
    expect_s3_class(p, "ggplot")
    expect_no_error(ggplot2::ggplot_build(p))
  }
})
