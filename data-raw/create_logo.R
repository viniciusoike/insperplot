## Script to create insperplot hex logo
## Run this script to generate the package hex sticker logo

# Install hexSticker if not already installed
if (!require("hexSticker", quietly = TRUE)) {
  install.packages("hexSticker")
}

library(hexSticker)
library(ggplot2)

# Define Insper colors
insper_red <- "#E4002B"
insper_teal <- "#009491"
insper_orange <- "#F15A22"

# Create a simple subplot - a stylized line chart representing plotting
subplot_data <- data.frame(
  x = seq(0, 10, length.out = 50),
  y = sin(seq(0, 2 * pi, length.out = 50)) * 0.5 + 0.5
)

subplot <- ggplot(subplot_data, aes(x = x, y = y)) +
  geom_line(color = "white", size = 2, lineend = "round") +
  geom_point(color = "white", size = 3,
             data = subplot_data[c(1, 25, 50), ]) +
  theme_void() +
  theme(
    panel.background = element_rect(fill = "transparent", color = NA),
    plot.background = element_rect(fill = "transparent", color = NA)
  )

# Create the directory if it doesn't exist
if (!dir.exists("man/figures")) {
  dir.create("man/figures", recursive = TRUE)
}

# Create the hex sticker
sticker(
  subplot = subplot,
  # Package name
  package = "insperplot",
  p_size = 22,           # Package name text size
  p_color = "white",     # Package name color
  p_x = 1,               # Package name x position
  p_y = 0.55,            # Package name y position (lower to make room for subplot)
  p_family = "sans",     # Font family
  # Subplot settings
  s_x = 1,               # Subplot x position
  s_y = 1.15,            # Subplot y position (above text)
  s_width = 1.2,         # Subplot width
  s_height = 0.8,        # Subplot height
  # Hex settings
  h_fill = insper_red,   # Hex background color (Insper Red)
  h_color = insper_teal, # Hex border color (Insper Teal for contrast)
  h_size = 1.5,          # Border thickness
  # Spotlight (adds subtle gradient effect)
  spotlight = TRUE,
  l_x = 1,
  l_y = 0.8,
  l_width = 3,
  l_height = 3,
  l_alpha = 0.3,
  # Output
  filename = "man/figures/logo.png",
  dpi = 320,
  white_around_sticker = FALSE
)

cat("Logo created successfully at: man/figures/logo.png\n")

# Create a smaller version for README
if (file.exists("man/figures/logo.png")) {
  # Read and resize using magick if available, otherwise just copy
  if (require("magick", quietly = TRUE)) {
    logo <- magick::image_read("man/figures/logo.png")
    logo_small <- magick::image_scale(logo, "240x278")
    magick::image_write(logo_small, "man/figures/logo-small.png")
    cat("Small logo created at: man/figures/logo-small.png\n")
  } else {
    cat("Note: Install 'magick' package to generate small logo version\n")
    cat("  install.packages('magick')\n")
  }
}

cat("\nTo use the logo in your README, add:\n")
cat('  <img src="man/figures/logo.png" align="right" height="139" />\n')
cat("\nYou can customize this script by:\n")
cat("  - Adjusting colors (insper_red, insper_teal, etc.)\n")
cat("  - Modifying the subplot design\n")
cat("  - Changing text size/position (p_size, p_x, p_y)\n")
cat("  - Adjusting subplot position/size (s_x, s_y, s_width, s_height)\n")
cat("  - Modifying border color/thickness (h_color, h_size)\n")
