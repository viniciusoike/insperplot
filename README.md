
<!-- README.md is generated from README.Rmd. Please edit that file -->

# insperplot <img src="man/figures/logo.png" align="right" height="139" />

<!-- badges: start -->

[![R-CMD-check](https://github.com/viniciusoike/insperplot/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/viniciusoike/insperplot/actions/workflows/R-CMD-check.yaml)
[![Lifecycle:
stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
<!-- badges: end -->

**insperplot** extends ggplot2 with [Insper Instituto de Ensino e
Pesquisa](https://www.insper.edu.br/) visual identity, providing custom
themes, color palettes, and specialized plotting functions for academic
and institutional use.

## ⚠️ Disclaimer

**This is an unofficial package created by an Insper employee, not an
official Insper product.** This package is developed independently and
is not endorsed, supported, or maintained by Insper Instituto de Ensino
e Pesquisa. For official Insper communications and materials, please
refer to [Insper’s official website](https://www.insper.edu.br/).

## Installation

You can install the development version of insperplot from GitHub:

``` r
# install.packages("remotes")
remotes::install_github("viniciusoike/insperplot")
```

## Setup (Recommended)

For the best results with insperplot, we recommend a one-time setup:

### Quick Setup Wizard

``` r
library(insperplot)
setup_insper_fonts()  # Interactive guide for complete setup
```

### Manual Setup

**Step 1: Install Insper Fonts**

`insperplot` uses fonts based on Insper’s official template. We include
EB Garamond and Playfair Display as fallbacks for Georgia.

- **Georgia** (serif, primary for titles) - typically pre-installed
- **Inter** (sans-serif, for body text) - Google Font
- **EB Garamond** & **Playfair Display** (serif, title fallbacks) -
  Google

To use these fonts, visit [Google Fonts](https://fonts.google.com) and
download and install “Inter”, “EB Garamond”, and “Playfair Display”.

**Step 2: Install ragg Graphics Device**

``` r
install.packages("ragg")
```

**Step 3: Configure RStudio (if using RStudio)**

- Go to: **Tools \> Global Options \> General \> Graphics**
- Set **Backend** to **AGG**
- Restart R session

**Note:** Positron users can skip this step since it uses ragg by
default.

## Quick Start

`insperplot` is built upon Insper’s brand colors. To improve
functionality, additional palettes were created based on these basic
colors.

<p align="center">

<img src="man/figures/readme-treemap.png" width="50%"/>
</p>

To use `insperplot` we recommend using `ggplot2`. The basic functions of
the package are `theme_insper()` and the `scale_*_insper_*()` functions.

``` r
library(insperplot)
library(ggplot2)
library(ragg)

# Create a basic plot with Insper theme
ggplot(mtcars, aes(x = wt, y = mpg, fill = factor(cyl))) +
  geom_point(color = "#ffffff", size = 4, shape = 21, alpha = 0.9) +
  scale_fill_insper_d(name = NULL) +
  theme_insper() +
  labs(
    title = "Fuel Efficiency vs Weight",
    subtitle = "Motor Trend Car Road Tests",
    x = "Weight (1000 lbs)",
    y = "Miles per Gallon"
  )
```

<p align="center">

<img src="man/figures/readme-mtcars-example.png" width="80%"/>
</p>

The package is based on Insper’s brand colors.

``` r
# View available colors
show_insper_colors()
```

<p align="center">

<img src="man/figures/readme-colors.png" width="80%"/>
</p>

insperplot includes several pre-defined palettes:

- **main**: Primary Insper colors
- **reds**, **oranges**, **teals**, **grays**: Sequential single-color
  gradients
- **diverging**, **red_teal**, **red_teal_ext**: Diverging palettes for
  data with a meaningful center
- **bright**, **contrast**: Qualitative palettes for categorical data
- **categorical**, **accent**: Additional color options

Use `list_palettes()` to see all available palettes with detailed
information. To visualize the colors in each palette, use
`show_insper_palette()`:

``` r
show_insper_palette()
```

<p align="center">

<img src="man/figures/readme-palette.png" width="80%"/>
</p>

## Main Functions

- `theme_insper()`: Apply Insper’s visual identity to ggplot2 plots.
- `scale_color_insper_d()` / `scale_fill_insper_d()`: Discrete color
  scales.
- `scale_color_insper_c()` / `scale_fill_insper_c()`: Continuous color
  scales.
- `show_insper_palette()`: Visualize available color palettes.
- `insper_*()`: Specialized plotting functions.

## Documentation

For detailed documentation and examples, visit the [package
website](https://viniciusoike.github.io/insperplot/).

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md)
for guidelines.

## License

MIT © Vinicius Reginatto

## Acknowledgments

This package was inspired by excellent ggplot2 theme packages including:

- [hrbrthemes](https://github.com/hrbrmstr/hrbrthemes) by Bob Rudis
  (note: removed from CRAN in 2025)
- [bbplot](https://github.com/bbc/bbplot) by BBC Data Team
- [ggthemes](https://github.com/jrnold/ggthemes) by Jeffrey Arnold
