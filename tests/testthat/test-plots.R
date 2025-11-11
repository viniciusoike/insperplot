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
  # Dodge warns about non-factor x but still works
  expect_warning(insper_barplot(df, x = x, y = y, fill = grp, position = "dodge"), "factor")
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
  # Suppress warning about non-factor x (expected behavior)
  suppressWarnings({
    p <- insper_barplot(df, x = x, y = y, fill = grp)
  })
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

test_that("insper_barplot text labels work with stacked bars", {
  skip_if_not_installed("ggplot2")
  df <- data.frame(
    x = rep(c("A", "B"), each = 2),
    y = c(10, 15, 20, 25),
    grp = rep(c("X", "Y"), 2)
  )
  p <- insper_barplot(df, x = x, y = y, fill = grp, position = "stack", text = TRUE)
  expect_s3_class(p, "ggplot")

  # Check that geom_text has position_stack
  text_layer <- p$layers[[which(sapply(p$layers, function(l) inherits(l$geom, "GeomText")))[1]]]
  expect_true(inherits(text_layer$position, "PositionStack"))
})

test_that("insper_barplot text labels work with filled bars", {
  skip_if_not_installed("ggplot2")
  df <- data.frame(
    x = rep(c("A", "B"), each = 2),
    y = c(10, 15, 20, 25),
    grp = rep(c("X", "Y"), 2)
  )
  p <- insper_barplot(df, x = x, y = y, fill = grp, position = "fill", text = TRUE)
  expect_s3_class(p, "ggplot")

  # Check that geom_text has position_fill
  text_layer <- p$layers[[which(sapply(p$layers, function(l) inherits(l$geom, "GeomText")))[1]]]
  expect_true(inherits(text_layer$position, "PositionFill"))
})

test_that("insper_barplot stack_vjust parameter works", {
  skip_if_not_installed("ggplot2")
  df <- data.frame(
    x = rep(c("A", "B"), each = 2),
    y = c(10, 15, 20, 25),
    grp = rep(c("X", "Y"), 2)
  )

  # Test different stack_vjust values
  p1 <- insper_barplot(df, x = x, y = y, fill = grp, position = "stack",
                       text = TRUE, stack_vjust = 0)
  p2 <- insper_barplot(df, x = x, y = y, fill = grp, position = "stack",
                       text = TRUE, stack_vjust = 0.5)
  p3 <- insper_barplot(df, x = x, y = y, fill = grp, position = "stack",
                       text = TRUE, stack_vjust = 1)

  expect_s3_class(p1, "ggplot")
  expect_s3_class(p2, "ggplot")
  expect_s3_class(p3, "ggplot")
})

test_that("insper_barplot warns when dodge used with non-factor x", {
  skip_if_not_installed("ggplot2")
  df <- data.frame(
    x = rep(c("A", "B"), each = 2),  # character, not factor
    y = c(10, 15, 20, 25),
    grp = rep(c("X", "Y"), 2)
  )

  expect_warning(
    insper_barplot(df, x = x, y = y, fill = grp, position = "dodge"),
    "factor"
  )
})

