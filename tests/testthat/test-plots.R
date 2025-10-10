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
  expect_no_error(insper_barplot(df, x = x, y = y, group = grp, position = "dodge"))
  expect_no_error(insper_barplot(df, x = x, y = y, group = grp, position = "stack"))
  expect_error(insper_barplot(df, x = x, y = y, group = grp, position = "invalid"))
})

test_that("insper_barplot handles grouped bars", {
  skip_if_not_installed("ggplot2")
  df <- data.frame(
    x = rep(c("A", "B"), each = 2),
    y = c(1, 2, 3, 4),
    grp = rep(c("X", "Y"), 2)
  )
  p <- insper_barplot(df, x = x, y = y, group = grp)
  expect_s3_class(p, "ggplot")
})

test_that("insper_barplot flip parameter works", {
  skip_if_not_installed("ggplot2")
  df <- data.frame(x = c("A", "B"), y = c(1, 2))
  p <- insper_barplot(df, x = x, y = y, flip = TRUE)
  expect_s3_class(p, "ggplot")
  expect_s3_class(p$coordinates, "CoordFlip")
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

test_that("insper_timeseries handles group aesthetic", {
  skip_if_not_installed("ggplot2")
  df <- data.frame(
    time = rep(1:10, 2),
    value = rnorm(20),
    group = rep(c("A", "B"), each = 10)
  )
  p <- insper_timeseries(df, x = time, y = value, group = group)
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

test_that("plot functions accept title/subtitle/caption", {
  skip_if_not_installed("ggplot2")

  p1 <- insper_scatterplot(
    mtcars, x = wt, y = mpg,
    title = "Test Title",
    subtitle = "Test Subtitle",
    caption = "Test Caption"
  )
  expect_s3_class(p1, "ggplot")

  p2 <- insper_timeseries(
    data.frame(time = 1:10, value = rnorm(10)),
    x = time, y = value,
    title = "Test"
  )
  expect_s3_class(p2, "ggplot")

  p3 <- insper_boxplot(
    mtcars, x = factor(cyl), y = mpg,
    caption = "Test"
  )
  expect_s3_class(p3, "ggplot")
})
