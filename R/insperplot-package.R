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
#'   \item \code{\link{insper_col}} - Extract Insper brand colors
#'   \item \code{\link{insper_pal}} - Get color palettes
#'   \item \code{\link{show_insper_palette}} - Visualize color palettes
#' }
#'
#' **Scales:**
#' \itemize{
#'   \item \code{\link{scale_color_insper}} - Insper color scales for ggplot2
#'   \item \code{\link{scale_fill_insper}} - Insper fill scales for ggplot2
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
#'   \item \code{\link{insper_caption}} - Create standardized captions
#'   \item \code{\link{format_brl}} - Format Brazilian currency
#'   \item \code{\link{format_percent_br}} - Format Brazilian percentages
#'   \item \code{\link{format_num_br}} - Format Brazilian numbers
#' }
#'
#' @section Color Palettes:
#' The package includes several pre-defined palettes:
#' \itemize{
#'   \item **main** - Primary Insper colors
#'   \item **reds_seq, oranges_seq, teals_seq, grays_seq** - Sequential single-color gradients
#'   \item **diverging_insper, diverging_red_teal** - Diverging palettes for data with a meaningful center
#'   \item **qualitative_main, qualitative_bright, qualitative_contrast** - Qualitative palettes for categorical data
#'   \item **categorical** - 8-color palette for multi-category data
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
#'   geom_point(color = insper_col("reds1"), size = 3) +
#'   theme_insper() +
#'   labs(title = "Fuel Efficiency vs Weight")
#'
#' # Use Insper color palettes
#' ggplot(mtcars, aes(x = factor(cyl), fill = factor(cyl))) +
#'   geom_bar() +
#'   scale_fill_insper(palette = "reds_seq") +
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
#' insper_col()
#'
#' # Show color palettes
#' show_insper_palette("reds")
#'
#' # Create a simple plot
#' library(ggplot2)
#' ggplot(mtcars, aes(x = wt, y = mpg)) +
#'   geom_point(color = insper_col("reds1")) +
#'   theme_insper()
#' @name insperplot-package
NULL
