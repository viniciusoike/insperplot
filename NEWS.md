# insperplot 0.7.0

## Breaking Changes: API Modernization

### Removed Orientation Parameters

Following ggplot2's move away from `coord_flip()` (superseded in ggplot2 3.5.0+), orientation parameters have been removed from all plot functions. Users should now swap x and y arguments or add `+ coord_flip()` manually for alternative orientations.

**Removed parameters:**
- `insper_barplot()`: `flip` parameter removed
- `insper_boxplot()`: `flip` parameter removed
- `insper_violin()`: `flip` parameter removed
- `insper_lollipop()`: `horizontal` parameter removed

**Migration examples:**

```r
# OLD - vertical barplot with flip
insper_barplot(df, x = category, y = value, flip = TRUE)

# NEW - swap x and y arguments
insper_barplot(df, x = value, y = category)

# OR - add coord_flip() yourself
insper_barplot(df, x = category, y = value) + coord_flip()
```

```r
# OLD - horizontal boxplot
insper_boxplot(df, x = group, y = value, flip = TRUE)

# NEW - swap x and y
insper_boxplot(df, x = value, y = group)
```

```r
# OLD - horizontal lollipop
insper_lollipop(df, x = category, y = value, horizontal = TRUE)

# NEW - add coord_flip() manually
insper_lollipop(df, x = category, y = value) + coord_flip()
```

### Removed Label Parameters

Title, subtitle, and caption parameters have been removed from all plot functions to reduce API clutter. Users should use standard ggplot2 `labs()` instead, providing better flexibility and consistency with the ggplot2 ecosystem.

**Removed from:** `insper_scatterplot()`, `insper_timeseries()`, `insper_boxplot()`, `insper_lollipop()`, `insper_area()`, `insper_violin()`, `insper_heatmap()`

**Migration guide:**

```r
# OLD - labels as function parameters
insper_scatterplot(df, x, y,
                   title = "My Title",
                   subtitle = "My Subtitle",
                   caption = "Source: XYZ")

# NEW - use ggplot2::labs()
insper_scatterplot(df, x, y) +
  labs(title = "My Title",
       subtitle = "My Subtitle",
       caption = "Source: XYZ")
```

### Improved Flexibility

**`insper_barplot()`** now explicitly supports both orientations without restrictions:

```r
# Categorical x, numeric y (typical vertical bars)
insper_barplot(df, x = group, y = value)

# Numeric x, categorical y (horizontal bars)
insper_barplot(df, x = value, y = group)
```

Documentation updated to clarify that x and y parameters accept any compatible variable types, removing the misleading "(categorical)" and "(numeric)" annotations.

### Benefits

- **Cleaner API**: Fewer parameters, less cognitive load
- **Modern patterns**: Aligns with ggplot2 best practices
- **More flexible**: Users maintain full control via standard ggplot2 patterns
- **Future-proof**: Ready for when coord_flip() is fully deprecated
- **Consistent**: All plot functions follow the same pattern

---

# insperplot 0.6.0

## Comprehensive Documentation with Vignettes

### New Vignette: Getting Started

* **`vignettes/getting-started.Rmd`**: Comprehensive introduction to insperplot featuring:
  - Installation instructions and font setup guide
  - Real-world São Paulo Metro Line-4 ridership data (2018-2020)
  - Complete showcase of all 8 plotting functions with practical examples
  - Brazilian number formatting demonstrations
  - Publication-ready plot saving guidelines
  - Modern R conventions throughout (native pipe `|>`, `linewidth`, `.by` grouping)

### Example Data

* Added **São Paulo Metro Line-4 dataset** (`inst/extdata/metro_sp_line_4_stations.csv`):
  - Monthly ridership data from 9 stations (2018-2020)
  - Captures dramatic COVID-19 pandemic impact on public transportation
  - Perfect for demonstrating time series, comparisons, and distribution analyses
  - All vignette examples use this cohesive, real-world Brazilian dataset

### Package Infrastructure

* Configured `VignetteBuilder: knitr` in DESCRIPTION
* Added `knitr` and `rmarkdown` to Suggests
* Vignettes integrate seamlessly with pkgdown documentation site
* **R CMD check: 0 errors ✔ | 0 warnings ✔ | 0 notes ✔**

### Documentation Improvements

* All 8 plot functions demonstrated with professional, publication-ready examples
* Consistent narrative arc showing pandemic impact through multiple visualization types
* Modern ggplot2 conventions and tidyverse patterns throughout
* Brazilian context (Portuguese labels, local formatting) showcased naturally

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
