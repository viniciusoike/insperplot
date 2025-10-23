## This file defines ALL colors and palettes used in insperplot.
## Run this script to regenerate R/sysdata.rda after making changes.

# 1. INDIVIDUAL NAMED COLORS (atomic units)
# These are the building blocks - individual colors that users can
# extract by name using get_insper_colors()
insper_individual_colors <- c(
  # Basic colors
  white = "#ffffff",
  off_white = "#fefefe",
  black = "#000000",

  # Grays (light to dark)
  gray_light = "#E6E7E8",
  gray_med = "#BCBEC0",
  gray_meddark = "#414042",
  gray_dark = "gray20",

  # Reds (Insper's primary color family)
  reds1 = "#E4002B", # Primary Insper Red
  reds2 = "#FCA5A8", # Light red
  reds3 = "#A50020", # Dark red

  # Oranges
  oranges1 = "#F15A22",
  oranges2 = "#F58220",
  oranges3 = "#FAA61A",

  # Magentas
  magentas1 = "#A62B4D",
  magentas2 = "#C43150",
  magentas3 = "#EE2A5D",

  # Teals (Insper's secondary color)
  teals1 = "#009491",
  teals2 = "#27A5A2",
  teals3 = "#3CBFAE"
)

# 2. COLOR PALETTES
# These are collections of colors for use in scale_*_insper_*() functions.
# Palettes can reference individual colors above OR define new hex codes.
insper_palettes <- list(
  # Primary Insper brand colors for categorical data
  main = c("#E4002B", "#F15A22", "#FAA61A", "#009491", "#3CBFAE", "#414042"),

  # Single-hue gradients for ordered/continuous data (light to dark)
  reds = c("#FEE5E7", "#FCA5A8", "#E4002B", "#A50020", "#6B0015"),
  oranges = c("#FEF1E5", "#FAA61A", "#F58220", "#F15A22", "#B83E16"),
  teals = c("#E5F7F7", "#3CBFAE", "#27A5A2", "#009491", "#006763"),
  grays = c("#F5F5F5", "#E6E7E8", "#BCBEC0", "#414042", "#1A1A1A"),

  # For data with meaningful center (negative/neutral/positive)
  red_teal = c("#E4002B", "#FCA5A8", "#FFFFFF", "#7DD4D2", "#009491"),
  red_teal_ext = c(
    "#6B0015",
    "#A50020",
    "#E4002B",
    "#FCA5A8",
    "#FEE5E7",
    "#FFFFFF",
    "#E5F7F7",
    "#7DD4D2",
    "#009491",
    "#006763",
    "#003D3B"
  ),
  diverging = c("#009491", "#3CBFAE", "#E6E7E8", "#FCA5A8", "#E4002B"),

  # Distinct colors for categorical data (unordered categories)
  bright = c("#E4002B", "#F15A22", "#FAA61A", "#009491", "#EE2A5D", "#9B59B6"),
  contrast = c(
    "#E4002B",
    "#009491",
    "#F58220",
    "#A62B4D",
    "#414042",
    "#3CBFAE"
  ),

  # Categorical palette (8 colors for multi-category data)
  categorical = c(
    "#003366",
    "#4A90E2",
    "#FF6B35",
    "#2ECC71",
    "#E74C3C",
    "#F39C12",
    "#9B59B6",
    "#6C757D"
  ),

  # Accent colors - For highlights and emphasis

  accent_red = c(
    "#414042",
    "#BCBEC0",
    "#E6E7E8",
    "#FAA61A",
    "#F15A22",
    "#E4002B"
  ),

  accent_teal = c(
    "#414042",
    "#BCBEC0",
    "#E6E7E8",
    "#003366",
    "#009491",
    "#954000"
  ),

  # accent_cat = c(
  #   scales::muted("#6C757D"),
  #   scales::muted("#9B59B6"),
  #   scales::muted("#F39C12"),
  #   scales::muted("#2ECC71"),
  #   scales::muted("#009491"),
  #   "#003366",
  #   "#F15A22",
  #   "#E4002B"
  # )

  # Good default palettes for general use

  # colorbrewer_div1 <- RColorBrewer::brewer.pal(11, "RdBu")
  # colorbrewer_div2 <- RColorBrewer::brewer.pal(11, "BrBG")

  categorical_ito = palette.colors(palette = "Okabe-Ito")[-1],
  categorical_tab = palette.colors(palette = "Tableau 10"),
  categorical_set = palette.colors(palette = "Set1")
)

# Save as internal data (available to package functions but not exported)
usethis::use_data(
  insper_individual_colors,
  insper_palettes,
  internal = TRUE,
  overwrite = TRUE
)
