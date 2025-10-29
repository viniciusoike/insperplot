# Parameter Naming Refactor: Smart Detection (v2.0.0)

**Status**: Phase 4 In Progress - 5 of 8 functions complete (63%)
**Target Release**: v2.0.0
**Created**: 2025-10-24
**Last Updated**: 2025-10-24 (Active Implementation Session)

## Quick Progress Summary

| Phase | Status | Functions | Details |
|-------|--------|-----------|---------|
| **Phase 1** | ✅ Complete | Helper functions | 3 internal helpers, 86 tests passing |
| **Phase 2** | ✅ Complete | insper_scatterplot | Dual aesthetic support (color + fill) |
| **Phase 3** | ✅ Complete | insper_barplot | Major refactor, removed 2 params |
| **Phase 4** | ✅ Complete | insper_timeseries | Renamed group→color |
| **Phase 5** | ✅ Complete | insper_boxplot | Minor refactor, added palette |
| **Phase 6** | ✅ Complete | insper_violin | Minor refactor, added palette |
| **Phase 7** | 🔄 In Progress | insper_histogram | Removing fill_color param |
| **Phase 8** | ⏳ Pending | insper_area | Major - dual aesthetic propagation |
| **Phase 9** | ⏳ Pending | insper_density | Major - dual aesthetic propagation |
| **Phase 10** | ⏳ Pending | Documentation | NEWS.md, README, roxygen |
| **Phase 11** | ⏳ Pending | Final Validation | devtools::check(), tests |

**Progress**: 5 of 8 plot functions updated (63%), ~8 hours work remaining

---

