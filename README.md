
<!-- README.md is generated from README.Rmd. Please edit that file -->

# insperplot <img src="man/figures/logo.png" align="right" height="139" />

<!-- badges: start -->

[![R-CMD-check](https://github.com/viniciusreginatto/insperplot/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/viniciusreginatto/insperplot/actions/workflows/R-CMD-check.yaml)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

**insperplot** extends ggplot2 with [Insper Instituto de Ensino e Pesquisa](https://www.insper.edu.br/) visual identity, providing custom themes, color palettes, and specialized plotting functions for academic and institutional use.

## ⚠️ Disclaimer

**This is an unofficial package created by an Insper employee, not an official Insper product.** This package is developed independently and is not endorsed, supported, or maintained by Insper Instituto de Ensino e Pesquisa. For official Insper communications and materials, please refer to [Insper’s official website](https://www.insper.edu.br/).

## Installation

You can install the development version of insperplot from GitHub.

``` r
# install.packages("pak")
pak::pak("viniciusreginatto/insperplot")
```

## Quick Start

``` r
library(insperplot)
library(ggplot2)

# Create a basic plot with Insper theme
ggplot(mtcars, aes(x = wt, y = mpg)) +
  geom_point(color = insper_col("reds1"), size = 3) +
  theme_insper() +
  labs(
    title = "Fuel Efficiency vs Weight",
    subtitle = "Motor Trend Car Road Tests",
    x = "Weight (1000 lbs)",
    y = "Miles per Gallon"
  )

# Use Insper color palettes
ggplot(mtcars, aes(x = factor(cyl), fill = factor(cyl))) +
  geom_bar() +
  scale_fill_insper(palette = "reds_seq") +
  theme_insper() +
  labs(title = "Distribution by Cylinders", fill = "Cylinders")

# View available colors
show_insper_palette()
```

## Features

- **Custom Themes**: Professional ggplot2 themes reflecting Insper’s
  visual identity.
- **Color Palettes**: Carefully curated color schemes for various data
  visualization needs.
- **Specialized Plots**: Pre-configured plotting functions for common
  chart types.
- **Brazilian Formatting**: Built-in formatters for Brazilian currency,
  percentages, and numbers.
- **Export Utilities**: Helper functions for saving publication-ready
  plots.

## Main Functions

- `theme_insper()`: Apply Insper’s visual identity to ggplot2 plots.
- `insper_col()`: Extract Insper brand colors.
- `insper_pal()`: Get color palettes.
- `scale_*_insper()`: Insper color scales for ggplot2.
- `show_insper_palette()`: Visualize available color palettes.

## Color Palettes

insperplot includes several pre-defined palettes:

- **main**: Primary Insper colors.
- **reds_seq**, **oranges_seq**, **teals_seq**, **grays_seq**:
  Sequential single-color gradients.
- **diverging_insper**, **diverging_red_teal**: Diverging palettes for
  data with a meaningful center.
- **qualitative_main**, **qualitative_bright**,
  **qualitative_contrast**: Qualitative palettes for categorical data.
- **categorical**: 8-color palette for multi-category data.

Use `list_palettes()` to see all available palettes with detailed information.

## Documentation

For detailed documentation and examples, visit the [package website](https://viniciusreginatto.github.io/insperplot/).

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

MIT © Vinicius Reginatto

## Acknowledgments

This package was inspired by excellent ggplot2 theme packages including:

- [hrbrthemes](https://github.com/hrbrmstr/hrbrthemes) by Bob Rudis
- [bbplot](https://github.com/bbc/bbplot) by BBC Data Team
- [ggthemes](https://github.com/jrnold/ggthemes) by Jeffrey Arnold
