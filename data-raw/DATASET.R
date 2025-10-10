## code to prepare `DATASET` dataset goes here

#' Insper Color Palettes
#'
#' Complete collection of Insper color palettes for different use cases
insper_colors <- list(

  # Main palette - Primary Insper colors
  main = c("#C4161C", "#F15A22", "#FAA61A", "#009491", "#3CBFAE", "#414042"),

  # Sequential palettes - Single color gradients
  reds = c("#F69679", "#E80724", "#C4161C"),
  oranges = c("#FAA61A", "#F58220", "#F15A22"),
  teals = c("#3CBFAE", "#27A5A2", "#009491"),
  grays = c("#E6E7E8", "#BCBEC0", "#414042"),

  # Sequential Blues (for continuous data)
  sequential = c(
    "#F7FBFF", "#DEEBF7", "#C6DBEF", "#9ECAE1",
    "#6BAED6", "#4292C6", "#2171B5", "#08519C", "#08306B"
  ),

  # Diverging palettes (for data with meaningful center)
  diverging_insper = c("#009491", "#3CBFAE", "#E6E7E8", "#F69679", "#C4161C"),
  diverging_extended = c(
    "#8E0152", "#C51B7D", "#DE77AE", "#F1B6DA",
    "#FDE0EF", "#E6F5D0", "#B8E186", "#7FBC41",
    "#4D9221", "#276419"
  ),

  # Qualitative palettes - Multi-category data
  bright = c("#E80724", "#F15A22", "#FAA61A", "#009491", "#EE2A5D"),
  contrast = c("#C4161C", "#009491", "#F58220", "#A62B4D", "#414042"),

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
