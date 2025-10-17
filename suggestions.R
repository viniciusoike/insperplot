library(ggplot2)
library(dplyr)
library(insperplot)

insper_timeseries(economics, date, unemploy) +
  theme(panel.grid.major.x = element_blank())

insper_barplot(mtcars, x = cyl, y = mpg)

insperplot::rec_passengers

sub_passengers <- rec_passengers |>
  filter(date >= as.Date("2024-01-01"), date <= as.Date("2024-12-31")) |>
  mutate(
    mes = lubridate::month(date, label = TRUE, abbr = TRUE, locale = "pt_BR"),
    doy = lubridate::day(date)
  )

month_total <- sub_passengers |>
  summarise(
    total_month = sum(passengers, na.rm = TRUE),
    .by = mes
  )

insper_barplot(month_total, mes, total_month / 1e6)

main_lines <- sub_passengers |>
  count(code_line, sort = TRUE, wt = passengers) |>
  slice(1:5) |>
  pull(code_line)

sub_mainlines <- subset(sub_passengers, code_line %in% main_lines)

# Looks too messy
insper_boxplot(
  sub_mainlines,
  x = code_line,
  y = passengers
)

# Default should be FALSE
# Maybe choose TRUE only if less than 100 obs per group
# but allow user to override if they want
insper_boxplot(
  sub_mainlines,
  x = code_line,
  y = passengers,
  add_jitter = FALSE
)

# Default should be FALSE
insper_violin(
  sub_mainlines,
  x = code_line,
  y = passengers,
  show_boxplot = FALSE
)

# Add smooht should be false
insper_scatterplot(
  mtcars,
  x = wt,
  y = mpg,
  add_smooth = FALSE
)

insper_scatterplot(
  mtcars,
  x = wt,
  y = mpg,
  add_smooth = TRUE,
  smooth_method = "gam"
)

# Default should be point_alpha = 1
# Also, not sure what the default size of geom_point is, but we should
# not change it. No reason for changing the default ggplot2 value.
insper_scatterplot(
  mtcars,
  x = wt,
  y = mpg,
  add_smooth = TRUE,
  smooth_method = "loess",
  point_alpha = 1,
)

# We need a ... argument
insper_scatterplot(
  mtcars,
  x = wt,
  y = mpg,
  color = as.factor(cyl),
  add_smooth = TRUE,
  smooth_method = "loess",
  point_size = 1
  # User might want different shapes
  # shape = 21
)

# Also, shape = 21, has both color and fill arguments
# How should we handle this?
# insper_scatterplot(
#   mtcars,
#   x = wt,
#   y = mpg,
#   color = "white",
#   fill = as.factor(cyl),
#   add_smooth = TRUE,
#   smooth_method = "loess",
#   point_size = 1,
#   shape = 21
# )

# The name of this function is unintuitive
# I thought it was a generic function for geom_col()
insper_col()

# Does this function work for other types of heatmaps?
# Seems like a function for correlation heatmaps
insper_heatmap(cor(mtcars[, 1:4]))

# For instance
agg_heatmap <- sub_mainlines |>
  summarise(
    total_month = sum(passengers, na.rm = TRUE),
    .by = c(mes, code_line)
  )

ggplot(agg_heatmap, aes(mes, code_line, fill = total_month)) +
  geom_tile() +
  scale_fill_gradient(low = "white", high = "black")

# This code fails because of scale_fill_insper()
# We should have scale_fill_insper_c() that
# interpolates color by default
# ggplot(agg_heatmap, aes(mes, code_line, fill = total_month)) +
#   geom_tile() +
#   scale_fill_insper()

# We are lacking a histogram plot function

# Something like this
# We should improve on bin selection
# Since this is an academic package we should implement the 'more formal'
# bins selection methods like Sturges, FD, and Scott
# bin_selection = c("sturges", "fd", "scott", "manual")
ggplot(sub_mainlines, aes(passengers)) +
  geom_histogram(
    color = "white",
    fill = insper_col("reds1"),
    bins = nclass.Sturges(sub_mainlines$passengers)
  ) +
  geom_hline(yintercept = 0) +
  scale_y_continuous(expand = expansion(c(0, 0.05))) +
  theme_insper()

# We shoudl also have density plot function
