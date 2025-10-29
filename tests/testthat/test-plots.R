test_that("insper_barplot returns ggplot object", {
  skip_if_not_installed("ggplot2")
  df <- data.frame(x = c("A", "B", "C"), y = c(1, 2, 3))
  p <- insper_barplot(df, x = x, y = y)
  expect_s3_class(p, "ggplot")
})

test_that("insper_barplot validates data frame input", {
  expect_error(insper_barplot(list(), x = x, y = y), "data frame")
  expect_error(insper_barplot(c(1, 2, 3), x = x, y = y), "data frame")
})

test_that("insper_barplot validates position parameter", {
  df <- data.frame(x = c("A", "B"), y = c(1, 2), grp = c("X", "Y"))
  expect_no_error(insper_barplot(df, x = x, y = y, fill = grp, position = "dodge"))
  expect_no_error(insper_barplot(df, x = x, y = y, fill = grp, position = "stack"))
  expect_error(insper_barplot(df, x = x, y = y, fill = grp, position = "invalid"))
})

test_that("insper_barplot handles grouped bars", {
  skip_if_not_installed("ggplot2")
  df <- data.frame(
    x = rep(c("A", "B"), each = 2),
    y = c(1, 2, 3, 4),
    grp = rep(c("X", "Y"), 2)
  )
  p <- insper_barplot(df, x = x, y = y, fill = grp)
  expect_s3_class(p, "ggplot")
})

test_that("insper_barplot works with swapped axes", {
  skip_if_not_installed("ggplot2")
  df <- data.frame(category = c("A", "B"), value = c(1, 2))

  # Vertical bars: categorical x, numeric y
  p1 <- insper_barplot(df, x = category, y = value)
  expect_s3_class(p1, "ggplot")

  # Check for horizontal line at y=0 (vertical bars)
  has_hline <- any(sapply(p1$layers, function(l) {
    inherits(l$geom, "GeomHline")
  }))
  expect_true(has_hline, "Vertical bars should have horizontal line at y=0")

  # Check for y-axis continuous scale
  expect_true("ScaleContinuousPosition" %in% class(p1$scales$get_scales("y")))

  # Horizontal bars: numeric x, categorical y
  p2 <- insper_barplot(df, x = value, y = category)
  expect_s3_class(p2, "ggplot")

  # Check for vertical line at x=0 (horizontal bars)
  has_vline <- any(sapply(p2$layers, function(l) {
    inherits(l$geom, "GeomVline")
  }))
  expect_true(has_vline, "Horizontal bars should have vertical line at x=0")

  # Check for x-axis continuous scale
  expect_true("ScaleContinuousPosition" %in% class(p2$scales$get_scales("x")))
})

test_that("insper_barplot text parameter adds labels", {
  skip_if_not_installed("ggplot2")
  df <- data.frame(x = c("A", "B"), y = c(1, 2))
  p <- insper_barplot(df, x = x, y = y, text = TRUE)
  expect_s3_class(p, "ggplot")
  # Check that geom_text is present
  expect_true(any(sapply(p$layers, function(l) inherits(l$geom, "GeomText"))))
})

test_that("insper_scatterplot creates plot", {
  skip_if_not_installed("ggplot2")
  p <- insper_scatterplot(mtcars, x = wt, y = mpg)
  expect_s3_class(p, "ggplot")
})

test_that("insper_scatterplot handles color aesthetic", {
  skip_if_not_installed("ggplot2")
  p <- insper_scatterplot(mtcars, x = wt, y = mpg, color = factor(cyl))
  expect_s3_class(p, "ggplot")
})

test_that("insper_scatterplot add_smooth parameter works", {
  skip_if_not_installed("ggplot2")
  p1 <- insper_scatterplot(mtcars, x = wt, y = mpg, add_smooth = TRUE)
  p2 <- insper_scatterplot(mtcars, x = wt, y = mpg, add_smooth = FALSE)
  expect_s3_class(p1, "ggplot")
  expect_s3_class(p2, "ggplot")
  # Check smooth is present in p1
  expect_true(any(sapply(p1$layers, function(l) inherits(l$geom, "GeomSmooth"))))
})

test_that("insper_timeseries creates plot", {
  skip_if_not_installed("ggplot2")
  df <- data.frame(time = 1:10, value = rnorm(10))
  p <- insper_timeseries(df, x = time, y = value)
  expect_s3_class(p, "ggplot")
})

test_that("insper_timeseries handles color aesthetic", {
  skip_if_not_installed("ggplot2")
  df <- data.frame(
    time = rep(1:10, 2),
    value = rnorm(20),
    group = rep(c("A", "B"), each = 10)
  )
  p <- insper_timeseries(df, x = time, y = value, color = group)
  expect_s3_class(p, "ggplot")
})

