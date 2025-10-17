library(insperplot)
library(ggplot2)
library(dplyr)

rank2018 <- spo_metro |>
  filter(year == 2018) |>
  summarise(total = sum(value, na.rm = TRUE), .by = "name_station") |>
  mutate(
    name_station = factor(name_station),
    name_station = forcats::fct_reorder(name_station, total)
  )

insper_barplot(rank2018, total, name_station)
insper_barplot(rank2018, name_station, total, text = TRUE)

df <- data.frame(group = letters[1:3], y = c(3, 5, 2))
insper_barplot(df, y, group)

ggplot(df, aes(group, y)) +
  geom_col()

ggplot(df, aes(y, group)) +
  geom_col()
