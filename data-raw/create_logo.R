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
  x = letters[1:3],
  y = c(3, 5, 2)
)

# Scatter plot data
scatter_data <- data.frame(
  x = rnorm(20),
  y = rnorm(20) * 2 + 5 + rnorm(20, sd = 2)
)

# Build subplots ----------------------------------------------------------

p_scatter <- ggplot(scatter_data, aes(x, y)) +
  geom_point(color = "white", size = 0.1) +
  geom_smooth(se = FALSE, color = "white", linewidth = 0.5) +
  theme_subplot()

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

# Combine subplots --------------------------------------------------------

subplot <- (p_bar | p_scatter) / p_line &
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
  p_size = 7,
  p_color = "black",
  p_x = 1,
  p_y = 0.465,
  p_family = "garamond",
  # Subplot positioning
  s_x = 1,
  s_y = 1.15,
  s_width = 1.5,
  s_height = 1.5 / 1.1,
  # Hex styling
  h_fill = insper_red,
  h_color = insper_teal,
  h_size = 1.5,
  # Output
  filename = "man/figures/logo.png",
  dpi = 300,
  white_around_sticker = FALSE
)

cli_alert_success("Logo created: {.file man/figures/logo.png}")

# Create small version for README -----------------------------------------

if (file.exists("man/figures/logo.png")) {
  if (require("magick", quietly = TRUE)) {
    logo <- magick::image_read("man/figures/logo.png")
    logo_small <- magick::image_scale(logo, "240x278")
    magick::image_write(logo_small, "man/figures/logo-small.png")
    cli_alert_success("Small logo created: {.file man/figures/logo-small.png}")
  } else {
    cli_alert_warning("Install {.pkg magick} to generate small logo version")
    cli_alert_info("Run: {.code install.packages('magick')}")
  }
}

# Usage instructions ------------------------------------------------------

cli_rule("Usage")
cli_bullets(c(
  "i" = "Add to README: {.code <img src=\"man/figures/logo.png\" align=\"right\" height=\"139\" />}",
  "i" = "Rebuild site: {.code pkgdown::build_site()}"
))

cli_rule("Customization")
cli_bullets(c(
  "*" = "Colors: Adjust {.code insper_red}, {.code insper_teal}",
  "*" = "Text: Modify {.code p_size}, {.code p_x}, {.code p_y}",
  "*" = "Subplot: Change {.code s_x}, {.code s_y}, {.code s_width}, {.code s_height}",
  "*" = "Border: Update {.code h_color}, {.code h_size}"
))
