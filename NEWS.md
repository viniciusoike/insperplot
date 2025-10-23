# insperplot 1.1.0

## Breaking Changes

This release removes several utility functions to simplify the package API and enforce consistent naming conventions. All `insper_*` exported functions now create plots, maintaining a consistent interface.

### Format Functions - Consolidated

**REMOVED:**
- `format_brl()` - consolidated into `format_num_br()`
- `format_percent_br()` - consolidated into `format_num_br()`

**UPDATED:**
- `format_num_br()` now accepts `percent` and `currency` parameters for flexible formatting
- Uses `scales::number()` internally (more powerful and consistent)
- Supports additional arguments via `...` parameter

**Migration guide:**
```r
# Old
format_brl(1234.56)
format_brl(1234.56, symbol = FALSE)
format_percent_br(0.123)
format_percent_br(0.123, digits = 2)

# New
format_num_br(1234.56, currency = TRUE, digits = 2)
format_num_br(1234.56, currency = TRUE, prefix = "", digits = 2)  # no symbol
format_num_br(0.123, percent = TRUE, digits = 1)
format_num_br(0.123, percent = TRUE, digits = 2)
```

### Functions Removed from Public API

**No longer exported:**
- `insper_pal()` - now internal-only, used by scale functions
  - Users should use `scale_color_insper_d()`, `scale_fill_insper_d()`, etc.
  - To explore palettes: use `list_palettes()` and `show_insper_palette()`

**Completely removed:**
- `insper_caption()` - build captions with `paste()`, `glue::glue()`, or `labs(caption = ...)`
- `show_palette_types()` - use `list_palettes()` to see all palettes, or loop with `show_insper_palette()`

### Dependency Changes

**Removed:**
- `lubridate` - no longer needed after removing `insper_caption()`

## Rationale

These changes enforce consistent API design:
- All `insper_*` exported functions now create plots (consistent interface)
- Utility functions consolidated to reduce surface area
- Palette discovery uses standardized `list_palettes()` + `show_insper_palette()` pattern
- Cleaner package with fewer exported functions (better maintainability)

---

# insperplot 1.0.1

## Bug Fixes

### Color & Palette System Refactor

Fixed architectural inconsistencies in color/palette system to provide a single source of truth:

**Breaking change (minor):**
- `show_insper_colors()` now returns a **ggplot visualization** instead of hex codes
  - Restored superior grid-based layout from previous version for better readability
  - **Migration:** Use `get_insper_colors()` for extraction (new simplified function)
  - Old: `colors <- show_insper_colors("reds1", "teals1")`
  - New: `colors <- get_insper_colors("reds1", "teals1")`

- `show_insper_palette()` default changed from `"all"` to `"main"`
  - The `"all"` option has been removed (use `list_palettes()` to see all available palettes)
  - Shows the main Insper brand palette by default

**Fixed:**
- `show_insper_palette()` now correctly displays palette colors (not individual colors)
- `list_palettes()` updated to include all palettes in the package:
  - Added: `accent_red`, `accent_teal`, `categorical_ito`, `categorical_tab`, `categorical_set`
  - Removed: non-existent `accent` palette
  - New type: `"accent"` for accent palettes
- `show_insper_colors()` now uses grid layout for better organization and readability
- Now works with all 15 palettes: `reds`, `oranges`, `teals`, `grays`, `red_teal`, `red_teal_ext`, `diverging`, `main`, `bright`, `contrast`, `categorical`, `accent_red`, `accent_teal`, `categorical_ito`, `categorical_tab`, `categorical_set`

**Improved:**
- Unified data structure - single source of truth in `data-raw/create_colors_and_palettes.R`
- Created `insper_individual_colors` and `insper_palettes` internal data objects
- Eliminated duplicate color definitions
- Better visual presentation of colors in grid layout

## Function Clarifications

| Function | Purpose | Returns | Default |
|----------|---------|---------|---------|
| `get_insper_colors()` | Extract individual colors by name | Named hex vector | All colors |
| `show_insper_colors()` | Visualize all individual colors | ggplot object (grid) | All colors |
| `insper_pal()` | Extract palette colors (for use in scales) | Hex vector | "main" palette |
| `show_insper_palette()` | Visualize palettes | ggplot object (gradient) | "main" palette |
| `list_palettes()` | List palette metadata | data.frame | All palettes |

All existing scale functions (`scale_fill_insper_d()`, `scale_color_insper_c()`, etc.) continue to work unchanged.

---

# insperplot 1.0.0

## Major Release: Stable API