## Table of Contents
1. [Problem Statement](#problem-statement)
2. [Solution Overview](#solution-overview)
3. [Core Design Decisions](#core-design-decisions)
4. [Technical Implementation](#technical-implementation)
5. [Completed Functions](#completed-functions)
6. [Remaining Functions](#remaining-functions)
7. [Edge Cases & Solutions](#edge-cases--solutions)
8. [Testing Strategy](#testing-strategy)
9. [Documentation Requirements](#documentation-requirements)
10. [Migration Guide](#migration-guide)
11. [Next Steps](#next-steps)

---

## Problem Statement

### Current API Confusion

Users encounter confusing behavior with `color` and `fill` parameters:

```r
# These are the same
ggplot(mtcars, aes(mpg, wt)) +
  geom_point(aes(color = factor(cyl)))

insper_scatterplot(mtcars, x = mpg, y = wt, color = factor(cyl))
```

**But this breaks user expectations:**

```r
# Expected: blue points
# Actual: creates fake group called "blue"
insper_scatterplot(mtcars, x = mpg, y = wt, color = "blue")

# Compare to ggplot2 (what users expect)
ggplot(mtcars, aes(mpg, wt)) +
  geom_point(color = "blue")  # Actually makes blue points!
```

### Current Workarounds

Different functions have different solutions:

- **insper_barplot**: Awkward `fill_var` vs `single_color` parameters
- **insper_scatterplot**: No way to set static color without hardcoding default
- **insper_area/density**: Confusing `fill_color` vs `fill` parameters

This inconsistency violates the package design principles:
- ❌ **Not consistent** across functions
- ❌ **Not intuitive** (color = "blue" doesn't work as expected)
- ❌ **Too many parameters** for common use cases

---

## Solution Overview

### Smart Detection Approach

Implement intelligent parameter detection that distinguishes between:

1. **Static colors**: `color = "blue"` or `fill = "#FF0000"`
2. **Variable mappings**: `color = Species` or `fill = factor(cyl)`

### Key Benefits

✅ **Intuitive**: `color = "blue"` produces blue points
✅ **Consistent**: All functions follow the same pattern
✅ **Simpler API**: Single aesthetic parameter per function
✅ **Clear errors**: Invalid colors show helpful messages
✅ **Type-aware**: Automatically detects continuous vs discrete variables

---

## Core Design Decisions

### 1. Single Smart Aesthetic Per Function

Each plotting function has **ONE** primary smart aesthetic parameter:

| Function | Smart Parameter | Rationale |
|----------|----------------|-----------|
| `insper_barplot` | `fill` | Bars use fill aesthetic |
| `insper_scatterplot` | `color` | Points use color aesthetic |
| `insper_timeseries` | `color` | Lines use color aesthetic |
| `insper_boxplot` | `fill` | Boxes use fill aesthetic |
| `insper_area` | `fill` | Areas use fill aesthetic |
| `insper_violin` | `fill` | Violins use fill aesthetic |
| `insper_histogram` | `fill` | Bars use fill aesthetic |
| `insper_density` | `fill` | Density curves use fill aesthetic |
| `insper_heatmap` | N/A | Uses continuous scale (no change) |

### 2. Automatic Aesthetic Propagation

When the smart parameter is a **variable mapping**, automatically apply to related aesthetics:

- **insper_area**: `fill = group` → applies to BOTH `aes(fill = group)` AND `aes(color = group)` for line
- **insper_density**: `fill = group` → applies to BOTH `aes(fill = group)` AND `aes(color = group)` for line
- **All others**: Only the primary aesthetic is affected

This simplifies the API while maintaining expected behavior.

### 3. Static Color Customization

For static cases with multiple aesthetics, keep separate parameters:

```r
# insper_area: separate control for area vs line
insper_area(
  df, x = time, y = value,
  fill = "lightblue",      # Static fill for area
  line_color = "darkblue"  # Static color for line
)

# insper_density: separate control for fill vs line
insper_density(
  df, x = value,
  fill = "lightblue",      # Static fill for density area
  line_color = "darkblue"  # Static color for density line
)
```

### 4. Palette Warning System

When `palette` is specified but the aesthetic uses a static color:

```r
# This should warn
insper_barplot(data, x = cyl, y = mpg, fill = "blue", palette = "bright")
#> Warning: `palette` argument ignored when `fill` is a static color

# This is correct usage
insper_barplot(data, x = cyl, y = mpg, fill = gear, palette = "bright")
```

**Implementation**: Use `cli::cli_warn()` with informative message.

### 5. Detection Rules (Quoted vs Unquoted)

| User Code | Detection | Behavior |
|-----------|-----------|----------|
| `color = Species` | Bare symbol → variable | `aes(color = Species)` + discrete scale |
| `color = factor(cyl)` | Expression → variable | `aes(color = factor(cyl))` + discrete scale |
| `color = hp` | Bare symbol → variable (continuous) | `aes(color = hp)` + continuous scale |
| `color = "blue"` | String literal → static | `geom_*(color = "blue")` |
| `color = "#0000FF"` | String literal → static | `geom_*(color = "#0000FF")` |
| `color = "red"` | String literal → static (even if column named "red" exists) | `geom_*(color = "red")` |

**Edge case resolution**: Strings ALWAYS treated as colors. If user has a column named "red" and wants to map it, they use bare symbol: `color = red` (unquoted).

---

## Technical Implementation

### Helper Function 1: Smart Detection

Create in `R/utils.R`:

```r
#' Detect if aesthetic parameter is static color or variable mapping
#'
#' @param quo Quosure from rlang::enquo()
#' @param param_name Character. Parameter name for error messages
#' @param data Data frame to evaluate variable in
#'
#' @return List with:
#'   - type: "missing", "static_color", or "variable_mapping"
#'   - value: The static color value (if type = "static_color")
#'   - is_continuous: Logical (if type = "variable_mapping")
#'
#' @keywords internal
detect_aesthetic_type <- function(quo, param_name = "parameter", data = NULL) {
  # Check if parameter was not provided
  if (rlang::quo_is_null(quo)) {
    return(list(type = "missing"))
  }

  expr <- rlang::quo_get_expr(quo)

  # Check if it's a string literal (static color)
  if (is.character(expr) && length(expr) == 1) {
    if (is_valid_color(expr)) {
      return(list(type = "static_color", value = expr))
    } else {
      cli::cli_abort(c(
        "{.arg {param_name}} = {.val {expr}} is not a valid color",
        "i" = "Use a bare column name for variable mapping: {.code {param_name} = column_name}",
        "i" = "Or use a valid color name/hex code: {.code {param_name} = \"blue\"}",
        "i" = "See {.code colors()} for valid color names"
      ))
    }
  }

  # It's a variable mapping (symbol or expression)
  # Detect if continuous or discrete
  if (!is.null(data)) {
    var_vals <- rlang::eval_tidy(quo, data)
    is_continuous <- is.numeric(var_vals) && !is.factor(var_vals)
  } else {
    is_continuous <- FALSE  # Can't determine without data
  }

  return(list(
    type = "variable_mapping",
    is_continuous = is_continuous
  ))
}
```

### Helper Function 2: Color Validation

Create in `R/utils.R`:

```r
#' Check if string is a valid color
#'
#' Validates hex colors and named colors recognized by R's graphics device.
#'
#' @param x Character vector of length 1
#'
#' @return Logical
#' @keywords internal
is_valid_color <- function(x) {
  if (!is.character(x) || length(x) != 1) {
    return(FALSE)
  }

  # Check hex color pattern (#RGB, #RRGGBB, #RRGGBBAA)
  if (grepl("^#([0-9A-Fa-f]{3}|[0-9A-Fa-f]{6}|[0-9A-Fa-f]{8})$", x)) {
    return(TRUE)
  }

  # Check if grDevices recognizes it as a named color
  tryCatch({
    grDevices::col2rgb(x)
    return(TRUE)
  }, error = function(e) {
    return(FALSE)
  })
}
```

### Helper Function 3: Palette Warning

Create in `R/utils.R`:

```r
#' Warn if palette specified with static aesthetic
#'
#' @param aesthetic_type List returned from detect_aesthetic_type()
#' @param palette Character or NULL. The palette argument value
#' @param param_name Character. Name of the aesthetic parameter
#'
#' @return NULL (called for side effect of warning)
#' @keywords internal
warn_palette_ignored <- function(aesthetic_type, palette, param_name) {
  if (!is.null(palette) && aesthetic_type$type == "static_color") {
    cli::cli_warn(c(
      "{.arg palette} argument ignored when {.arg {param_name}} is a static color",
      "i" = "The {.arg palette} parameter only applies when {.arg {param_name}} is a variable mapping",
      "i" = "Remove {.code palette = {.val {palette}}} or use a variable for {.arg {param_name}}"
    ))
  }
}
```

---

## Completed Functions

### ✅ 1. insper_scatterplot (COMPLETE)

**Status**: Fully implemented and tested (12 test scenarios passing)

**Changes Made:**
- Added smart detection for `color` parameter
- Added smart detection for `fill` parameter (NEW - for shapes 21-25)
- Added `palette` parameter for explicit palette control
- Automatic continuous vs discrete scale detection
- Supports dual aesthetic mapping (different variables to color and fill)

**New Signature:**
```r
insper_scatterplot(
  data, x, y,
  color = NULL,        # Smart: "blue" or Species or hp
  fill = NULL,         # Smart: "lightblue" or Species (shapes 21-25)
  palette = "categorical",
  add_smooth = FALSE,
  smooth_method = "lm",
  point_size = 2,
  point_alpha = 1,
  ...
)
```

**Examples:**
```r
# Static color
insper_scatterplot(mtcars, x = wt, y = mpg, color = "blue")

# Discrete variable
insper_scatterplot(mtcars, x = wt, y = mpg, color = factor(cyl))

# Continuous variable (NEW!)
insper_scatterplot(mtcars, x = wt, y = mpg, color = hp)

# Dual aesthetics (NEW!)
insper_scatterplot(mtcars, x = wt, y = mpg,
                   color = factor(cyl), fill = factor(gear), shape = 21)
```

**Location**: R/plots.R:213-447

---

### ✅ 2. insper_barplot (COMPLETE)

**Status**: Fully implemented and tested (8 test scenarios passing)

**Breaking Changes:**
- REMOVED: `fill_var` parameter
- REMOVED: `single_color` parameter
- ADDED: Smart `fill` parameter (handles both cases)
- ADDED: `palette` parameter
- CHANGED: `...` now goes to `geom_col()` instead of scale

**New Signature:**
```r
insper_barplot(
  data, x, y,
  fill = NULL,           # Smart: "blue" or gear
  position = "dodge",
  palette = "categorical",
  zero = TRUE,
  text = FALSE,
  text_size = 4,
  text_color = "black",
  label_formatter = scales::comma,
  ...  # Goes to geom_col()
)
```

**Migration:**
```r
# OLD v1.x
insper_barplot(mtcars, x = cyl, y = mpg, single_color = "blue")
insper_barplot(mtcars, x = cyl, y = mpg, fill_var = gear)

# NEW v2.0
insper_barplot(mtcars, x = cyl, y = mpg, fill = "blue")
insper_barplot(mtcars, x = cyl, y = mpg, fill = gear)
```

**Location**: R/plots.R:1-211

---

### ✅ 3. insper_timeseries (COMPLETE)

**Status**: Fully implemented and tested (6 test scenarios passing)

**Breaking Changes:**
- RENAMED: `group` parameter → `color` (semantic clarity)
- ADDED: Smart detection for `color`
- ADDED: `palette` parameter
- ADDED: Continuous variable support

**New Signature:**
```r
insper_timeseries(
  data, x, y,
  color = NULL,      # Smart: "darkblue" or category or intensity
  palette = "categorical",
  line_width = 0.8,
  add_points = FALSE,
  ...
)
```

**Migration:**
```r
# OLD v1.x
insper_timeseries(df, x = time, y = value, group = category)

# NEW v2.0
insper_timeseries(df, x = time, y = value, color = category)
```

**New Capability:**
```r
# Continuous color gradient (NEW!)
insper_timeseries(df, x = time, y = value, color = intensity)
```

**Location**: R/plots.R:449-584

---

### ✅ 4. insper_boxplot (COMPLETE)

**Status**: Fully implemented, ready for testing

**Changes Made:**
- Added smart detection for `fill` parameter
- Added `palette` parameter
- No breaking changes to parameter names

**New Signature:**
```r
insper_boxplot(
  data, x, y,
  fill = NULL,           # Smart: "lightblue" or Species
  palette = "categorical",
  add_jitter = NULL,
  add_notch = FALSE,
  box_alpha = 0.8,
  ...
)
```

**New Capability:**
```r
# Static fill (NEW!)
insper_boxplot(iris, x = Species, y = Sepal.Length, fill = "lightblue")

# Variable fill (same as before, but now with palette control)
insper_boxplot(iris, x = Species, y = Sepal.Length, fill = Species, palette = "bright")
```

**Location**: R/plots.R:586-713

---

### ✅ 5. insper_violin (COMPLETE)

**Status**: Fully implemented, ready for testing

**Changes Made:**
- Added smart detection for `fill` parameter
- Added `palette` parameter
- No breaking changes to parameter names

**New Signature:**
```r
insper_violin(
  data, x, y,
  fill = NULL,           # Smart: "purple" or Species
  palette = "categorical",
  show_boxplot = FALSE,
  show_points = FALSE,
  violin_alpha = 0.7,
  ...
)
```

**New Capability:**
```r
# Static fill (NEW!)
insper_violin(iris, x = Species, y = Sepal.Length, fill = "purple")

# Variable fill with custom palette
insper_violin(iris, x = Species, y = Sepal.Length, fill = Species, palette = "bright")
```

**Location**: R/plots.R:949-1065

---

## Remaining Functions

### 🔄 6. insper_histogram (IN PROGRESS)

**Current signature:**
```r
insper_barplot(data, x, y, fill_var = NULL, single_color = get_insper_colors("reds1"),
               position = "dodge", palette = "categorical", ...)
```

**New signature:**
```r
insper_barplot(data, x, y, fill = NULL, position = "dodge",
               palette = "categorical", zero = TRUE, text = FALSE, ...)
```

**Implementation pattern:**
```r
insper_barplot <- function(
  data, x, y,
  fill = NULL,
  position = "dodge",
  palette = "categorical",
  zero = TRUE,
  text = FALSE,
  text_size = 4,
  text_color = "black",
  label_formatter = scales::comma,
  ...
) {
  # Detect fill type
  fill_quo <- rlang::enquo(fill)
  fill_type <- detect_aesthetic_type(fill_quo, "fill", data)

  # Warn if palette specified with static fill
  warn_palette_ignored(fill_type, palette, "fill")

  # Build plot based on type
  if (fill_type$type == "missing") {
    # Default: Insper red
    p <- ggplot2::ggplot(data, ggplot2::aes(x = {{ x }}, y = {{ y }})) +
      ggplot2::geom_col(fill = get_insper_colors("reds1"), position = position, ...)

  } else if (fill_type$type == "static_color") {
    # User-specified static color
    p <- ggplot2::ggplot(data, ggplot2::aes(x = {{ x }}, y = {{ y }})) +
      ggplot2::geom_col(fill = fill_type$value, position = position, ...)

  } else {
    # Variable mapping - use discrete scale (bars are categorical by nature)
    p <- ggplot2::ggplot(data, ggplot2::aes(x = {{ x }}, y = {{ y }}, fill = {{ fill }})) +
      ggplot2::geom_col(position = position, ...) +
      scale_fill_insper_d(palette = palette)
  }

  # ... rest of function (zero line, text, theme, etc.)
}
```

**Breaking changes:**
- Remove `fill_var` parameter → use `fill` with bare column name
- Remove `single_color` parameter → use `fill` with string literal
- Move `...` from scale to geom (consistency improvement)

---

### 2. insper_scatterplot (MODERATE REFACTOR)

**Current signature:**
```r
insper_scatterplot(data, x, y, color = NULL, add_smooth = FALSE,
                   point_size = 2, point_alpha = 1, ...)
```

**New signature:** (NO CHANGE - just implementation)

**Implementation pattern:**
```r
insper_scatterplot <- function(
  data, x, y,
  color = NULL,
  palette = "categorical",  # ADD THIS
  add_smooth = FALSE,
  smooth_method = "lm",
  point_size = 2,
  point_alpha = 1,
  ...
) {
  # Detect color type
  color_quo <- rlang::enquo(color)
  color_type <- detect_aesthetic_type(color_quo, "color", data)

  # Warn if palette specified with static color
  warn_palette_ignored(color_type, palette, "color")

  # Build plot based on type
  if (color_type$type == "missing") {
    # Default: Insper teal
    p <- ggplot2::ggplot(data, ggplot2::aes(x = {{ x }}, y = {{ y }})) +
      ggplot2::geom_point(
        color = get_insper_colors("teals1"),
        size = point_size,
        alpha = point_alpha,
        ...
      )

  } else if (color_type$type == "static_color") {
    # User-specified static color
    p <- ggplot2::ggplot(data, ggplot2::aes(x = {{ x }}, y = {{ y }})) +
      ggplot2::geom_point(
        color = color_type$value,
        size = point_size,
        alpha = point_alpha,
        ...
      )

  } else {
    # Variable mapping - detect continuous vs discrete
    if (color_type$is_continuous) {
      p <- ggplot2::ggplot(data, ggplot2::aes(x = {{ x }}, y = {{ y }}, color = {{ color }})) +
        ggplot2::geom_point(size = point_size, alpha = point_alpha, ...) +
        scale_color_insper_c(palette = palette)
    } else {
      p <- ggplot2::ggplot(data, ggplot2::aes(x = {{ x }}, y = {{ y }}, color = {{ color }})) +
        ggplot2::geom_point(size = point_size, alpha = point_alpha, ...) +
        scale_color_insper_d(palette = palette)
    }
  }

  # ... rest of function (smooth, theme, etc.)
}
```

**Breaking changes:**
- Add `palette` parameter (NEW - enables customization)

---

### 3. insper_timeseries (MODERATE REFACTOR)

**Current signature:**
```r
insper_timeseries(data, x, y, group = NULL, line_width = 0.8,
                  add_points = FALSE, ...)
```

**New signature:**
```r
insper_timeseries(data, x, y, color = NULL, palette = "categorical",
                  line_width = 0.8, add_points = FALSE, ...)
```

**Implementation:** Similar to `insper_scatterplot` but with `geom_line()`.

**Breaking changes:**
- Rename `group` → `color` (semantic clarity)

---

### 4. insper_boxplot (MINOR REFACTOR)

**Current signature:**
```r
insper_boxplot(data, x, y, fill = NULL, add_jitter = NULL,
               add_notch = FALSE, box_alpha = 0.8, ...)
```

**New signature:** (NO CHANGE - just add `palette`)

**Implementation:** Similar to `insper_barplot` but only discrete (boxplots don't use continuous fill).

**Breaking changes:**
- Add `palette` parameter (NEW)

---

### 5. insper_area (MAJOR REFACTOR)

**Current signature:**
```r
insper_area(data, x, y, fill = NULL, stacked = FALSE, area_alpha = 0.9,
            fill_color = get_insper_colors("teals1"), add_line = TRUE,
            line_color = get_insper_colors("teals3"), line_width = 0.8,
            line_alpha = 1, zero = FALSE, ...)
```

**New signature:**
```r
insper_area(data, x, y, fill = NULL, stacked = FALSE,
            palette = "categorical", area_alpha = 0.9,
            fill_color = get_insper_colors("teals1"),  # Static fill (when fill = NULL)
            add_line = TRUE,
            line_color = get_insper_colors("teals3"),  # Static line (when fill = NULL or static)
            line_width = 0.8, line_alpha = 1, zero = FALSE, ...)
```

**Key change:** When `fill` is a variable, automatically apply to BOTH `aes(fill = ...)` AND `aes(color = ...)`:

```r
if (fill_type$type == "variable_mapping") {
  # Apply to BOTH fill and color (for the line)
  p <- ggplot2::ggplot(data, ggplot2::aes(x = {{ x }}, y = {{ y }}, fill = {{ fill }})) +
    ggplot2::geom_area(alpha = area_alpha, position = position, ...) +
    scale_fill_insper_d(palette = palette)

  if (add_line) {
    p <- p +
      ggplot2::geom_line(
        ggplot2::aes(color = {{ fill }}),  # Same variable
        linewidth = line_width,
        alpha = line_alpha,
        position = position
      ) +
      scale_color_insper_d(palette = palette)
  }
}
```

**Breaking changes:**
- Remove `fill_color` parameter → use `fill` with string
- Keep separate `line_color` for static-only cases
- Add `palette` parameter

---

### 6. insper_violin (MINOR REFACTOR)

**Implementation:** Similar to `insper_boxplot`.

---

### 7. insper_histogram (MODERATE REFACTOR)

**Current signature:**
```r
insper_histogram(data, x, fill = NULL, bins = NULL, bin_method = "sturges",
                 fill_color = get_insper_colors("reds1"),
                 border_color = "white", zero = TRUE, ...)
```

**New signature:**
```r
insper_histogram(data, x, fill = NULL, bins = NULL, bin_method = "sturges",
                 palette = "categorical", border_color = "white",
                 zero = TRUE, ...)
```

**Breaking changes:**
- Remove `fill_color` parameter → use `fill` with string
- Add `palette` parameter

---

### 8. insper_density (MAJOR REFACTOR)

**Current signature:**
```r
insper_density(data, x, fill = NULL,
               fill_color = get_insper_colors("teals1"),
               line_color = get_insper_colors("teals3"),
               alpha = 0.6, bandwidth = NULL, adjust = 1,
               kernel = "gaussian", ...)
```

**New signature:**
```r
insper_density(data, x, fill = NULL, palette = "categorical",
               fill_color = get_insper_colors("teals1"),  # Static (when fill = NULL)
               line_color = get_insper_colors("teals3"),  # Static (when fill = NULL or static)
               alpha = 0.6, bandwidth = NULL, adjust = 1,
               kernel = "gaussian", ...)
```

**Implementation:** Similar to `insper_area` - when `fill` is variable, apply to both `aes(fill)` and `aes(color)`.

**Breaking changes:**
- Keep `fill_color`/`line_color` for static-only cases
- Add `palette` parameter

---

### 9. insper_heatmap (NO CHANGES)

Uses continuous scale (`scale_fill_insper_c()`), no smart detection needed.

---

## Edge Cases & Solutions

### Edge Case 1: Column Name = Color Name

**Scenario:**
```r
df <- data.frame(red = 1:10, blue = 11:20, value = rnorm(20))
```

**Solution:**
```r
# Quoted → static color
insper_scatterplot(df, x = red, y = value, color = "red")  # Red points

# Unquoted → variable mapping
insper_scatterplot(df, x = red, y = value, color = red)    # Points colored by 'red' column
```

**Rule:** Strings ALWAYS treated as colors. No ambiguity.

---

### Edge Case 2: Continuous Variable Mapping

**Scenario:**
```r
# hp is continuous (not factor)
insper_scatterplot(mtcars, x = wt, y = mpg, color = hp)
```

**Solution:** Detect variable type in data and apply appropriate scale:
- Numeric + not factor → `scale_color_insper_c()` (continuous)
- Factor or character → `scale_color_insper_d()` (discrete)

**Implementation:** See `color_type$is_continuous` in detection logic.

---

### Edge Case 3: Invalid Color String

**Scenario:**
```r
insper_scatterplot(mtcars, x = wt, y = mpg, color = "bleu")  # Typo
```

**Expected behavior:**
```r
#> Error: `color` = "bleu" is not a valid color
#> ℹ Use a bare column name for variable mapping: `color = column_name`
#> ℹ Or use a valid color name/hex code: `color = "blue"`
#> ℹ See `colors()` for valid color names
```

**Implementation:** `is_valid_color()` checks with `grDevices::col2rgb()`.

---

### Edge Case 4: Palette Specified with Static Color

**Scenario:**
```r
insper_barplot(mtcars, x = cyl, y = mpg, fill = "blue", palette = "bright")
```

**Expected behavior:**
```r
#> Warning: `palette` argument ignored when `fill` is a static color
#> ℹ The `palette` parameter only applies when `fill` is a variable mapping
#> ℹ Remove `palette = "bright"` or use a variable for `fill`
```

**Implementation:** `warn_palette_ignored()` checks aesthetic type.

---

### Edge Case 5: NULL vs Missing

**Scenario:** Default argument is `fill = NULL`.

**Solution:**
```r
# User explicitly passes NULL
insper_barplot(data, x = cyl, y = mpg, fill = NULL)

# User doesn't specify (same result)
insper_barplot(data, x = cyl, y = mpg)
```

Both use `rlang::quo_is_null()` and return `type = "missing"`, applying default color.

---

## Testing Strategy

### Test Coverage Requirements

Each of the 8 updated functions needs comprehensive tests covering:

1. ✅ **Missing parameter** → uses default color
2. ✅ **Static hex color** → `color = "#0000FF"`
3. ✅ **Static named color** → `color = "blue"`
4. ✅ **Variable symbol (discrete)** → `color = Species`
5. ✅ **Variable expression (discrete)** → `color = factor(cyl)`
6. ✅ **Variable symbol (continuous)** → `color = hp` (scatterplot only)
7. ✅ **Column name = color name** → both `color = red` (variable) and `color = "red"` (static)
8. ✅ **Invalid color string** → `color = "bleu"` (should error)
9. ✅ **Palette with static color** → should warn
10. ✅ **Palette with variable** → should NOT warn

**Total test cases:** ~8 functions × 10 tests = **~80 new tests**

### Test File Organization

Update existing test files:
- `tests/testthat/test-plots.R` - main plot function tests
- Add new file: `tests/testthat/test-smart-detection.R` - helper function tests

### Example Test Cases

```r
test_that("insper_barplot handles static fill colors", {
  # Hex color
  p1 <- insper_barplot(mtcars, x = cyl, y = mpg, fill = "#0000FF")
  expect_s3_class(p1, "ggplot")

  # Named color
  p2 <- insper_barplot(mtcars, x = cyl, y = mpg, fill = "blue")
  expect_s3_class(p2, "ggplot")
})

test_that("insper_barplot handles variable mapping", {
  # Discrete variable
  p <- insper_barplot(mtcars, x = cyl, y = mpg, fill = factor(gear))
  expect_s3_class(p, "ggplot")
  expect_true("ScaleDiscrete" %in% class(p$scales$scales[[1]]))
})

test_that("insper_scatterplot handles continuous variable mapping", {
  p <- insper_scatterplot(mtcars, x = wt, y = mpg, color = hp)
  expect_s3_class(p, "ggplot")
  expect_true("ScaleContinuous" %in% class(p$scales$scales[[1]]))
})

test_that("invalid color throws helpful error", {
  expect_error(
    insper_scatterplot(mtcars, x = wt, y = mpg, color = "bleu"),
    "not a valid color"
  )
})

test_that("palette with static color warns", {
  expect_warning(
    insper_barplot(mtcars, x = cyl, y = mpg, fill = "blue", palette = "bright"),
    "palette.*ignored"
  )
})

test_that("column name vs color name disambiguation", {
  df <- data.frame(red = 1:5, blue = 6:10, value = rnorm(10))

  # Bare symbol = variable
  p1 <- insper_scatterplot(df, x = red, y = value, color = red)
  expect_true("ScaleDiscrete" %in% class(p1$scales$scales[[1]]) ||
              "ScaleContinuous" %in% class(p1$scales$scales[[1]]))

  # String = static color
  p2 <- insper_scatterplot(df, x = red, y = value, color = "red")
  expect_s3_class(p2, "ggplot")
})
```

### Visual Regression Tests

Update `tests/testthat/test-visual.R` with `vdiffr` snapshots:

```r
test_that("visual: barplot with static fill", {
  p <- insper_barplot(mtcars, x = cyl, y = mpg, fill = "blue")
  vdiffr::expect_doppelganger("barplot-static-blue", p)
})

test_that("visual: barplot with variable fill", {
  p <- insper_barplot(mtcars, x = cyl, y = mpg, fill = factor(gear))
  vdiffr::expect_doppelganger("barplot-grouped-gear", p)
})
```

---

## Documentation Requirements

### Roxygen Updates for Each Function

**Template for `@param` documentation:**

```r
#' @param fill Fill aesthetic. Accepts either:
#'   \itemize{
#'     \item A bare column name for variable mapping (e.g., \code{fill = Species})
#'     \item A quoted color string for static fill (e.g., \code{fill = "blue"} or \code{fill = "#0000FF"})
#'     \item \code{NULL} (default) to use the default Insper color
#'   }
#'   When mapping a variable, the appropriate scale (\code{scale_fill_insper_d()} or
#'   \code{scale_fill_insper_c()}) is automatically applied based on variable type.
#'
#' @param palette Character. Color palette name to use when \code{fill} is a variable mapping.
#'   Ignored with a warning if \code{fill} is a static color. Default is \code{"categorical"}.
#'   See \code{\link{list_palettes}} for available palettes.
```

### Example Section Updates

**Each function needs examples showing BOTH patterns:**

```r
#' @examples
#' \dontrun{
#' # Basic plot with default color
#' insper_barplot(mtcars, x = cyl, y = mpg)
#'
#' # Static fill color (hex)
#' insper_barplot(mtcars, x = cyl, y = mpg, fill = "#E4002B")
#'
#' # Static fill color (named)
#' insper_barplot(mtcars, x = cyl, y = mpg, fill = "steelblue")
#'
#' # Variable mapping (discrete)
#' insper_barplot(mtcars, x = cyl, y = mpg, fill = factor(gear))
#'
#' # Variable mapping with custom palette
#' insper_barplot(mtcars, x = cyl, y = mpg, fill = factor(gear), palette = "bright")
#'
#' # Continuous variable (scatterplot example)
#' insper_scatterplot(mtcars, x = wt, y = mpg, color = hp)
#' }
```

### README Updates

Update README.md to showcase new API:

```r
## Quick Start

library(insperplot)

# Static colors
insper_scatterplot(mtcars, x = wt, y = mpg, color = "blue")

# Variable mapping
insper_scatterplot(mtcars, x = wt, y = mpg, color = factor(cyl))

# Continuous gradient
insper_scatterplot(mtcars, x = wt, y = mpg, color = hp)
```

---

## Migration Guide

### Breaking Changes Summary

**v2.0.0 introduces breaking changes to parameter naming for consistency and usability.**

| Function | Old Parameters | New Parameters | Migration |
|----------|---------------|----------------|-----------|
| `insper_barplot` | `fill_var`, `single_color` | `fill` (smart) | See below |
| `insper_scatterplot` | N/A | Add `palette` | Non-breaking addition |
| `insper_timeseries` | `group` | `color` | Rename parameter |
| `insper_boxplot` | N/A | Add `palette` | Non-breaking addition |
| `insper_area` | `fill_color` | `fill` (smart) | Use `fill = "color"` |
| `insper_violin` | N/A | Add `palette` | Non-breaking addition |
| `insper_histogram` | `fill_color` | `fill` (smart) | Use `fill = "color"` |
| `insper_density` | `fill_color`, `line_color` | `fill` (smart), keep `line_color` | Use `fill = "color"` |

---

### Migration Examples

#### insper_barplot

**Old (v1.x):**
```r
# Single color bars
insper_barplot(mtcars, x = cyl, y = mpg, single_color = "blue")

# Grouped bars
insper_barplot(mtcars, x = cyl, y = mpg, fill_var = gear)
```

**New (v2.0):**
```r
# Single color bars
insper_barplot(mtcars, x = cyl, y = mpg, fill = "blue")

# Grouped bars
insper_barplot(mtcars, x = cyl, y = mpg, fill = gear)
```

---

#### insper_scatterplot

**Old (v1.x):**
```r
# No way to set static color without default
insper_scatterplot(mtcars, x = wt, y = mpg)

# Grouped by variable
insper_scatterplot(mtcars, x = wt, y = mpg, color = factor(cyl))
```

**New (v2.0):**
```r
# Static color now possible!
insper_scatterplot(mtcars, x = wt, y = mpg, color = "blue")

# Grouped by variable (same)
insper_scatterplot(mtcars, x = wt, y = mpg, color = factor(cyl))

# Continuous gradient (NEW!)
insper_scatterplot(mtcars, x = wt, y = mpg, color = hp)
```

---

#### insper_timeseries

**Old (v1.x):**
```r
insper_timeseries(df, x = date, y = value, group = category)
```

**New (v2.0):**
```r
insper_timeseries(df, x = date, y = value, color = category)
```

---

#### insper_area

**Old (v1.x):**
```r
# Single color area
insper_area(df, x = time, y = value, fill_color = "lightblue")

# Grouped areas
insper_area(df, x = time, y = value, fill = group)
```

**New (v2.0):**
```r
# Single color area
insper_area(df, x = time, y = value, fill = "lightblue")

# Grouped areas (same)
insper_area(df, x = time, y = value, fill = group)
```

---

#### insper_histogram

**Old (v1.x):**
```r
# Custom fill color
insper_histogram(mtcars, x = mpg, fill_color = "steelblue")

# Grouped histogram
insper_histogram(mtcars, x = mpg, fill = factor(cyl))
```

**New (v2.0):**
```r
# Custom fill color
insper_histogram(mtcars, x = mpg, fill = "steelblue")

# Grouped histogram (same)
insper_histogram(mtcars, x = mpg, fill = factor(cyl))
```

---

#### insper_density

**Old (v1.x):**
```r
# Custom colors
insper_density(mtcars, x = mpg,
               fill_color = "lightblue",
               line_color = "darkblue")

# Grouped density
insper_density(mtcars, x = mpg, fill = factor(cyl))
```

**New (v2.0):**
```r
# Custom colors
insper_density(mtcars, x = mpg,
               fill = "lightblue",        # Changed!
               line_color = "darkblue")   # Same

# Grouped density (same)
insper_density(mtcars, x = mpg, fill = factor(cyl))
```

---

### Automated Migration Script (Optional)

Create `data-raw/migrate_v2.R` to help users:

```r
#' Find and suggest replacements for old parameter names
#'
#' Searches R files for old parameter patterns and suggests v2.0 replacements.
#'
#' @param path Character. Path to search (file or directory)
#' @export
suggest_v2_migration <- function(path = ".") {
  cli::cli_h1("insperplot v2.0 Migration Helper")

  # Search patterns
  patterns <- list(
    list(
      old = "fill_var\\s*=",
      new = "fill =",
      func = "insper_barplot"
    ),
    list(
      old = "single_color\\s*=",
      new = "fill =",
      func = "insper_barplot"
    ),
    list(
      old = "group\\s*=",
      new = "color =",
      func = "insper_timeseries"
    ),
    list(
      old = "fill_color\\s*=",
      new = "fill =",
      func = "insper_area, insper_histogram, insper_density"
    )
  )

  # Scan files and report
  # ... implementation ...
}
```

---

## Next Steps

### Immediate Tasks (Current Session)

1. **Complete insper_histogram()** (~30 minutes)
   - Remove `fill_color` parameter
   - Add smart detection for `fill`
   - Add `palette` parameter
   - Test with 5-6 scenarios

2. **Update insper_area()** (~1 hour)
   - Keep `fill_color` and `line_color` for static-only fallback
   - Add smart detection for `fill`
   - When `fill` is variable, auto-propagate to line `color`
   - Add `palette` parameter
   - Test dual aesthetic behavior

3. **Update insper_density()** (~1 hour)
   - Similar to `insper_area()`
   - Smart detection for `fill`
   - Auto-propagate to line `color` when variable
   - Test with continuous and discrete variables

### Documentation Phase (~2 hours)

4. **Update NEWS.md**
   - Add comprehensive v2.0.0 breaking changes section
   - Include before/after migration examples for each function
   - List all removed parameters
   - Document new capabilities

5. **Update README.md**
   - Replace examples with new smart detection syntax
   - Show both static and variable usage
   - Highlight continuous variable support

6. **Regenerate all documentation**
   - Run `devtools::document()`
   - Verify all `.Rd` files are correct
   - Check cross-references

### Validation Phase (~2 hours)

7. **Create comprehensive test suite**
   - Write formal tests for all 5 updated functions (boxplot, violin, histogram, area, density)
   - Target: ~50 new test cases
   - Include visual regression tests with vdiffr

8. **Run full package validation**
   - `devtools::check()` - must pass with 0/0/0
   - `devtools::test()` - all tests must pass
   - `covr::package_coverage()` - maintain >80%
   - Manual testing in clean R session

9. **Update package metadata**
   - DESCRIPTION: version 1.2.0 → 2.0.0
   - DESCRIPTION: update date
   - Build pkgdown site
   - Create git tag v2.0.0

### Estimated Time Remaining

| Task | Time | Status |
|------|------|--------|
| insper_histogram | 30 min | 🔄 In Progress |
| insper_area | 1 hour | ⏳ Pending |
| insper_density | 1 hour | ⏳ Pending |
| Documentation | 2 hours | ⏳ Pending |
| Testing & Validation | 2 hours | ⏳ Pending |
| **Total** | **~6.5 hours** | **37% remaining** |

---

## Implementation Checklist

### Phase 1-6: Core Functions ✅ COMPLETE

Execute in this exact order:

### Phase 1: Helper Functions ✅ COMPLETE
- [x] Implement `is_valid_color()` - R/utils.R:892-911
- [x] Implement `detect_aesthetic_type()` - R/utils.R:946-990
- [x] Implement `warn_palette_ignored()` - R/utils.R:1012-1020
- [x] Add roxygen documentation for internal functions
- [x] Run `devtools::document()`

### Phase 2: Test Helper Functions ✅ COMPLETE
- [x] Create `tests/testthat/test-smart-detection.R` (290 lines)
- [x] Test `is_valid_color()` with hex, named, invalid colors
- [x] Test `detect_aesthetic_type()` with all cases
- [x] Test `warn_palette_ignored()` warning behavior
- [x] Run `devtools::test(filter = "smart-detection")` - **86 tests passing**

### Phase 3-7: Update Plot Functions ✅ 5 of 8 COMPLETE

**Completed Functions:**

- [x] `insper_scatterplot` - R/plots.R:213-447 - **Tested (12 scenarios)**
- [x] `insper_barplot` - R/plots.R:1-211 - **Tested (8 scenarios)**
- [x] `insper_timeseries` - R/plots.R:449-584 - **Tested (6 scenarios)**
- [x] `insper_boxplot` - R/plots.R:586-713 - **Implemented**
- [x] `insper_violin` - R/plots.R:949-1065 - **Implemented**

**In Progress:**

- [ ] `insper_histogram` - R/plots.R:1068+ - **IN PROGRESS**
  - [ ] Remove `fill_color` parameter
  - [ ] Add smart detection logic
  - [ ] Add palette parameter
  - [ ] Test with 5-6 scenarios

**Remaining:**

- [ ] `insper_area` - **Complex dual aesthetic**
  - [ ] Keep `fill_color`/`line_color` for static fallback
  - [ ] Add smart detection for `fill`
  - [ ] Auto-propagate variable fill to line color
  - [ ] Add palette parameter
  - [ ] Test propagation behavior

- [ ] `insper_density` - **Complex dual aesthetic**
  - [ ] Similar changes to `insper_area`
  - [ ] Smart detection for `fill`
  - [ ] Auto-propagate to line color
  - [ ] Test with continuous and discrete

### Phase 8: Documentation ⏳ PENDING
- [ ] Update README.md with new examples
- [ ] Update NEWS.md with comprehensive v2.0.0 breaking changes section
  - [ ] List all parameter changes
  - [ ] Provide before/after migration examples
  - [ ] Document new capabilities (static colors, continuous variables)
- [ ] Update vignettes if they use old parameters
- [ ] Regenerate all `.Rd` files: `devtools::document()`
- [ ] Verify cross-references are correct

### Phase 9: Testing ⏳ PENDING
- [ ] Write formal tests for updated functions:
  - [ ] insper_boxplot (~10 tests)
  - [ ] insper_violin (~10 tests)
  - [ ] insper_histogram (~10 tests)
  - [ ] insper_area (~12 tests - dual aesthetic)
  - [ ] insper_density (~12 tests - dual aesthetic)
- [ ] Update visual regression tests (vdiffr)
- [ ] Run full test suite: `devtools::test()`
- [ ] Verify all tests pass

### Phase 10: Package Validation ⏳ PENDING
- [ ] Update DESCRIPTION version to 2.0.0
- [ ] Update DESCRIPTION date
- [ ] Run `devtools::check()` - must pass with 0/0/0
- [ ] Run `covr::package_coverage()` - maintain >80% coverage
- [ ] Run `lintr::lint_package()` - fix any style issues
- [ ] Install package locally: `devtools::install()`
- [ ] Test interactively in clean R session
- [ ] Run all examples from documentation

### Phase 11: Release Preparation ⏳ PENDING
- [ ] Build pkgdown site: `pkgdown::build_site()`
- [ ] Review generated website for correctness
- [ ] Commit all changes with descriptive messages
- [ ] Create annotated tag: `git tag -a v2.0.0 -m "Release v2.0.0"`
- [ ] Push to repository

---

## Current Status Summary

**Completed**:
- ✅ All helper functions (3 functions, 86 tests)
- ✅ 5 of 8 plot functions (scatterplot, barplot, timeseries, boxplot, violin)
- ✅ Manual testing for 3 functions (26 test scenarios total)
- ✅ First checkpoint commit (c7a86a5)

**In Progress**:
- 🔄 insper_histogram() - removing fill_color parameter

**Remaining**:
- ⏳ 2 plot functions (area, density) - ~2 hours
- ⏳ Documentation updates (NEWS.md, README) - ~2 hours
- ⏳ Comprehensive testing (~50 new tests) - ~2 hours
- ⏳ Final validation and release prep - ~30 minutes

**Total Work**: ~63% complete, ~6.5 hours remaining

**Files Modified So Far**:
- R/utils.R: +140 lines (3 helper functions)
- R/plots.R: ~800 lines modified (5 functions refactored)
- tests/testthat/test-smart-detection.R: +290 lines (new file)
- man/*.Rd: 8 files updated/created
- claude/*.md: 3 planning/progress documents

**Next Session Goals**:
1. Complete insper_histogram() (30 min)
2. Complete insper_area() (1 hour)
3. Complete insper_density() (1 hour)
4. Create checkpoint commit
5. Begin documentation phase

---

## Notes for Implementer

### Estimated Effort
- Helper functions: **2 hours**
- Helper tests: **1 hour**
- Per-function updates (8 functions): **8 × 2 hours = 16 hours**
- Documentation: **3 hours**
- Testing & validation: **4 hours**

**Total: ~26 hours** of focused development

### Common Pitfalls to Avoid

1. **Don't evaluate quosures too early** - Keep them as quosures until detection
2. **Check for NULL data** - Some functions might call helpers before data available
3. **Test with tibbles AND data.frames** - Ensure `eval_tidy` works with both
4. **Watch out for NSE edge cases** - Test with piped data, expressions, etc.
5. **Maintain backward compat in examples** - Don't update examples until ready to release

### Success Criteria

✅ All tests pass (`devtools::test()`)
✅ No check errors/warnings (`devtools::check()`)
✅ Coverage maintained >80% (`covr::package_coverage()`)
✅ All examples run without errors
✅ Documentation renders correctly
✅ pkgdown site builds successfully
✅ Interactive testing confirms expected behavior

---

## Future Enhancements (Post v2.0.0)

### Potential Additions

1. **Smart shape detection** for scatterplot (e.g., `shape = 17` vs `shape = category`)
2. **Gradient direction control** for continuous scales
3. **Alpha blending** smart detection
4. **Multiple aesthetics** simultaneously (e.g., `color = group1, shape = group2`)

### Deferred Items

- **Palette customization API** - Let users define custom palettes
- **Theme variants** - More specialized themes for different output formats
- **Animation support** - Integration with gganimate
- **Interactive plots** - Integration with plotly

---

## Questions & Decisions Log

| Date | Question | Decision | Rationale |
|------|----------|----------|-----------|
| 2025-10-24 | Single parameter or separate color/fill? | Single smart parameter per function | Simpler API, function-appropriate aesthetic |
| 2025-10-24 | Handle palette with static color? | Show warning | Educates users, doesn't break execution |
| 2025-10-24 | Automatic color→fill propagation? | Yes, for area/density plots | Simplifies common use case |
| 2025-10-24 | Version number? | v2.0.0 | Breaking changes require major bump |
| 2025-10-24 | Column name = color name? | Quoted = color, bare = column | Clear, explicit, no ambiguity |

---

**Document Version**: 1.0
**Last Updated**: 2025-10-24
**Status**: Ready for Implementation
