library(ggplot2)
library(insperplot)
library(dplyr)

# The format functions are a bit too specific for my taste
# We should have only one function that can handle all formats

# Should be a wrapper around scales::number
# Something like this
format_num_br <- function(
  x,
  digits = 0,
  percent = FALSE,
  curreny = FALSE,
  ...
) {
  if (percent) {
    scales::number(
      x * 100,
      accuracy = 10^(-digits),
      big.mark = ".",
      decimal.mark = ",",
      suffix = "%",
      ...
    )
  }

  if (currency) {
    scales::number(
      x,
      accuracy = 10^(-digits),
      big.mark = ".",
      decimal.mark = ",",
      prefix = "R$",
      ...
    )
  }

  scales::number(
    x,
    accuracy = 10^(-digits),
    big.mark = ".",
    decimal.mark = ",",
    ...
  )
}

# Older functions should be removed
# format_percent_br()
# format_brl()

# These functions break the syntax format of the pacakge
# all insper_ functions are used to make plots
# These functions don't make plots
insper_pal()
insper_caption()

# Also, I'm not sure this function is adding much value to the user
# Maybe consider removing it
insper_caption(source = "IBGE", date = as.Date("2024-02-01"), text = "AAA")

# We have too many "discovery" functions
# Do we need show_palette_types()?
