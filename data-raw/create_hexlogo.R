library(hexSticker)
library(ggplot2)
library(patchwork)

library(showtext)
font_add_google("EB Garamond", "garamond")
showtext_opts(dpi = 300)
showtext_auto()

insper_red <- "#E4002B"
insper_teal <- "#009491"
insper_orange <- "#F15A22"

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

# Bar plot data
bar_data <- data.frame(
  x = letters[1:5],
  y = c(3, 5, 4, 2, 3.5)
)

# Line plot data
line_data <- data.frame(
  x = seq(0, 10, length.out = 100),
  y = sin(seq(0, 2 * pi, length.out = 100))
)


p_line <- ggplot(line_data, aes(x, y)) +
  geom_line(color = "white", linewidth = 0.5) +
  # geom_vline(
  #   xintercept = seq(0, 50, 100),
  #   color = "white",
  #   lwd = 0.25,
  #   linetype = 2
  # ) +
  # geom_hline(yintercept = 0, color = "white", lwd = 0.8) +
  # geom_point(
  #   data = line_data[c(1, 26, 100), ],
  #   color = "white",
  #   size = 1
  # ) +
  scale_y_continuous(limits = c(-1.2, 1.2)) +
  theme_subplot() +
  theme(
    plot.margin = margin(0, 0, 0, 0),
    axis.line = element_line(color = "white", linewidth = 0.8)
  )

p_bar <- ggplot(bar_data, aes(x, y)) +
  geom_col(fill = "white", width = 0.7) +
  theme_subplot()

panel <- (p_bar | p_line)

subplot <- panel &
  theme(
    plot.background = element_rect(fill = "transparent", color = NA),
    panel.background = element_rect(fill = "transparent", color = NA)
  )

sticker(
  subplot = subplot,
  # Package name
  package = "insperplot",
  p_size = 9,
  p_color = "black",
  p_x = 1,
  p_y = 0.7,
  p_family = "garamond",
  # Subplot positioning
  s_x = 1,
  s_y = 1.2,
  s_width = 1.7,
  s_height = 1 / 1.1,
  # Hex styling
  h_fill = insper_red,
  h_color = "black",
  # Output
  filename = "man/figures/logo.png",
  dpi = 300,
  white_around_sticker = FALSE
)
