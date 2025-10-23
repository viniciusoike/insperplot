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

# This function doesn't work at all.
insper_density(mtcars, wt)

# This function is very poorly implemented, the resuling plot is unaesthetic
# and useless in several use cases.
insper_lollipop(mtcars, cyl, mpg)
# insper_lollipop() has to either make stronger assumptions about the shape
# of the data or has to be removed.

# I think this function should be removed. We can think of a better implementation
# in the future.

# The examples of insper_boxplot() and insper_violin() should use iris and not
# mtcars. The iris data set already has a Species column which is a factor
# insper_boxplot()
# insper_violin()
