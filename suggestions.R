library(insperplot)
library(ggplot2)
library(dplyr)

# Very important documentation change
# All insper_ function have <[`data-masked`][ggplot2::aes_eval]> in their documentation
# This adds zero value to the documentation, and it's not clear what it does.
# They should all be removed. This tag only makes sense inside the ggplot2 package.

# Very important usability change!
# All insper_ functions should support ...
# This should pass arguments to the main geom_* function

# Ex: insper_histogram(...) should pass arguments to geom_histogram()
# Ex: insper_area(...) should pass arguments to geom_area()
# Ex: insper_boxplot(...) should pass arguments to geom_boxplot()
# Ex: insper_timeseries(...) should pass arguments to geom_line()

# The default should be show_value = FALSE
insper_heatmap(mtcars, wt, mpg, show_value = FALSE)

# [RESOLVED v1.3.3] insper_density() now works correctly with bw parameter
insper_density(mtcars, wt)

# [RESOLVED v1.3.3] insper_lollipop() - DECISION: NOT IMPLEMENTED
# Lollipop charts are intentionally excluded from the package.
# Rationale:
# - Would require complex assumptions about data aggregation
# - Can be easily created with standard ggplot2:
#   ggplot(data, aes(x, y)) + geom_segment() + geom_point() + theme_insper()
# - Or use insper_barplot() as starting point and customize
# - Keeps package API focused on commonly-used, well-defined plot types

# The examples of insper_boxplot() and insper_violin() should use iris and not
# mtcars. The iris data set already has a Species column which is a factor
# insper_boxplot()
# insper_violin()
