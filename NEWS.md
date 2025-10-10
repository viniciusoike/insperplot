# insperplot 0.5.0

## Enhanced Plotting Functions

### Modernization of Existing Functions

All plot functions have been modernized with:
* **Modern rlang patterns**: Replaced `is.null(substitute())` with `rlang::quo_is_null(rlang::enquo())`
* **CLI error messages**: User-friendly error messages with `cli::cli_abort()` replacing basic `stop()`
* **Consistent API**: All functions now use `data` parameter (previously `.dat` in `insper_barplot()`)
* **Enhanced parameters**: Added configurable options for size, alpha, colors, and visual elements

### Plot Function Improvements

**`insper_barplot()`**:
* **BREAKING**: Renamed `group` parameter to `fill_var` for clarity
* **BREAKING**: Changed `.dat` parameter to `data` for consistency
* Fixed fill/group logic bug where single-color and grouped fills conflicted
* Added `label_formatter` parameter for custom text label formatting
* Improved dodge width calculation for better grouped bar spacing

**`insper_scatterplot()`**:
* Added `smooth_method` parameter ("lm", "loess", "gam", "glm")
* Added `point_size` and `point_alpha` parameters for point customization
* Improved color aesthetic handling with proper rlang checks

**`insper_timeseries()`**:
* Added `line_width` parameter for customizable line thickness
* Added `add_points` parameter to overlay points on lines
* Improved Date/POSIXct axis handling
* Better support for grouped time series

**`insper_boxplot()`**:
* Added `add_jitter` parameter (default TRUE) to control jittered points
* Added `add_notch` parameter for notched boxplots
* Added `flip` parameter (default TRUE) to control orientation
* Added `box_alpha` parameter for transparency control

**`insper_heatmap()`**:
* Improved auto-detection of melted vs matrix data
* Added `value_color` and `value_size` parameters for text customization
* Better handling of matrices without row/column names
* Enhanced validation with helpful error messages

### New Plot Functions

* **`insper_lollipop()`**: Lollipop charts for ranked categorical data
  - Supports horizontal/vertical orientation
  - Optional sorting by value
  - Color aesthetic support

* **`insper_area()`**: Area charts for time series
  - Single and grouped areas
  - Stacked area support
  - Optional line overlay

* **`insper_violin()`**: Violin plots for distribution visualization
  - Optional boxplot overlay
  - Optional jittered points
  - Horizontal/vertical orientation

### Testing

* Updated all existing tests to use new API (`fill_var` instead of `group`)
* Added 15 new tests for new plot functions
* All 146+ tests passing
* Maintained >80% code coverage

### Code Quality

* Added `dplyr` and `rlang` to Imports for modern tidyverse patterns
* All functions use consistent parameter documentation with `<[data-masked]>` tags
* Improved examples in all function documentation
* **R CMD check: 0 errors ✔ | 0 warnings ✔ | 0 notes ✔**

### Breaking Changes

* `insper_barplot()`: Parameter `group` renamed to `fill_var` for clarity
* `insper_barplot()`: Parameter `.dat` renamed to `data` for consistency with other functions
* Migration: Replace `insper_barplot(..., group = var)` with `insper_barplot(..., fill_var = var)`

# insperplot 0.4.0

## Visual Identity Enhancement

### Typography Updates
* **Updated brand fonts** to match Insper's actual visual identity:
  - `theme_insper()` now uses **EB Garamond** (serif) for titles
  - Body text now uses **Barlow** (sans-serif) as DIN alternative
  - Both fonts are free Google Fonts, making the package more accessible
* Added `check_insper_fonts()` utility to verify font installation and provide helpful installation instructions

### Color System Overhaul
* **Corrected primary brand color**: Updated from `#C4161C` to `#E4002B` (true Insper Red)
* **Reorganized palettes** into three distinct types following color theory best practices:
  - **Sequential palettes** (`reds_seq`, `oranges_seq`, `teals_seq`, `grays_seq`): For ordered/continuous data
  - **Diverging palettes** (`diverging_red_teal`, `diverging_red_teal_extended`, `diverging_insper`): For data with meaningful center
  - **Qualitative palettes** (`qualitative_main`, `qualitative_bright`, `qualitative_contrast`): For categorical data
