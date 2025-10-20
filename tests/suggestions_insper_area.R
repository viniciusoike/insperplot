library(insperplot)
library(ggplot2)
library(dplyr)

spo_metro |>
  summarise(total = sum(value), .by = date) |>
  insper_area(
    x = date,
    y = total,
    add_line = TRUE
  ) +
  labs(
    title = "Demanda Total da Linha 4-Amarela",
    subtitle = "Soma de todas as estações (milhares de passageiros/mês)",
    caption = "Fonte: CCR Metrô | Insper"
  )

dont_run <- function() {
  spo_metro |>
    summarise(total = sum(value), .by = date) |>
    insper_area(
      x = date,
      y = total,
      add_line = TRUE,
      fill_color = show_insper_colors("teals1"),
      area_alpha = 0.8,  # Note: kept as area_alpha (more specific than fill_alpha)
      line_width = 1,
      line_color = show_insper_colors("teals3"),
      line_alpha = 0.8,
      zero = TRUE  # Note: zero (consistent with other plot functions), not zero_line
    ) +
    scale_y_continuous(expand = expansion(mult = c(0, 0.05))) +
    theme(panel.grid.major.x = element_blank())
}
