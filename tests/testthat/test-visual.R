# Visual Regression Tests using vdiffr
# These tests capture visual snapshots of plots to detect unintended changes

# Skip tests if vdiffr is not available
skip_if_not_installed("vdiffr")

# Skip all visual tests if Insper fonts are not available
# Visual tests require fonts for consistent rendering across systems
skip_if_no_fonts()

library(ggplot2)

# Test data
test_df <- data.frame(
  category = c("A", "B", "C", "D"),
  value = c(10, 25, 15, 30),
  group = rep(c("X", "Y"), 2)
)

# Theme Tests -----------------------------------------------------------------

test_that("theme_insper renders correctly with default settings", {
  p <- ggplot(mtcars, aes(x = wt, y = mpg)) +
    geom_point() +
    labs(title = "Test Plot", subtitle = "Subtitle text") +
    theme_insper()

  vdiffr::expect_doppelganger("theme_insper_default", p)
})

test_that("theme_insper renders without grid", {
  p <- ggplot(mtcars, aes(x = wt, y = mpg)) +
    geom_point() +
    labs(title = "No Grid") +
    theme_insper(grid = FALSE)

  vdiffr::expect_doppelganger("theme_insper_no_grid", p)
})

test_that("theme_insper renders with half border", {
  p <- ggplot(mtcars, aes(x = wt, y = mpg)) +
    geom_point() +
    labs(title = "Half Border") +
    theme_insper(border = "half")

  vdiffr::expect_doppelganger("theme_insper_half_border", p)
})

test_that("theme_insper renders with closed border", {
  p <- ggplot(mtcars, aes(x = wt, y = mpg)) +
    geom_point() +
    labs(title = "Closed Border") +
    theme_insper(border = "closed")

  vdiffr::expect_doppelganger("theme_insper_closed_border", p)
})

test_that("theme_insper renders with different align settings", {
  p_panel <- ggplot(mtcars, aes(x = wt, y = mpg)) +
    geom_point() +
    labs(title = "Panel Align", caption = "Caption") +
    theme_insper(align = "panel")

  p_plot <- ggplot(mtcars, aes(x = wt, y = mpg)) +
    geom_point() +
    labs(title = "Plot Align", caption = "Caption") +
    theme_insper(align = "plot")

  vdiffr::expect_doppelganger("theme_insper_align_panel", p_panel)
  vdiffr::expect_doppelganger("theme_insper_align_plot", p_plot)
})

# Plot Function Tests ---------------------------------------------------------

test_that("insper_barplot vertical bars render correctly", {
  p <- insper_barplot(test_df, x = category, y = value)
  vdiffr::expect_doppelganger("barplot_vertical", p)
})

test_that("insper_barplot horizontal bars render correctly", {
  p <- insper_barplot(test_df, x = value, y = category)
  vdiffr::expect_doppelganger("barplot_horizontal", p)
})

test_that("insper_barplot with text labels renders correctly", {
  p <- insper_barplot(test_df, x = category, y = value, text = TRUE)
  vdiffr::expect_doppelganger("barplot_with_text", p)
})

test_that("insper_barplot with grouped bars renders correctly", {
  p <- insper_barplot(test_df, x = category, y = value, fill_var = group)
  vdiffr::expect_doppelganger("barplot_grouped", p)
})

test_that("insper_scatterplot renders correctly", {
  p <- insper_scatterplot(mtcars, x = wt, y = mpg)
  vdiffr::expect_doppelganger("scatterplot_basic", p)
})

test_that("insper_scatterplot with color aesthetic renders correctly", {
  p <- insper_scatterplot(mtcars, x = wt, y = mpg, color = factor(cyl))
  vdiffr::expect_doppelganger("scatterplot_colored", p)
})

test_that("insper_timeseries renders correctly", {
  ts_data <- data.frame(time = 1:20, value = cumsum(rnorm(20)))
  p <- insper_timeseries(ts_data, x = time, y = value)
  vdiffr::expect_doppelganger("timeseries_basic", p)
})

test_that("insper_timeseries with groups renders correctly", {
  ts_data <- data.frame(
    time = rep(1:20, 2),
    value = cumsum(rnorm(40)),
    group = rep(c("A", "B"), each = 20)
  )
  p <- insper_timeseries(ts_data, x = time, y = value, group = group)
  vdiffr::expect_doppelganger("timeseries_grouped", p)
})

test_that("insper_boxplot renders correctly", {
  p <- insper_boxplot(mtcars, x = factor(cyl), y = mpg)
  vdiffr::expect_doppelganger("boxplot_basic", p)
})

test_that("insper_area renders correctly", {
  area_data <- data.frame(time = 1:20, value = cumsum(rnorm(20)))
  p <- insper_area(area_data, x = time, y = value)
  vdiffr::expect_doppelganger("area_basic", p)
})

test_that("insper_violin renders correctly", {
  p <- insper_violin(mtcars, x = factor(cyl), y = mpg)
  vdiffr::expect_doppelganger("violin_basic", p)
})

test_that("insper_heatmap renders correctly", {
  cor_mat <- cor(mtcars[, 1:4])
  p <- insper_heatmap(cor_mat)
  vdiffr::expect_doppelganger("heatmap_basic", p)
})

# Theme Variant Tests ---------------------------------------------------------

test_that("theme_insper_minimal renders correctly", {
  p <- ggplot(mtcars, aes(x = wt, y = mpg)) +
    geom_point() +
    labs(title = "Minimal Theme") +
    theme_insper_minimal()

  vdiffr::expect_doppelganger("theme_minimal", p)
})

test_that("theme_insper_presentation renders correctly", {
  p <- ggplot(mtcars, aes(x = wt, y = mpg)) +
    geom_point(size = 3) +
    labs(title = "Presentation Theme") +
    theme_insper_presentation()

  vdiffr::expect_doppelganger("theme_presentation", p)
})

test_that("theme_insper_print renders correctly", {
  p <- ggplot(mtcars, aes(x = wt, y = mpg)) +
    geom_point() +
    labs(title = "Print Theme") +
    theme_insper_print()

  vdiffr::expect_doppelganger("theme_print", p)
})
