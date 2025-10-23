## code to prepare `DATASET` dataset goes here

#' Insper Color Palettes
#'
#' Complete collection of Insper color palettes for different use cases.
#' Based on Insper's visual identity guidelines.
#'
#' Primary brand color: #E4002B (Insper Red)
insper_colors <- list(

  # ========== MAIN PALETTE ==========
  # Primary Insper brand colors
  main = c("#E4002B", "#F15A22", "#FAA61A", "#009491", "#3CBFAE", "#414042"),

  # ========== SEQUENTIAL PALETTES ==========
  # Single-hue gradients for ordered/continuous data
  reds = c("#FEE5E7", "#FCA5A8", "#E4002B", "#A50020", "#6B0015"),
  oranges = c("#FEF1E5", "#FAA61A", "#F58220", "#F15A22", "#B83E16"),
  teals = c("#E5F7F7", "#3CBFAE", "#27A5A2", "#009491", "#006763"),
  grays = c("#F5F5F5", "#E6E7E8", "#BCBEC0", "#414042", "#1A1A1A"),

  # ========== DIVERGING PALETTES ==========
  # For data with meaningful center (negative/neutral/positive)
  red_teal = c("#E4002B", "#FCA5A8", "#FFFFFF", "#7DD4D2", "#009491"),
  red_teal_ext = c(
    "#6B0015", "#A50020", "#E4002B", "#FCA5A8", "#FEE5E7",
    "#FFFFFF",
    "#E5F7F7", "#7DD4D2", "#009491", "#006763", "#003D3B"
  ),
  diverging = c("#009491", "#3CBFAE", "#E6E7E8", "#FCA5A8", "#E4002B"),

  # ========== QUALITATIVE PALETTES ==========
  # Distinct colors for categorical data (unordered)
  bright = c("#E4002B", "#F15A22", "#FAA61A", "#009491", "#EE2A5D", "#9B59B6"),
  contrast = c("#E4002B", "#009491", "#F58220", "#A62B4D", "#414042", "#3CBFAE"),

  # Categorical Palette (8 colors for multi-category data)
  categorical = c(
    "#003366", "#4A90E2", "#FF6B35", "#2ECC71",
    "#E74C3C", "#F39C12", "#9B59B6", "#6C757D"
  ),

  # Accent Colors - For highlights and emphasis
  accent = c(
    orange = "#FF6B35",
    green = "#2ECC71",
    red = "#E74C3C",
    yellow = "#F39C12",
    purple = "#9B59B6"
  )
)

usethis::use_data(insper_colors, internal = TRUE, overwrite = TRUE)