test_that("insper_boxplot creates plot", {
  skip_if_not_installed("ggplot2")
  p <- insper_boxplot(mtcars, x = factor(cyl), y = mpg)
  expect_s3_class(p, "ggplot")
})

test_that("insper_boxplot handles fill aesthetic", {
  skip_if_not_installed("ggplot2")
  p <- insper_boxplot(mtcars, x = factor(cyl), y = mpg, fill = factor(cyl))
  expect_s3_class(p, "ggplot")
})

test_that("insper_heatmap creates plot from matrix", {
  skip_if_not_installed("ggplot2")
  mat <- cor(mtcars[, 1:4])
  p <- insper_heatmap(mat)
  expect_s3_class(p, "ggplot")
})

test_that("insper_heatmap show_values parameter works", {
  skip_if_not_installed("ggplot2")
  mat <- cor(mtcars[, 1:4])
  p1 <- insper_heatmap(mat, show_values = TRUE)
  p2 <- insper_heatmap(mat, show_values = FALSE)
  expect_s3_class(p1, "ggplot")
  expect_s3_class(p2, "ggplot")
})

test_that("plot functions work without title/subtitle/caption (use labs() instead)", {
  skip_if_not_installed("ggplot2")

  # Functions should work without built-in title parameters
  p1 <- insper_scatterplot(mtcars, x = wt, y = mpg)
  expect_s3_class(p1, "ggplot")

  # Users can add labels with labs()
  p1_with_labs <- p1 + ggplot2::labs(
    title = "Test Title",
    subtitle = "Test Subtitle",
    caption = "Test Caption"
  )
  expect_s3_class(p1_with_labs, "ggplot")

  p2 <- insper_timeseries(
    data.frame(time = 1:10, value = rnorm(10)),
    x = time, y = value
  ) + ggplot2::labs(title = "Test")
  expect_s3_class(p2, "ggplot")

  p3 <- insper_boxplot(
    mtcars, x = factor(cyl), y = mpg
  ) + ggplot2::labs(caption = "Test")
  expect_s3_class(p3, "ggplot")
})

# Tests for new plot functions

test_that("insper_area creates plot", {
  skip_if_not_installed("ggplot2")
  df <- data.frame(time = 1:20, value = cumsum(rnorm(20)))
  p <- insper_area(df, x = time, y = value)
  expect_s3_class(p, "ggplot")
})

test_that("insper_area handles fill aesthetic", {
  skip_if_not_installed("ggplot2")
  df <- data.frame(
    time = rep(1:20, 2),
    value = cumsum(rnorm(40)),
    group = rep(c("A", "B"), each = 20)
  )
  p <- insper_area(df, x = time, y = value, fill = group)
  expect_s3_class(p, "ggplot")
})

test_that("insper_area stacked parameter works", {
  skip_if_not_installed("ggplot2")
  df <- data.frame(
    time = rep(1:10, 2),
    value = abs(rnorm(20)),
    group = rep(c("A", "B"), each = 10)
  )
  p <- insper_area(df, x = time, y = value, fill = group, stacked = TRUE)
  expect_s3_class(p, "ggplot")
})

test_that("insper_area custom fill_color works", {
  skip_if_not_installed("ggplot2")
  df <- data.frame(time = 1:20, value = cumsum(rnorm(20)))
  p <- insper_area(df, x = time, y = value,
                   fill_color = get_insper_colors("reds1"))
  expect_s3_class(p, "ggplot")
})

test_that("insper_area custom line parameters work", {
  skip_if_not_installed("ggplot2")
  df <- data.frame(time = 1:20, value = cumsum(rnorm(20)))
  p <- insper_area(df, x = time, y = value,
                   line_color = get_insper_colors("oranges1"),
                   line_width = 2,
                   line_alpha = 0.5)
  expect_s3_class(p, "ggplot")
})

test_that("insper_area zero parameter adds horizontal line", {
  skip_if_not_installed("ggplot2")
  df <- data.frame(time = 1:20, value = cumsum(rnorm(20)))
  p <- insper_area(df, x = time, y = value, zero = TRUE)
  expect_s3_class(p, "ggplot")
  # Check that the plot contains a horizontal line layer
  expect_true(any(sapply(p$layers, function(layer) {
    inherits(layer$geom, "GeomHline")
  })))
})

test_that("insper_area works without line overlay", {
  skip_if_not_installed("ggplot2")
  df <- data.frame(time = 1:20, value = cumsum(rnorm(20)))
  p <- insper_area(df, x = time, y = value, add_line = FALSE)
  expect_s3_class(p, "ggplot")
})

test_that("insper_violin creates plot", {
  skip_if_not_installed("ggplot2")
  p <- insper_violin(mtcars, x = factor(cyl), y = mpg)
  expect_s3_class(p, "ggplot")
})

