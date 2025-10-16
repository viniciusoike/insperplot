## ============================================================================
## insperplot Hex Logo Generator
## ============================================================================
## Run this script to generate the package hex sticker logo

# Load required packages --------------------------------------------------

library(hexSticker)
library(ggplot2)
library(patchwork)
library(cli)

# Configure fonts ---------------------------------------------------------

library(showtext)
font_add_google("EB Garamond", "garamond")
showtext_opts(dpi = 300)
showtext_auto()

# Define colors -----------------------------------------------------------

insper_red <- "#E4002B"
insper_teal <- "#009491"
insper_orange <- "#F15A22"

# Helper: common theme for subplots ---------------------------------------

theme_subplot <- function() {
  theme_minimal() +
    theme(
      axis.title = element_blank(),
      axis.text = element_blank(),
      panel.grid = element_blank(),
      panel.background = element_rect(fill = "transparent", color = NA),
      plot.background = element_rect(fill = "transparent", color = NA),
      plot.margin = margin(5, 5, 5, 5)
    )
}

# Create subplot data -----------------------------------------------------

set.seed(1992)

# Line plot data
line_data <- data.frame(
  x = seq(0, 10, length.out = 100),
  y = sin(seq(0, 2 * pi, length.out = 100))
)

# Bar plot data
bar_data <- data.frame(
  x = letters[1:5],
  y = c(3, 5, 4, 2, 3.5)
)

# Scatter plot data
scatter_data <- tibble::tibble(
  x = rnorm(25),
  y = x * 2 + 5 + rnorm(25, sd = 2)
)

spo <- geobr::read_municipality(3550308)

lollipop_data <- data.frame(
  x = c(3.5, 2.5),
  y = c(1.8, 1.1),
  z = c(1.1, 2.5),
  a = c(1.5, 2.5)
)

p_lolli <- lollipop_data |>
  tidyr::pivot_longer(cols = everything()) |>
  ggplot(aes(value, name)) +
  geom_line(aes(group = name), lwd = 0.5, color = "white") +
  geom_point(size = 0.75, color = "white") +
  geom_vline(xintercept = 2, lwd = 0.25, linetype = "dashed", color = "white") +
  scale_x_continuous(limits = c(0.9, 3.7)) +
  theme_subplot()
# theme(
#   panel.background = element_rect(fill = insper_red, color = "white"),
#   plot.background = element_rect(fill = insper_red, color = "white")
# )

# Build subplots ----------------------------------------------------------
p_map <- ggplot(spo) +
  geom_sf(fill = "white", color = "white") +
  theme_subplot()

p_scatter <- ggplot(scatter_data, aes(x, y)) +
  geom_point(
    shape = 21,
    color = "white",
    size = sample(c(0.1, 0.2, 0.55, 1.1), size = 25, replace = TRUE)
  ) +
  # geom_smooth(se = FALSE, color = "white", linewidth = 0.5) +
  theme_subplot() +
  theme(
    plot.margin = margin(10, 10, 10, 10),
    plot.background = element_rect(fill = "transparent", color = "white"),
    panel.background = element_rect(fill = "transparent", color = "white")
  )


# p_scatter <- ggplot(scatter_data, aes(x, y)) +
#   geom_point(color = "white", size = 0.1) +
#   geom_smooth(se = FALSE, color = "white", linewidth = 0.5) +
#   theme_subplot()

p_bar <- ggplot(bar_data, aes(x, y)) +
  geom_col(fill = "white", width = 0.7) +
  theme_subplot()

p_line <- ggplot(line_data, aes(x, y)) +
  geom_line(color = "white", linewidth = 1, lineend = "round") +
  geom_point(
    data = line_data[c(1, 26, 100), ],
    color = "white",
    size = 2
  ) +
  scale_y_continuous(limits = c(-1.15, 1.15)) +
  theme_subplot() +
  theme(plot.margin = margin(0, 0, 0, 0))


p_scatter +
  theme(
    plot.margin = margin(0, 0, 0, 0),
    plot.background = element_rect(fill = insper_red, color = insper_red),
    panel.background = element_rect(fill = insper_red, color = insper_red)
  )

# Combine subplots --------------------------------------------------------

subplot <- (p_bar | p_lolli) /
  p_line &
  theme(
    plot.background = element_rect(fill = "transparent", color = NA),
    panel.background = element_rect(fill = "transparent", color = NA)
  )

# Create output directory -------------------------------------------------

if (!dir.exists("man/figures")) {
  dir.create("man/figures", recursive = TRUE)
}

# Generate hex sticker ----------------------------------------------------

cli_alert_info("Generating hex logo...")

sticker(
  subplot = subplot,
  # Package name
  package = "insperplot",
  p_size = 5,
  p_color = "black",
  p_x = 1,
  p_y = 1.6,
  p_family = "garamond",
  # Subplot positioning
  s_x = 1,
  s_y = 0.865,
  s_width = 1.75,
  s_height = 1.55 / 1.1,
  # Hex styling
  h_fill = insper_red,
  h_color = "black",
  h_size = 0.85,
  # Output
  filename = "man/figures/logo.png",
  dpi = 300,
  white_around_sticker = FALSE
)

cli_alert_success("Logo created: {.file man/figures/logo.png}")