test_that("insper_barplot automatic percentage formatting for fill position", {
  skip_if_not_installed("ggplot2")
  # Test with proportion data (0-1)
  df <- data.frame(
    x = rep(c("A", "B"), each = 2),
    y = c(0.4, 0.6, 0.3, 0.7),  # proportions
    grp = rep(c("X", "Y"), 2)
  )

  p <- insper_barplot(df, x = x, y = y, fill = grp, position = "fill", text = TRUE)
  expect_s3_class(p, "ggplot")

  # The plot should build without errors
  expect_no_error(ggplot2::ggplot_build(p))
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

test_that("insper_area smart detection: stacks when fill is a variable", {
  skip_if_not_installed("ggplot2")
  df <- data.frame(
    time = rep(1:10, 2),
    value = abs(rnorm(20)),
    group = rep(c("A", "B"), each = 10)
  )
  # With fill variable and stacked = NULL (default), should stack
  p <- insper_area(df, x = time, y = value, fill = group)
  expect_s3_class(p, "ggplot")
  # Check that geom_area has position = "stack"
  area_layer <- p$layers[[1]]
  expect_true(inherits(area_layer$position, "PositionStack"))
})

test_that("insper_area smart detection: respects explicit stacked = FALSE", {
  skip_if_not_installed("ggplot2")
  df <- data.frame(
    time = rep(1:10, 2),
    value = abs(rnorm(20)),
    group = rep(c("A", "B"), each = 10)
  )
  # With fill variable but explicit stacked = FALSE, should NOT stack
  p <- insper_area(df, x = time, y = value, fill = group, stacked = FALSE)
  expect_s3_class(p, "ggplot")
  # Check that geom_area has position = "identity"
  area_layer <- p$layers[[1]]
  expect_true(inherits(area_layer$position, "PositionIdentity"))
})

test_that("insper_area smart detection: no effect without fill variable", {
  skip_if_not_installed("ggplot2")
  df <- data.frame(time = 1:20, value = cumsum(rnorm(20)))
  # Without fill variable, stacked = NULL should have no stacking effect
  p <- insper_area(df, x = time, y = value)
  expect_s3_class(p, "ggplot")
  # When no fill variable is provided, should not stack (uses default ggplot2 position)
  # The geom_area is created without explicit position parameter, so it uses defaults
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

# Tests for ... parameter functionality across plot functions
test_that("insper_barplot ... parameter passes to geom_col", {
  skip_if_not_installed("ggplot2")
  df <- data.frame(x = c("A", "B", "C"), y = c(1, 2, 3))
  # Test width parameter (geom_col specific)
  p1 <- insper_barplot(df, x = x, y = y, width = 0.5)
  expect_s3_class(p1, "ggplot")
  # Test alpha parameter
  p2 <- insper_barplot(df, x = x, y = y, alpha = 0.5)
  expect_s3_class(p2, "ggplot")
})

test_that("insper_scatterplot ... parameter passes to geom_point", {
  skip_if_not_installed("ggplot2")
  # Test shape parameter (geom_point specific)
  p1 <- insper_scatterplot(mtcars, x = wt, y = mpg, shape = 17)
  expect_s3_class(p1, "ggplot")
  # Test stroke parameter (geom_point specific)
  p2 <- insper_scatterplot(mtcars, x = wt, y = mpg, stroke = 2)
  expect_s3_class(p2, "ggplot")
})

test_that("insper_timeseries ... parameter passes to geom_line", {
  skip_if_not_installed("ggplot2")
  df <- data.frame(time = 1:10, value = rnorm(10))
  # Test linetype parameter (geom_line specific)
  p1 <- insper_timeseries(df, x = time, y = value, linetype = "dashed")
  expect_s3_class(p1, "ggplot")
  # Test alpha parameter
  p2 <- insper_timeseries(df, x = time, y = value, alpha = 0.7)
  expect_s3_class(p2, "ggplot")
})

test_that("insper_area ... parameter passes to geom_area", {
  skip_if_not_installed("ggplot2")
  df <- data.frame(time = 1:20, value = cumsum(rnorm(20)))
  # Test position parameter (geom_area specific)
  p1 <- insper_area(df, x = time, y = value, position = "identity")
  expect_s3_class(p1, "ggplot")
  # Test na.rm parameter
  p2 <- insper_area(df, x = time, y = value, na.rm = TRUE)
  expect_s3_class(p2, "ggplot")
})

test_that("insper_histogram ... parameter passes to geom_histogram", {
  skip_if_not_installed("ggplot2")
  # Test binwidth parameter (geom_histogram specific)
  p1 <- insper_histogram(mtcars, x = mpg, binwidth = 5)
  expect_s3_class(p1, "ggplot")
  # Test alpha parameter
  p2 <- insper_histogram(mtcars, x = mpg, alpha = 0.8)
  expect_s3_class(p2, "ggplot")
})

test_that("insper_density ... parameter passes to geom_density", {
  skip_if_not_installed("ggplot2")
  # Test n parameter (geom_density specific - number of points for density)
  p1 <- insper_density(mtcars, x = mpg, n = 256)
  expect_s3_class(p1, "ggplot")
  # Test na.rm parameter
  p2 <- insper_density(mtcars, x = mpg, na.rm = TRUE)
  expect_s3_class(p2, "ggplot")
})

test_that("insper_boxplot ... parameter passes to geom_boxplot", {
  skip_if_not_installed("ggplot2")
  # Test width parameter (geom_boxplot specific)
  p1 <- insper_boxplot(iris, x = Species, y = Sepal.Length, width = 0.5)
  expect_s3_class(p1, "ggplot")
  # Test outlier.shape parameter (geom_boxplot specific)
  p2 <- insper_boxplot(iris, x = Species, y = Sepal.Length, outlier.shape = NA)
  expect_s3_class(p2, "ggplot")
})

test_that("insper_violin ... parameter passes to geom_violin", {
  skip_if_not_installed("ggplot2")
  # Test width parameter (geom_violin specific)
  p1 <- insper_violin(iris, x = Species, y = Sepal.Length, width = 0.8)
  expect_s3_class(p1, "ggplot")
  # Test trim parameter (geom_violin specific)
  p2 <- insper_violin(iris, x = Species, y = Sepal.Length, trim = FALSE)
  expect_s3_class(p2, "ggplot")
})

test_that("insper_heatmap ... parameter passes to geom_tile", {
  skip_if_not_installed("ggplot2")
  cor_mat <- cor(mtcars[, 1:4])
  # Test width parameter (geom_tile specific)
  p1 <- insper_heatmap(cor_mat, width = 0.9)
  expect_s3_class(p1, "ggplot")
  # Test height parameter (geom_tile specific)
  p2 <- insper_heatmap(cor_mat, height = 0.9)
  expect_s3_class(p2, "ggplot")
})

# Extended tests for insper_scatterplot() ----

test_that("insper_scatterplot validates data frame input", {
  skip_if_not_installed("ggplot2")
  expect_error(
    insper_scatterplot("not a data frame", x = x, y = y),
    "data.*must be a data frame"
  )
  expect_error(
    insper_scatterplot(list(x = 1:5, y = 1:5), x = x, y = y),
    "data.*must be a data frame"
  )
})

test_that("insper_scatterplot validates smooth_method parameter", {
  skip_if_not_installed("ggplot2")
  expect_error(
    insper_scatterplot(mtcars, x = wt, y = mpg, add_smooth = TRUE, smooth_method = "invalid"),
    "smooth_method.*must be one of"
  )
})

test_that("insper_scatterplot smooth_method variations work", {
  skip_if_not_installed("ggplot2")
  # Test all valid smooth methods
  p_lm <- insper_scatterplot(mtcars, x = wt, y = mpg, add_smooth = TRUE, smooth_method = "lm")
  p_loess <- insper_scatterplot(mtcars, x = wt, y = mpg, add_smooth = TRUE, smooth_method = "loess")
  p_glm <- insper_scatterplot(mtcars, x = wt, y = mpg, add_smooth = TRUE, smooth_method = "glm")

  expect_s3_class(p_lm, "ggplot")
  expect_s3_class(p_loess, "ggplot")
  expect_s3_class(p_glm, "ggplot")

  # Check smooth layer is present
  expect_true(any(sapply(p_lm$layers, function(l) inherits(l$geom, "GeomSmooth"))))
})

test_that("insper_scatterplot fill aesthetic with variable mapping", {
  skip_if_not_installed("ggplot2")
  p <- insper_scatterplot(mtcars, x = wt, y = mpg, fill = factor(cyl), shape = 21)
  expect_s3_class(p, "ggplot")
  expect_no_error(ggplot2::ggplot_build(p))
})

test_that("insper_scatterplot fill aesthetic with static color", {
  skip_if_not_installed("ggplot2")
  p <- insper_scatterplot(mtcars, x = wt, y = mpg, fill = "lightblue", shape = 21)
  expect_s3_class(p, "ggplot")
  expect_no_error(ggplot2::ggplot_build(p))
})

test_that("insper_scatterplot both color and fill variable mappings", {
  skip_if_not_installed("ggplot2")
  p <- insper_scatterplot(mtcars,
                          x = wt, y = mpg,
                          color = factor(cyl),
                          fill = factor(gear),
                          shape = 21)
  expect_s3_class(p, "ggplot")

  # Check both scales are present
  built <- ggplot2::ggplot_build(p)
  expect_true(!is.null(p$scales$get_scales("colour")))
  expect_true(!is.null(p$scales$get_scales("fill")))
})

test_that("insper_scatterplot fill ignored for default shape", {
  skip_if_not_installed("ggplot2")
  # Shape 19 (default) doesn't support fill
  p <- insper_scatterplot(mtcars, x = wt, y = mpg, fill = "lightblue")
  expect_s3_class(p, "ggplot")
  expect_no_error(ggplot2::ggplot_build(p))
})

test_that("insper_scatterplot static color string works", {
  skip_if_not_installed("ggplot2")
  p <- insper_scatterplot(mtcars, x = wt, y = mpg, color = "#3CBFAE")
  expect_s3_class(p, "ggplot")
  expect_no_error(ggplot2::ggplot_build(p))
})

test_that("insper_scatterplot continuous color scale applied", {
  skip_if_not_installed("ggplot2")
  p <- insper_scatterplot(mtcars, x = wt, y = mpg, color = hp)
  expect_s3_class(p, "ggplot")

  # Check continuous color scale is present
  expect_true(!is.null(p$scales$get_scales("colour")))
})

test_that("insper_scatterplot continuous fill scale applied", {
  skip_if_not_installed("ggplot2")
  p <- insper_scatterplot(mtcars, x = wt, y = mpg, fill = hp, shape = 21)
  expect_s3_class(p, "ggplot")

  # Check continuous fill scale is present
  expect_true(!is.null(p$scales$get_scales("fill")))
})

test_that("insper_scatterplot color and fill both continuous", {
  skip_if_not_installed("ggplot2")
  p <- insper_scatterplot(mtcars,
                          x = wt, y = mpg,
                          color = hp,
                          fill = disp,
                          shape = 21)
  expect_s3_class(p, "ggplot")
  expect_no_error(ggplot2::ggplot_build(p))
})

test_that("insper_scatterplot default color when NULL", {
  skip_if_not_installed("ggplot2")
  p <- insper_scatterplot(mtcars, x = wt, y = mpg)
  expect_s3_class(p, "ggplot")

  # Should use default teals1 color
  built <- ggplot2::ggplot_build(p)
  expect_no_error(built)
})

test_that("insper_scatterplot palette parameter works with color", {
  skip_if_not_installed("ggplot2")
  p1 <- insper_scatterplot(mtcars, x = wt, y = mpg, color = factor(cyl), palette = "bright")
  p2 <- insper_scatterplot(mtcars, x = wt, y = mpg, color = factor(cyl), palette = "main")

  expect_s3_class(p1, "ggplot")
  expect_s3_class(p2, "ggplot")
})

test_that("insper_scatterplot palette parameter works with fill", {
  skip_if_not_installed("ggplot2")
  p <- insper_scatterplot(mtcars, x = wt, y = mpg, fill = factor(cyl), palette = "contrast", shape = 21)
  expect_s3_class(p, "ggplot")
})

test_that("insper_scatterplot warns when palette ignored", {
  skip_if_not_installed("ggplot2")
  # Palette should be ignored when both color and fill are static
  expect_warning(
    insper_scatterplot(mtcars, x = wt, y = mpg, color = "blue", fill = "red", palette = "bright", shape = 21),
    "palette.*ignored"
  )
})

test_that("insper_scatterplot point_size parameter works", {
  skip_if_not_installed("ggplot2")
  p1 <- insper_scatterplot(mtcars, x = wt, y = mpg, point_size = 4)
  p2 <- insper_scatterplot(mtcars, x = wt, y = mpg, point_size = 1)

  expect_s3_class(p1, "ggplot")
  expect_s3_class(p2, "ggplot")
})

test_that("insper_scatterplot point_alpha parameter works", {
  skip_if_not_installed("ggplot2")
  p1 <- insper_scatterplot(mtcars, x = wt, y = mpg, point_alpha = 0.5)
  p2 <- insper_scatterplot(mtcars, x = wt, y = mpg, point_alpha = 0.2)

  expect_s3_class(p1, "ggplot")
  expect_s3_class(p2, "ggplot")
})

test_that("insper_scatterplot shape 21-25 with color and fill", {
  skip_if_not_installed("ggplot2")
  # Test multiple fill-supporting shapes
  for (shp in c(21, 22, 23, 24, 25)) {
    p <- insper_scatterplot(mtcars,
                            x = wt, y = mpg,
                            color = "black",
                            fill = factor(cyl),
                            shape = shp)
    expect_s3_class(p, "ggplot")
  }
})

test_that("insper_scatterplot stroke parameter for outlined shapes", {
  skip_if_not_installed("ggplot2")
  p <- insper_scatterplot(mtcars, x = wt, y = mpg,
                          color = factor(cyl),
                          shape = 21,
                          stroke = 2)
  expect_s3_class(p, "ggplot")
  expect_no_error(ggplot2::ggplot_build(p))
})

test_that("insper_scatterplot discrete color with discrete fill", {
  skip_if_not_installed("ggplot2")
  p <- insper_scatterplot(mtcars,
                          x = wt, y = mpg,
                          color = factor(cyl),
                          fill = factor(gear),
                          shape = 21)
  expect_s3_class(p, "ggplot")

  # Both should have discrete scales
  expect_true(!is.null(p$scales$get_scales("colour")))
  expect_true(!is.null(p$scales$get_scales("fill")))
})

# Extended tests for insper_timeseries() ----

test_that("insper_timeseries validates data frame input", {
  skip_if_not_installed("ggplot2")
  expect_error(
    insper_timeseries("not a data frame", x = x, y = y),
    "data.*must be a data frame"
  )
  expect_error(
    insper_timeseries(list(x = 1:5, y = 1:5), x = x, y = y),
    "data.*must be a data frame"
  )
})

test_that("insper_timeseries static color string works", {
  skip_if_not_installed("ggplot2")
  df <- data.frame(time = 1:20, value = cumsum(rnorm(20)))
  p <- insper_timeseries(df, x = time, y = value, color = "#E4002B")
  expect_s3_class(p, "ggplot")
  expect_no_error(ggplot2::ggplot_build(p))
})

test_that("insper_timeseries default color when NULL", {
  skip_if_not_installed("ggplot2")
  df <- data.frame(time = 1:20, value = cumsum(rnorm(20)))
  p <- insper_timeseries(df, x = time, y = value)
  expect_s3_class(p, "ggplot")

  # Should use default teals1 color
  built <- ggplot2::ggplot_build(p)
  expect_no_error(built)
})

test_that("insper_timeseries discrete color scale applied", {
  skip_if_not_installed("ggplot2")
  df <- data.frame(
    time = rep(1:20, 3),
    value = c(cumsum(rnorm(20)), cumsum(rnorm(20)), cumsum(rnorm(20))),
    group = rep(c("A", "B", "C"), each = 20)
  )
  p <- insper_timeseries(df, x = time, y = value, color = group)
  expect_s3_class(p, "ggplot")

  # Check discrete color scale is present
  expect_true(!is.null(p$scales$get_scales("colour")))
})

test_that("insper_timeseries continuous color scale applied", {
  skip_if_not_installed("ggplot2")
  df <- data.frame(
    time = 1:100,
    value = cumsum(rnorm(100)),
    intensity = seq(0, 1, length.out = 100)
  )
  p <- insper_timeseries(df, x = time, y = value, color = intensity)
  expect_s3_class(p, "ggplot")

  # Check continuous color scale is present
  expect_true(!is.null(p$scales$get_scales("colour")))
})

test_that("insper_timeseries static color with add_points", {
  skip_if_not_installed("ggplot2")
  df <- data.frame(time = 1:20, value = cumsum(rnorm(20)))
  p <- insper_timeseries(df, x = time, y = value, color = "#009491", add_points = TRUE)
  expect_s3_class(p, "ggplot")

  # Check both line and point layers present
  has_line <- any(sapply(p$layers, function(l) inherits(l$geom, "GeomLine")))
  has_point <- any(sapply(p$layers, function(l) inherits(l$geom, "GeomPoint")))
  expect_true(has_line)
  expect_true(has_point)
})

test_that("insper_timeseries variable color with add_points", {
  skip_if_not_installed("ggplot2")
  df <- data.frame(
    time = rep(1:20, 2),
    value = c(cumsum(rnorm(20)), cumsum(rnorm(20))),
    group = rep(c("A", "B"), each = 20)
  )
  p <- insper_timeseries(df, x = time, y = value, color = group, add_points = TRUE)
  expect_s3_class(p, "ggplot")

  # Check both layers present
  has_line <- any(sapply(p$layers, function(l) inherits(l$geom, "GeomLine")))
  has_point <- any(sapply(p$layers, function(l) inherits(l$geom, "GeomPoint")))
  expect_true(has_line)
  expect_true(has_point)
})

test_that("insper_timeseries handles Date x-axis", {
  skip_if_not_installed("ggplot2")
  df <- data.frame(
    date = as.Date("2020-01-01") + 0:19,
    value = cumsum(rnorm(20))
  )
  p <- insper_timeseries(df, x = date, y = value)
  expect_s3_class(p, "ggplot")
  expect_no_error(ggplot2::ggplot_build(p))
})

test_that("insper_timeseries handles POSIXct x-axis", {
  skip_if_not_installed("ggplot2")
  df <- data.frame(
    datetime = as.POSIXct("2020-01-01 00:00:00") + (0:19) * 3600,
    value = cumsum(rnorm(20))
  )
  p <- insper_timeseries(df, x = datetime, y = value)
  expect_s3_class(p, "ggplot")
  expect_no_error(ggplot2::ggplot_build(p))
})

test_that("insper_timeseries handles numeric x-axis", {
  skip_if_not_installed("ggplot2")
  df <- data.frame(
    year = 2000:2019,
    value = cumsum(rnorm(20))
  )
  p <- insper_timeseries(df, x = year, y = value)
  expect_s3_class(p, "ggplot")
  expect_no_error(ggplot2::ggplot_build(p))
})

test_that("insper_timeseries palette parameter works", {
  skip_if_not_installed("ggplot2")
  df <- data.frame(
    time = rep(1:20, 3),
    value = c(cumsum(rnorm(20)), cumsum(rnorm(20)), cumsum(rnorm(20))),
    group = rep(c("A", "B", "C"), each = 20)
  )
  p1 <- insper_timeseries(df, x = time, y = value, color = group, palette = "bright")
  p2 <- insper_timeseries(df, x = time, y = value, color = group, palette = "contrast")

  expect_s3_class(p1, "ggplot")
  expect_s3_class(p2, "ggplot")
})

test_that("insper_timeseries warns when palette ignored", {
  skip_if_not_installed("ggplot2")
  df <- data.frame(time = 1:20, value = cumsum(rnorm(20)))

  # Palette should be ignored when color is static
  expect_warning(
    insper_timeseries(df, x = time, y = value, color = "blue", palette = "bright"),
    "palette.*ignored"
  )
})

test_that("insper_timeseries line_width parameter works", {
  skip_if_not_installed("ggplot2")
  df <- data.frame(time = 1:20, value = cumsum(rnorm(20)))
  p1 <- insper_timeseries(df, x = time, y = value, line_width = 1.5)
  p2 <- insper_timeseries(df, x = time, y = value, line_width = 0.5)

  expect_s3_class(p1, "ggplot")
  expect_s3_class(p2, "ggplot")
})

# Extended tests for insper_violin() ----

test_that("insper_violin validates data frame input", {
  skip_if_not_installed("ggplot2")
  expect_error(
    insper_violin("not a data frame", x = x, y = y),
    "data.*must be a data frame"
  )
  expect_error(
    insper_violin(list(x = c("A", "B"), y = c(1, 2)), x = x, y = y),
    "data.*must be a data frame"
  )
})

test_that("insper_violin static fill color works", {
  skip_if_not_installed("ggplot2")
  p <- insper_violin(iris, x = Species, y = Sepal.Length, fill = "#E4002B")
  expect_s3_class(p, "ggplot")
  expect_no_error(ggplot2::ggplot_build(p))
})

test_that("insper_violin default fill when NULL", {
  skip_if_not_installed("ggplot2")
  p <- insper_violin(iris, x = Species, y = Sepal.Length)
  expect_s3_class(p, "ggplot")

  # Should use default teals2 color
  built <- ggplot2::ggplot_build(p)
  expect_no_error(built)
})

test_that("insper_violin variable fill mapping", {
  skip_if_not_installed("ggplot2")
  p <- insper_violin(iris, x = Species, y = Sepal.Length, fill = Species)
  expect_s3_class(p, "ggplot")

  # Check discrete fill scale is present
  expect_true(!is.null(p$scales$get_scales("fill")))
})

test_that("insper_violin show_boxplot parameter works", {
  skip_if_not_installed("ggplot2")
  p_with <- insper_violin(iris, x = Species, y = Sepal.Length, show_boxplot = TRUE)
  p_without <- insper_violin(iris, x = Species, y = Sepal.Length, show_boxplot = FALSE)

  expect_s3_class(p_with, "ggplot")
  expect_s3_class(p_without, "ggplot")

  # Check boxplot layer is present in p_with
  has_boxplot <- any(sapply(p_with$layers, function(l) inherits(l$geom, "GeomBoxplot")))
  expect_true(has_boxplot)
})

test_that("insper_violin show_points parameter works", {
  skip_if_not_installed("ggplot2")
  p_with <- insper_violin(iris, x = Species, y = Sepal.Length, show_points = TRUE)
  p_without <- insper_violin(iris, x = Species, y = Sepal.Length, show_points = FALSE)

  expect_s3_class(p_with, "ggplot")
  expect_s3_class(p_without, "ggplot")

  # Check jitter layer is present in p_with
  has_jitter <- any(sapply(p_with$layers, function(l) inherits(l$geom, "GeomPoint")))
  expect_true(has_jitter)
})

test_that("insper_violin show_boxplot and show_points together", {
  skip_if_not_installed("ggplot2")
  p <- insper_violin(iris, x = Species, y = Sepal.Length,
                     show_boxplot = TRUE, show_points = TRUE)
  expect_s3_class(p, "ggplot")

  # Check both layers present
  has_boxplot <- any(sapply(p$layers, function(l) inherits(l$geom, "GeomBoxplot")))
  has_points <- any(sapply(p$layers, function(l) inherits(l$geom, "GeomPoint")))
  expect_true(has_boxplot)
  expect_true(has_points)
})

test_that("insper_violin violin_alpha parameter works", {
  skip_if_not_installed("ggplot2")
  p1 <- insper_violin(iris, x = Species, y = Sepal.Length, violin_alpha = 0.3)
  p2 <- insper_violin(iris, x = Species, y = Sepal.Length, violin_alpha = 0.9)

  expect_s3_class(p1, "ggplot")
  expect_s3_class(p2, "ggplot")
})

test_that("insper_violin palette parameter works", {
  skip_if_not_installed("ggplot2")
  p1 <- insper_violin(iris, x = Species, y = Sepal.Length, fill = Species, palette = "bright")
  p2 <- insper_violin(iris, x = Species, y = Sepal.Length, fill = Species, palette = "contrast")

  expect_s3_class(p1, "ggplot")
  expect_s3_class(p2, "ggplot")
})

test_that("insper_violin warns when palette ignored", {
  skip_if_not_installed("ggplot2")
  # Palette should be ignored when fill is static
  expect_warning(
    insper_violin(iris, x = Species, y = Sepal.Length, fill = "purple", palette = "bright"),
    "palette.*ignored"
  )
})

# Extended tests for insper_heatmap() ----

test_that("insper_heatmap validates input types", {
  skip_if_not_installed("ggplot2")
  expect_error(
    insper_heatmap("not a data frame or matrix"),
    "data.*must be a data frame or matrix"
  )
  expect_error(
    insper_heatmap(list(a = 1:5, b = 1:5)),
    "data.*must be a data frame or matrix"
  )
})

test_that("insper_heatmap accepts melted data frame", {
  skip_if_not_installed("ggplot2")
  melted_df <- data.frame(
    Var1 = rep(c("A", "B", "C"), each = 3),
    Var2 = rep(c("X", "Y", "Z"), 3),
    value = rnorm(9)
  )
  p <- insper_heatmap(melted_df)
  expect_s3_class(p, "ggplot")
  expect_no_error(ggplot2::ggplot_build(p))
})

test_that("insper_heatmap accepts matrix input", {
  skip_if_not_installed("ggplot2")
  mat <- matrix(rnorm(12), nrow = 3, ncol = 4)
  p <- insper_heatmap(mat)
  expect_s3_class(p, "ggplot")
  expect_no_error(ggplot2::ggplot_build(p))
})

test_that("insper_heatmap errors on non-numeric data frame", {
  skip_if_not_installed("ggplot2")
  df <- data.frame(
    a = c("x", "y", "z"),
    b = c(1, 2, 3)
  )
  expect_error(
    insper_heatmap(df),
    "must contain only numeric columns"
  )
})

test_that("insper_heatmap handles matrix without names", {
  skip_if_not_installed("ggplot2")
  mat <- matrix(rnorm(12), nrow = 3, ncol = 4)
  # No rownames or colnames
  p <- insper_heatmap(mat)
  expect_s3_class(p, "ggplot")
  expect_no_error(ggplot2::ggplot_build(p))
})

test_that("insper_heatmap handles matrix with custom names", {
  skip_if_not_installed("ggplot2")
  mat <- cor(mtcars[, 1:4])
  # Already has rownames/colnames from cor()
  p <- insper_heatmap(mat)
  expect_s3_class(p, "ggplot")
  expect_no_error(ggplot2::ggplot_build(p))
})

test_that("insper_heatmap value_color parameter works", {
  skip_if_not_installed("ggplot2")
  mat <- cor(mtcars[, 1:4])
  p1 <- insper_heatmap(mat, show_values = TRUE, value_color = "white")
  p2 <- insper_heatmap(mat, show_values = TRUE, value_color = "black")

  expect_s3_class(p1, "ggplot")
  expect_s3_class(p2, "ggplot")
})

test_that("insper_heatmap value_size parameter works", {
  skip_if_not_installed("ggplot2")
  mat <- cor(mtcars[, 1:4])
  p1 <- insper_heatmap(mat, show_values = TRUE, value_size = 2)
  p2 <- insper_heatmap(mat, show_values = TRUE, value_size = 4)

  expect_s3_class(p1, "ggplot")
  expect_s3_class(p2, "ggplot")
})

test_that("insper_heatmap palette parameter works", {
  skip_if_not_installed("ggplot2")
  mat <- cor(mtcars[, 1:4])
  p1 <- insper_heatmap(mat, palette = "diverging")
  p2 <- insper_heatmap(mat, palette = "red_teal")

  expect_s3_class(p1, "ggplot")
  expect_s3_class(p2, "ggplot")
})

test_that("insper_heatmap continuous scale applied", {
  skip_if_not_installed("ggplot2")
  mat <- cor(mtcars[, 1:4])
  p <- insper_heatmap(mat)
  expect_s3_class(p, "ggplot")

  # Check continuous fill scale is present
  expect_true(!is.null(p$scales$get_scales("fill")))
})

test_that("insper_heatmap handles NA values in matrix", {
  skip_if_not_installed("ggplot2")
  mat <- matrix(c(1, 2, NA, 4, 5, 6, 7, 8, 9), nrow = 3)
  p <- insper_heatmap(mat)
  expect_s3_class(p, "ggplot")
  expect_no_error(ggplot2::ggplot_build(p))
})

test_that("insper_heatmap show_values displays text layer", {
  skip_if_not_installed("ggplot2")
  mat <- cor(mtcars[, 1:4])
  p_with <- insper_heatmap(mat, show_values = TRUE)
  p_without <- insper_heatmap(mat, show_values = FALSE)

  expect_s3_class(p_with, "ggplot")
  expect_s3_class(p_without, "ggplot")

  # Check text layer is present in p_with
  has_text <- any(sapply(p_with$layers, function(l) inherits(l$geom, "GeomText")))
  expect_true(has_text)
})

# Extended tests for insper_area() ----

test_that("insper_area validates data frame input", {
  skip_if_not_installed("ggplot2")
  expect_error(
    insper_area("not a data frame", x = x, y = y),
    "data.*must be a data frame"
  )
})

test_that("insper_area static fill with line overlay", {
  skip_if_not_installed("ggplot2")
  df <- data.frame(time = 1:20, value = cumsum(rnorm(20)))
  p <- insper_area(df, x = time, y = value, fill = "#E4002B", add_line = TRUE)
  expect_s3_class(p, "ggplot")

  # Check both area and line layers
  has_area <- any(sapply(p$layers, function(l) inherits(l$geom, "GeomArea")))
  has_line <- any(sapply(p$layers, function(l) inherits(l$geom, "GeomLine")))
  expect_true(has_area)
  expect_true(has_line)
})

test_that("insper_area continuous fill scale applied", {
  skip_if_not_installed("ggplot2")
  df <- data.frame(
    time = 1:100,
    value = cumsum(rnorm(100)),
    intensity = seq(0, 1, length.out = 100)
  )
  p <- insper_area(df, x = time, y = value, fill = intensity)
  expect_s3_class(p, "ggplot")

  # Check continuous fill scale is present
  expect_true(!is.null(p$scales$get_scales("fill")))
})

test_that("insper_area warns when palette ignored", {
  skip_if_not_installed("ggplot2")
  df <- data.frame(time = 1:20, value = cumsum(rnorm(20)))

  # Palette should be ignored when fill is static
  expect_warning(
    insper_area(df, x = time, y = value, fill = "#009491", palette = "bright"),
    "palette.*ignored"
  )
})

test_that("insper_area line_width parameter works", {
  skip_if_not_installed("ggplot2")
  df <- data.frame(time = 1:20, value = cumsum(rnorm(20)))
  p1 <- insper_area(df, x = time, y = value, line_width = 1.5)
  p2 <- insper_area(df, x = time, y = value, line_width = 0.3)

  expect_s3_class(p1, "ggplot")
  expect_s3_class(p2, "ggplot")
})

test_that("insper_area line_alpha parameter works", {
  skip_if_not_installed("ggplot2")
  df <- data.frame(time = 1:20, value = cumsum(rnorm(20)))
  p1 <- insper_area(df, x = time, y = value, line_alpha = 0.5)
  p2 <- insper_area(df, x = time, y = value, line_alpha = 1)

  expect_s3_class(p1, "ggplot")
  expect_s3_class(p2, "ggplot")
})

test_that("insper_area add_line parameter works", {
  skip_if_not_installed("ggplot2")
  df <- data.frame(time = 1:20, value = cumsum(rnorm(20)))
  p_with <- insper_area(df, x = time, y = value, add_line = TRUE)
  p_without <- insper_area(df, x = time, y = value, add_line = FALSE)

  expect_s3_class(p_with, "ggplot")
  expect_s3_class(p_without, "ggplot")

  # Check line is present only in p_with
  has_line_with <- any(sapply(p_with$layers, function(l) inherits(l$geom, "GeomLine")))
  has_line_without <- any(sapply(p_without$layers, function(l) inherits(l$geom, "GeomLine")))
  expect_true(has_line_with)
  expect_false(has_line_without)
})

test_that("insper_area zero parameter adds horizontal line", {
  skip_if_not_installed("ggplot2")
  df <- data.frame(time = 1:20, value = c(-5:-1, 0, 1:14))
  p <- insper_area(df, x = time, y = value, zero = TRUE)
  expect_s3_class(p, "ggplot")

  # Check hline is present
  has_hline <- any(sapply(p$layers, function(l) inherits(l$geom, "GeomHline")))
  expect_true(has_hline)
})

test_that("insper_area area_alpha parameter works", {
  skip_if_not_installed("ggplot2")
  df <- data.frame(time = 1:20, value = cumsum(rnorm(20)))
  p1 <- insper_area(df, x = time, y = value, area_alpha = 0.3)
  p2 <- insper_area(df, x = time, y = value, area_alpha = 1)

  expect_s3_class(p1, "ggplot")
  expect_s3_class(p2, "ggplot")
})

# Extended tests for insper_boxplot() ----

test_that("insper_boxplot validates data frame input", {
  skip_if_not_installed("ggplot2")
  expect_error(
    insper_boxplot("not a data frame", x = x, y = y),
    "data.*must be a data frame"
  )
})

test_that("insper_boxplot auto-jitter with small groups", {
  skip_if_not_installed("ggplot2")
  # Small dataset - jitter should be auto-enabled
  p <- insper_boxplot(iris, x = Species, y = Sepal.Length)
  expect_s3_class(p, "ggplot")

  # Check jitter layer is present (auto-enabled for small groups)
  has_jitter <- any(sapply(p$layers, function(l) inherits(l$geom, "GeomPoint")))
  expect_true(has_jitter)
})

test_that("insper_boxplot auto-jitter with large groups", {
  skip_if_not_installed("ggplot2")
  # Create large dataset (>100 per group)
  large_df <- data.frame(
    group = rep(c("A", "B"), each = 150),
    value = rnorm(300)
  )
  p <- insper_boxplot(large_df, x = group, y = value)
  expect_s3_class(p, "ggplot")

  # Jitter should NOT be auto-enabled for large groups
  has_jitter <- any(sapply(p$layers, function(l) inherits(l$geom, "GeomPoint")))
  expect_false(has_jitter)
})

test_that("insper_boxplot add_jitter override works", {
  skip_if_not_installed("ggplot2")
  # Force jitter on large dataset
  large_df <- data.frame(
    group = rep(c("A", "B"), each = 150),
    value = rnorm(300)
  )
  p <- insper_boxplot(large_df, x = group, y = value, add_jitter = TRUE)
  expect_s3_class(p, "ggplot")

  # Jitter should be present because explicitly requested
  has_jitter <- any(sapply(p$layers, function(l) inherits(l$geom, "GeomPoint")))
  expect_true(has_jitter)
})

test_that("insper_boxplot add_notch parameter works", {
  skip_if_not_installed("ggplot2")
  p <- insper_boxplot(iris, x = Species, y = Sepal.Length, add_notch = TRUE)
  expect_s3_class(p, "ggplot")
  expect_no_error(ggplot2::ggplot_build(p))
})

test_that("insper_boxplot box_alpha parameter works", {
  skip_if_not_installed("ggplot2")
  p1 <- insper_boxplot(iris, x = Species, y = Sepal.Length, box_alpha = 0.3)
  p2 <- insper_boxplot(iris, x = Species, y = Sepal.Length, box_alpha = 1)

  expect_s3_class(p1, "ggplot")
  expect_s3_class(p2, "ggplot")
})

test_that("insper_boxplot palette parameter works", {
  skip_if_not_installed("ggplot2")
  p1 <- insper_boxplot(iris, x = Species, y = Sepal.Length, fill = Species, palette = "bright")
  p2 <- insper_boxplot(iris, x = Species, y = Sepal.Length, fill = Species, palette = "contrast")

  expect_s3_class(p1, "ggplot")
  expect_s3_class(p2, "ggplot")
})

test_that("insper_boxplot warns when palette ignored", {
  skip_if_not_installed("ggplot2")
  # Palette should be ignored when fill is static
  expect_warning(
    insper_boxplot(iris, x = Species, y = Sepal.Length, fill = "lightblue", palette = "bright"),
    "palette.*ignored"
  )
})

test_that("insper_boxplot static fill matches expected color", {
  skip_if_not_installed("ggplot2")
  p <- insper_boxplot(iris, x = Species, y = Sepal.Length, fill = "#F15A22")
  expect_s3_class(p, "ggplot")
  expect_no_error(ggplot2::ggplot_build(p))
})

test_that("insper_boxplot variable fill mapping", {
  skip_if_not_installed("ggplot2")
  p <- insper_boxplot(iris, x = Species, y = Sepal.Length, fill = Species)
  expect_s3_class(p, "ggplot")

  # Check discrete fill scale is present
  expect_true(!is.null(p$scales$get_scales("fill")))
})

test_that("insper_boxplot default fill when NULL", {
  skip_if_not_installed("ggplot2")
  p <- insper_boxplot(iris, x = Species, y = Sepal.Length)
  expect_s3_class(p, "ggplot")

  # Should use default teals2 color
  built <- ggplot2::ggplot_build(p)
  expect_no_error(built)
})
