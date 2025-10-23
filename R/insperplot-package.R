#' @keywords internal
"_PACKAGE"

#' insperplot: Insper Themed ggplot2 Extensions
#'
#' @description
#' This package extends ggplot2 with Insper Instituto de Ensino e Pesquisa
#' visual identity, providing custom themes, color palettes, and specialized
#' plotting functions for academic and institutional use.
#'
#' **Disclaimer:** This is an unofficial package created by an Insper employee,
#' not an official Insper product. This package is developed independently and
#' is not endorsed, supported, or maintained by Insper Instituto de Ensino e
#' Pesquisa.
#'
#' @section Main Functions:
#'
#' **Themes:**
#' \itemize{
#'   \item \code{\link{theme_insper}} - Apply Insper's visual identity to plots
#' }
#'
#' **Colors:**
#' \itemize{
#'   \item \code{\link{get_insper_colors}} - Extract individual Insper brand colors
#'   \item \code{\link{show_insper_colors}} - Visualize Insper brand colors
#'   \item \code{\link{show_insper_palette}} - Visualize color palettes
#'   \item \code{\link{list_palettes}} - List available color palettes
#' }
#'
#' **Scales:**
#' \itemize{
#'   \item \code{\link{scale_color_insper_d}} / \code{\link{scale_fill_insper_d}} - Discrete color scales
#'   \item \code{\link{scale_color_insper_c}} / \code{\link{scale_fill_insper_c}} - Continuous color scales
#' }
#'
#' **Plot Functions:**
#' \itemize{
#'   \item \code{\link{insper_barplot}} - Create bar plots with Insper theme
#'   \item \code{\link{insper_scatterplot}} - Create scatter plots
#'   \item \code{\link{insper_timeseries}} - Create time series plots
#'   \item \code{\link{insper_boxplot}} - Create box plots
#' }
#'
#' **Utilities:**
#' \itemize{
#'   \item \code{\link{save_insper_plot}} - Save plots with institutional defaults
#'   \item \code{\link{format_num_br}} - Format Brazilian numbers (supports currency and percentages)
#' }
#'
#' @section Color Palettes:
#' The package includes 15 pre-defined palettes:
#' \itemize{
#'   \item **main** - Primary Insper brand colors
#'   \item **reds, oranges, teals, grays** - Sequential single-color gradients
#'   \item **diverging, red_teal, red_teal_ext** - Diverging palettes for data with a meaningful center
#'   \item **bright, contrast, categorical** - Qualitative palettes for categorical data
#'   \item **accent_red, accent_teal** - Accent palettes for emphasis
#'   \item **categorical_ito, categorical_tab, categorical_set** - Colorblind-safe categorical options
#' }
#'
#' Use \code{\link{list_palettes}()} to see all available palettes with detailed information.
#'
#' @section Getting Started:
#' \preformatted{
#' library(insperplot)
#' library(ggplot2)
#'
#' # Create a basic plot with Insper theme
#' ggplot(mtcars, aes(x = wt, y = mpg)) +
#'   geom_point(color = get_insper_colors("reds1"), size = 3) +
#'   theme_insper() +
#'   labs(title = "Fuel Efficiency vs Weight")
#'
#' # Use Insper color palettes
#' ggplot(mtcars, aes(x = factor(cyl), fill = factor(cyl))) +
#'   geom_bar() +
#'   scale_fill_insper_d(palette = "reds") +
#'   theme_insper()
#' }
#'
#' @section Package Development:
#' This package follows modern R development best practices:
#' \itemize{
#'   \item Native pipe operator (\code{|>}) throughout
#'   \item Modern tidyverse patterns (dplyr 1.1+)
#'   \item Comprehensive documentation with roxygen2
#'   \item Continuous integration with GitHub Actions
#' }
#'
#' @references
#' For official Insper communications and materials, please visit:
#' \url{https://www.insper.edu.br/}
#'
#' @seealso
#' Useful links:
#' \itemize{
#'   \item Report bugs at \url{https://github.com/viniciusoike/insperplot/issues}
#'   \item Package website at \url{https://viniciusoike.github.io/insperplot/}
#' }
#'
#' @examples
#' # View available colors
#' get_insper_colors()
#'
#' # Show color palettes
#' show_insper_palette("reds")
#'
#' \dontrun{
#' # Create a simple plot (requires fonts to be set up)
#' library(ggplot2)
#' ggplot(mtcars, aes(x = wt, y = mpg)) +
#'   geom_point(color = get_insper_colors("reds1")) +
#'   theme_insper()
#' }
#' @name insperplot-package
NULL
