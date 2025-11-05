library(insperplot)
library(ggplot2)
library(treemapify)
library(dplyr)

inds <- c(1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144)

insper_cols <- get_palette_colors("main")

dat <- tibble(
  colors = factor(insper_cols, levels = insper_cols),
  area = 1 / inds[1:length(colors)]
)

p1 <- ggplot(dat, aes(area = area, fill = colors, label = colors)) +
  geom_treemap() +
  geom_treemap_text() +
  scale_fill_manual(
    values = insper_cols
  ) +
  theme(
    legend.position = "none",
    plot.margin = margin(10, 10, 10, 10)
  )

p2 <- ggplot(mtcars, aes(x = wt, y = mpg, fill = factor(cyl))) +
  geom_point(color = "#ffffff", size = 4, shape = 21, alpha = 0.9) +
  scale_fill_insper_d(name = NULL) +
  theme_insper() +
  labs(
    title = "Fuel Efficiency vs Weight",
    subtitle = "Motor Trend Car Road Tests",
    x = "Weight (1000 lbs)",
    y = "Miles per Gallon"
  )

p3 <- show_insper_colors()
p4 <- show_insper_palette()


ggsave("man/figures/readme-treemap.png", p1, width = 5, height = 5)
ggsave("man/figures/readme-mtcars-example.png", p2, width = 6, height = 4)
ggsave("man/figures/readme-colors.png", p3, width = 6, height = 4)
ggsave("man/figures/readme-palette.png", p4, width = 6, height = 4)