* All palettes now use systematic naming conventions (e.g., `reds_seq` instead of `reds`)

### New Discovery Functions
* `list_palettes()`: Returns detailed information about all available palettes (type, number of colors, recommended use)
* `get_insper_colors()`: Interactive palette explorer with visual display of colors and hex codes
* `show_palette_types()`: Creates comprehensive visual display of all palette types with examples

### Bug Fixes
* Fixed naming conflict between `insper_colors()` function and `insper_colors` data object
* Updated `plots.R` to use correct color references (`insper_col()` instead of non-existent data structure)
* Updated `show_insper_palette()` to support both old and new palette names for backwards compatibility
* Fixed all test files to use new palette naming conventions

### Code Quality
* **R CMD check: 0 errors ✔ | 0 warnings ✔ | 0 notes ✔**
* All 131 tests passing
* Updated documentation examples to use new palette names
* Added proper variable declarations to prevent R CMD check NOTEs

# insperplot 0.3.0

## Documentation Improvements

* Added `@family` tags to all functions for better organization:
  - `@family themes` for theme functions
  - `@family colors` for color-related functions
  - `@family scales` for scale functions
  - `@family plots` for plotting functions
  - `@family utilities` for utility functions
* Created comprehensive package-level documentation (`?insperplot`)
* Added `@seealso` cross-references between related functions
* Enhanced function documentation with better examples
* Fixed documentation for `format_num_br()` (previously mislabeled as percentage)

## Testing Infrastructure

* Set up testthat 3rd edition framework
* Implemented comprehensive test suite with 131 tests covering:
  - Theme functions (16 tests)
  - Color functions (24 tests)
  - Scale functions (19 tests)
  - Utility functions (43 tests)
  - Plot functions (29 tests)
* Achieved **94.8% test coverage** (target: 80%+)
* All functions with 100% coverage except plots.R (88.28%)

## Code Quality

* **R CMD check: 0 errors ✔ | 0 warnings ✔ | 0 notes ✔**
* Fixed deprecated ggplot2 `size` parameter → `linewidth` in geom_line and geom_tile
* Updated `discrete_scale()` calls to use new `aesthetics` and `palette` parameters
* Fixed `insper_heatmap()` to use correct palette name (`diverging_insper`)
* Improved `format_num_br()` to handle NULL digits parameter correctly

## Bug Fixes

* Fixed `insper_barplot()` grouped bar functionality
* Corrected palette reference in heatmap function
* Fixed formatting functions to handle edge cases properly

# insperplot 0.2.0

## Major Changes

* Initialized git repository and GitHub integration
* Added comprehensive README with disclaimer about unofficial status
* Updated package structure to follow modern R development best practices

## Code Improvements

* Fixed duplicate code in `data-raw/DATASET.R`
* Removed duplicate `insper_barplot()` function definition
* Cleaned up color palette definitions (renamed `diverging` to `diverging_insper` and `diverging_extended`)
* Updated `.Rbuildignore` with comprehensive exclusions

## Documentation

* Added package disclaimer in DESCRIPTION
* Created README.Rmd with installation instructions and quickstart guide
* Updated DESCRIPTION with proper metadata and URLs

## Infrastructure

* Set up `.gitignore` for R package development
* Added GitHub Actions workflow for R CMD check
* Configured package for pkgdown website

# insperplot 0.1.0

## Initial Release

* Basic theme system with `theme_insper()`
* Color palette functions (`insper_col()`, `insper_pal()`)
* Scale functions for ggplot2
* Specialized plotting functions:
  - `insper_barplot()`
  - `insper_scatterplot()`
  - `insper_timeseries()`
  - `insper_boxplot()`
  - `insper_heatmap()`
* Brazilian formatting utilities
* Caption builder function
