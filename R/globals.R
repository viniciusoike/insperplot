# Global variables for NSE (Non-Standard Evaluation)
utils::globalVariables(c(
  # Variables used in ggplot2 aes() and other NSE contexts
  "Var1", "Var2", "value",  # insper_heatmap
  "x", "y", "hex", "color", "reverse_col"  # show_insper_palette
))