This is the **first stable release** of insperplot! The package API is now frozen and follows [semantic versioning](https://semver.org/).

**Lifecycle change:** Package status updated from "experimental" to **"stable"** ✨

## Breaking Changes

### Removed Deprecated Palette Names

Old palette names that showed deprecation warnings in v0.9.x have been **completely removed**. You must now use the simplified names introduced in v0.9.0:

**Removed palette names:**
- ❌ `reds_seq`, `oranges_seq`, `teals_seq`, `grays_seq` → Use `reds`, `oranges`, `teals`, `grays`
- ❌ `diverging_red_teal`, `diverging_red_teal_extended`, `diverging_insper` → Use `red_teal`, `red_teal_ext`, `diverging`
- ❌ `qualitative_main`, `qualitative_bright`, `qualitative_contrast` → Use `main`, `bright`, `contrast`

**Migration:**
```r
# OLD (will now error)
scale_fill_insper_c(palette = "reds_seq")

# NEW
scale_fill_insper_c(palette = "reds")

# List all available palettes
list_palettes()
```

## Bug Fixes

- Fixed vignette build errors caused by undefined variable references
- Fixed font handling in vignettes to prevent failures when fonts unavailable
- Updated all documentation to use current API (`show_insper_colors()` instead of removed `insper_col()`)
- Moved example scripts from `tests/` to `inst/examples/` to prevent test execution issues

## Documentation

- Updated README with stable lifecycle badge
- Clarified v1.0.0 breaking changes in NEWS
- Package documentation is complete and production-ready

## Acknowledgments

Thank you to all users who provided feedback during the experimental phase (v0.1.0 - v0.9.1). The API is now stable and ready for production use!

---

# insperplot 0.9.1

## Enhancements

### Improved `insper_area()` Customization

Enhanced `insper_area()` with five new parameters for greater flexibility while maintaining 100% backward compatibility:

**New parameters:**
- `fill_color` - Custom color for area fill (default: `show_insper_colors("teals1")`)
- `line_color` - Custom color for line overlay (default: `show_insper_colors("teals3")`)
- `line_width` - Adjustable line width (default: 0.8)
- `line_alpha` - Line transparency control (default: 1)
- `zero` - Add horizontal line at y = 0 (default: `FALSE`)

**Example:**
```r
spo_metro |>
  summarise(total = sum(value), .by = date) |>
  insper_area(
    x = date,
    y = total,
    fill_color = show_insper_colors("reds1"),
    line_color = show_insper_colors("reds3"),
    line_width = 1.5,
    line_alpha = 0.8,
    area_alpha = 0.6,
    zero = TRUE
  )
```

**Design consistency:**
- Parameter naming follows package conventions (e.g., `zero` matches `insper_barplot()` and `insper_histogram()`)
- Kept `area_alpha` (more specific than generic `fill_alpha`)
- All parameters apply to both single and grouped area charts

### Documentation

- Added comprehensive CLAUDE.md file with architecture documentation and development guidelines
- Updated `insper_area()` documentation with new parameter examples
- Added 5 new tests covering all new parameters

---

# insperplot 0.9.0

## Breaking Changes

This release completes the API modernization started in v0.8.0, removing all deprecated functions and simplifying palette names for better usability.

### Removed Deprecated Functions

The following deprecated functions have been **removed** (they showed deprecation warnings in v0.8.0):

**Scale functions:**
- ❌ `scale_color_insper()` - Use `scale_color_insper_d()` or `scale_color_insper_c()` instead
- ❌ `scale_colour_insper()` - Use `scale_colour_insper_d()` or `scale_colour_insper_c()` instead
- ❌ `scale_fill_insper()` - Use `scale_fill_insper_d()` or `scale_fill_insper_c()` instead

**Color extraction:**
- ❌ `insper_col()` - Use `show_insper_colors()` instead

**Migration guide:**
```r
# OLD (will now error)
ggplot(data, aes(x, y, color = group)) +
  geom_point() +
  scale_color_insper()

# NEW - for discrete/categorical data
ggplot(data, aes(x, y, color = group)) +
  geom_point() +
  scale_color_insper_d()

# NEW - for continuous data
ggplot(data, aes(x, y, color = value)) +
  geom_point() +
  scale_color_insper_c()

# OLD color extraction (will now error)
color <- insper_col("reds1")

# NEW
color <- show_insper_colors("reds1")
```

### Simplified Palette Names

Palette names have been simplified to be shorter and more intuitive. Old names still work with deprecation warnings (will be removed in v1.0.0):

**Sequential palettes:**
- `reds_seq` → `reds` ⚠️
- `oranges_seq` → `oranges` ⚠️
- `teals_seq` → `teals` ⚠️
- `grays_seq` → `grays` ⚠️

**Diverging palettes:**
- `diverging_red_teal` → `red_teal` ⚠️
- `diverging_red_teal_extended` → `red_teal_ext` ⚠️
- `diverging_insper` → `diverging` ⚠️

**Qualitative palettes:**
- `qualitative_main` → `main` ⚠️
- `qualitative_bright` → `bright` ⚠️
- `qualitative_contrast` → `contrast` ⚠️

**Migration:**
```r
# OLD (still works with warning)
ggplot(data, aes(x, y, color = value)) +
  geom_tile() +
  scale_color_insper_c(palette = "reds_seq")

# NEW
ggplot(data, aes(x, y, color = value)) +
  geom_tile() +
  scale_color_insper_c(palette = "reds")

# List all available palettes
list_palettes()
```

### Updated Default Palettes

- `scale_color_insper_c()` and `scale_fill_insper_c()` now default to `"teals"` (was `"teals_seq"`)

## Benefits

- **Simpler API**: Removed 4 deprecated functions, cleaned up palette naming
- **Less verbose**: `reds` instead of `reds_seq`, `red_teal` instead of `diverging_red_teal`
- **Clearer intent**: `_d` and `_c` suffixes make discrete vs continuous explicit
- **Better consistency**: Follows ggplot2 conventions (e.g., `scale_color_viridis_d()`)

## Documentation Updates

- All examples updated to use new function names and palette names
- All tests updated (19 scale tests, 24 color tests passing)
- README, vignette, and package documentation fully updated
- Comprehensive migration guide in NEWS

---

# insperplot 0.8.0

## Breaking Changes

### Renamed Scale Functions

Following ggplot2 naming conventions, scale functions have been renamed to use `_d` (discrete) and `_c` (continuous) suffixes:

**Old names (deprecated):**
- `scale_color_insper(discrete = TRUE)` / `scale_color_insper(discrete = FALSE)`
- `scale_fill_insper(discrete = TRUE)` / `scale_fill_insper(discrete = FALSE)`

**New names:**
- `scale_color_insper_d()` / `scale_color_insper_c()`
- `scale_fill_insper_d()` / `scale_fill_insper_c()`
- British spellings also available: `scale_colour_insper_d()` / `scale_colour_insper_c()`

**Migration:**
```r
# OLD
ggplot(data, aes(x, y, fill = factor(group))) +
  geom_point() +
  scale_fill_insper()

# NEW
ggplot(data, aes(x, y, fill = factor(group))) +
  geom_point() +
  scale_fill_insper_d()

# OLD - continuous scale
ggplot(data, aes(x, y, fill = value)) +
  geom_tile() +
  scale_fill_insper(discrete = FALSE)

# NEW - continuous scale
ggplot(data, aes(x, y, fill = value)) +
  geom_tile() +
  scale_fill_insper_c()
```

Old function names remain available with deprecation warnings and will be removed in a future version.

### Renamed Color Extraction Function

`insper_col()` has been renamed to `show_insper_colors()` for clarity (it's a utility function, not a plotting function):

**Migration:**
```r
# OLD
color <- insper_col("reds1")
all_colors <- insper_col()

# NEW
color <- show_insper_colors("reds1")
all_colors <- show_insper_colors()
```

The old `insper_col()` name remains available with a deprecation warning.

### Changed Default Parameters

To improve UX and reduce visual clutter by default:

**`insper_scatterplot()`:**
- `add_smooth` now defaults to `FALSE` (was `TRUE`)
- `point_alpha` now defaults to `1` (was `0.7`)

**`insper_boxplot()`:**
- `add_jitter` now defaults to `NULL` with smart auto-detection:
  - Automatically enables jitter if the largest group has <100 observations
  - Can still be explicitly set to `TRUE` or `FALSE` to override

**`insper_violin()`:**
- `show_boxplot` now defaults to `FALSE` (was `TRUE`)

## New Features

### New Plot Functions

**`insper_histogram()`**: Create histograms with formal bin selection methods
- Implements Sturges, Freedman-Diaconis (FD), and Scott algorithms
- Default uses Sturges method for optimal bin width
- Supports grouped histograms with fill aesthetic
- Full Insper styling

```r
# Simple histogram
insper_histogram(mtcars, x = mpg)

# Using Freedman-Diaconis method
insper_histogram(mtcars, x = mpg, bin_method = "fd")

# Grouped histogram
insper_histogram(mtcars, x = mpg, fill = factor(cyl))
```

**`insper_density()`**: Create density plots
- Supports grouped densities
- Customizable bandwidth and kernel
- Full Insper styling

```r
# Simple density plot
insper_density(mtcars, x = mpg)

# Grouped density
insper_density(mtcars, x = mpg, fill = factor(cyl))
```

### Enhanced Flexibility

**`insper_scatterplot()`** now accepts `...` parameter for full geom_point() customization:

```r
# Custom point shape
insper_scatterplot(mtcars, x = wt, y = mpg, shape = 17)

# Use shape = 21 with both color and fill
insper_scatterplot(mtcars, x = wt, y = mpg,
                   color = factor(cyl),
                   shape = 21, stroke = 1.5)
```

## Internal Improvements

- All internal package code updated to use new function names
- All documentation updated with new function references
- Improved code consistency throughout the package

---

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

## Visual Identity

### Package Logo Redesign

The package hex logo has been redesigned with improved visual composition:

* **New design features**:
  - Bar chart + lollipop chart + line chart composition (previously bar + scatter + line)
  - Package name repositioned to top of hex for better visibility
  - Refined subplot sizing and positioning for better balance
  - Thinner border (h_size: 0.85) for modern aesthetic

* **Simplified output**:
  - Only full-size logo (`man/figures/logo.png`) is now generated
  - Small logo variant (`logo-small.png`) removed as it's no longer needed
  - Logo generation script (`data-raw/create_logo.R`) streamlined

The logo continues to represent insperplot's core purpose: creating beautiful, publication-ready data visualizations with Insper's visual identity.

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