test_that("insper_violin handles fill aesthetic", {
  skip_if_not_installed("ggplot2")
  p <- insper_violin(mtcars, x = factor(cyl), y = mpg, fill = factor(cyl))
  expect_s3_class(p, "ggplot")
})

test_that("insper_violin optional features work", {
  skip_if_not_installed("ggplot2")
  p1 <- insper_violin(mtcars, x = factor(cyl), y = mpg, show_boxplot = FALSE)
  p2 <- insper_violin(mtcars, x = factor(cyl), y = mpg, show_points = TRUE)
  expect_s3_class(p1, "ggplot")
  expect_s3_class(p2, "ggplot")
})

# Tests for insper_density()
test_that("insper_density creates plot", {
  skip_if_not_installed("ggplot2")
  p <- insper_density(mtcars, x = mpg)
  expect_s3_class(p, "ggplot")
})

test_that("insper_density handles fill aesthetic with variable mapping", {
  skip_if_not_installed("ggplot2")
  p <- insper_density(iris, x = Sepal.Length, fill = Species)
  expect_s3_class(p, "ggplot")
})

test_that("insper_density validates data frame input", {
  expect_error(insper_density(list(), x = x), "data frame")
  expect_error(insper_density(c(1, 2, 3), x = x), "data frame")
})

test_that("insper_density bw parameter works", {
  skip_if_not_installed("ggplot2")
  p1 <- insper_density(mtcars, x = mpg, bw = 1)
  p2 <- insper_density(mtcars, x = mpg, bw = 5)
  p3 <- insper_density(mtcars, x = mpg, bw = "nrd")
  expect_s3_class(p1, "ggplot")
  expect_s3_class(p2, "ggplot")
  expect_s3_class(p3, "ggplot")
})

test_that("insper_density kernel parameter works", {
  skip_if_not_installed("ggplot2")
  p1 <- insper_density(mtcars, x = mpg, kernel = "epanechnikov")
  p2 <- insper_density(mtcars, x = mpg, kernel = "rectangular")
  p3 <- insper_density(mtcars, x = mpg, kernel = "triangular")
  expect_s3_class(p1, "ggplot")
  expect_s3_class(p2, "ggplot")
  expect_s3_class(p3, "ggplot")
})

test_that("insper_density adjust parameter works", {
  skip_if_not_installed("ggplot2")
  p1 <- insper_density(mtcars, x = mpg, adjust = 0.5)
  p2 <- insper_density(mtcars, x = mpg, adjust = 2)
  expect_s3_class(p1, "ggplot")
  expect_s3_class(p2, "ggplot")
})

test_that("insper_density static color works", {
  skip_if_not_installed("ggplot2")
  p <- insper_density(mtcars, x = mpg, fill = "purple")
  expect_s3_class(p, "ggplot")
})

# Tests for insper_histogram()
test_that("insper_histogram creates plot", {
  skip_if_not_installed("ggplot2")
  p <- insper_histogram(mtcars, x = mpg)
  expect_s3_class(p, "ggplot")
})

test_that("insper_histogram bin methods work", {
  skip_if_not_installed("ggplot2")
  p1 <- insper_histogram(mtcars, x = mpg, bin_method = "sturges")
  p2 <- insper_histogram(mtcars, x = mpg, bin_method = "fd")
  p3 <- insper_histogram(mtcars, x = mpg, bin_method = "scott")
  expect_s3_class(p1, "ggplot")
  expect_s3_class(p2, "ggplot")
  expect_s3_class(p3, "ggplot")
})

test_that("insper_histogram manual bins work", {
  skip_if_not_installed("ggplot2")
  p <- insper_histogram(mtcars, x = mpg, bin_method = "manual", bins = 20)
  expect_s3_class(p, "ggplot")
})

test_that("insper_histogram validates manual bins", {
  expect_error(
    insper_histogram(mtcars, x = mpg, bin_method = "manual"),
    "bins.*must be specified"
  )
})

test_that("insper_histogram handles fill aesthetic", {
  skip_if_not_installed("ggplot2")
  p <- insper_histogram(iris, x = Sepal.Length, fill = Species)
  expect_s3_class(p, "ggplot")
})

test_that("insper_histogram zero parameter works", {
  skip_if_not_installed("ggplot2")
  p1 <- insper_histogram(mtcars, x = mpg, zero = TRUE)
  p2 <- insper_histogram(mtcars, x = mpg, zero = FALSE)
  expect_s3_class(p1, "ggplot")
  expect_s3_class(p2, "ggplot")
  # Check that p1 has hline
  expect_true(any(sapply(p1$layers, function(l) inherits(l$geom, "GeomHline"))))
})

test_that("insper_histogram static color works", {
  skip_if_not_installed("ggplot2")
  p <- insper_histogram(mtcars, x = mpg, fill = "steelblue")
  expect_s3_class(p, "ggplot")
})
