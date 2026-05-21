# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Package Overview

**insperplot** is an R package that extends ggplot2 with Insper Instituto de Ensino e Pesquisa's visual identity. It provides custom themes, color palettes, scales, and specialized plotting functions for academic and institutional use.

## Common Development Commands

### Testing
```bash
# Run all tests
Rscript -e "devtools::test()"

# Run tests with coverage report
Rscript -e "covr::package_coverage()"

# Run specific test file
Rscript -e "testthat::test_file('tests/testthat/test-theme.R')"

# Check visual regression tests
Rscript -e "devtools::test(filter = 'visual')"
```

### Building and Checking
```bash
# Full R CMD check (must pass with 0 errors, 0 warnings, 0 notes)
Rscript -e "devtools::check()"

# Build package documentation
Rscript -e "devtools::document()"

# Build pkgdown site
Rscript -e "pkgdown::build_site()"

# Install development version locally
Rscript -e "devtools::install()"
```

### Code Quality
```bash
# Check for code style issues
Rscript -e "lintr::lint_package()"

# Auto-format code (if styler is used)
Rscript -e "styler::style_pkg()"
```

## Architecture and Code Organization

### Core Philosophy
This package follows **modern R development best practices** (2025 standards):
- Native pipe `|>` throughout (NOT magrittr `%>%`)
- Modern tidyverse patterns (dplyr 1.1+ with `.by`, `reframe()`, `pick()`)
- Modern rlang patterns (embrace `{{}}`, injection `!!`, splicing `!!!`)
- Font handling via `systemfonts + ragg` (NOT showtext/extrafont due to DPI conflicts)

### Key R Files Structure

- `R/theme_insper.R` — `theme_insper()` and internal `detect_font()` (theme variants live here, not a separate file)
- `R/plot-<name>.R` — one file per exported plot function (`plot-area.R`, `plot-barplot.R`, `plot-boxplot.R`, `plot-density.R`, `plot-heatmap.R`, `plot-histogram.R`, `plot-scatterplot.R`, `plot-timeseries.R`, `plot-violin.R`). Add new plots as a new file in this pattern.
- `R/palette-utils.R` — exported `insper_palette()`, `show_insper_palettes()`, and internal `get_insper_colors()`, `palette_metadata()`
- `R/insper_palette.R` — internal `insper_pal()` helper used by scales
- `R/scales.R` — `scale_color_insper_{c,d}()` / `scale_fill_insper_{c,d}()` (+ `colour` aliases)
- `R/utils.R` — `save_insper_plot()`, `format_num_br()`, `import_insper_fonts()`, `setup_insper_fonts()`, plus internal helpers: `detect_aesthetic_type()`, `warn_palette_ignored()`, `calculate_luminance()`, `get_contrast_text_color()`, `has_insper_fonts()`, `is_valid_color()`
- `R/data.R` — dataset documentation; data lives in `data/` and `R/sysdata.rda`
- `R/zzz.R` — `.onAttach()` startup message only (no font auto-import)
- `R/globals.R` — `utils::globalVariables()` declarations

## Development Guidelines

> Full coding standards are documented in [`claude/coding_guidelines.md`](claude/coding_guidelines.md) and [`claude/modern-error-handling-in-r.md`](claude/modern-error-handling-in-r.md). The rules below are the package-critical highlights; consult those files for complete guidance.

### Code Style (see `claude/coding_guidelines.md`)
1. **Always use native pipe `|>`** - NEVER use `%>%`
2. **Use modern dplyr patterns**: `.by` for grouping (not `group_by() |> ... |> ungroup()`)
3. **Use rlang correctly**:
   - `{{}}` (embrace) for forwarding function arguments
   - `!!` for single injection, `!!!` for splicing
   - `.data[[]]` for programmatic column access
4. **Use cli package for messages**: `cli::cli_abort()`, `cli::cli_warn()`, `cli::cli_alert_*()`
5. **Snake_case for everything** except S3 methods
6. **Type-stable outputs**: prefer `map_dbl()` over `sapply()`
7. **Join syntax**: use `join_by()` not `c("a" = "b")` character vectors
8. **Pipe chains**: max 5–7 steps; break longer chains into named intermediate objects

### Error Handling (see `claude/modern-error-handling-in-r.md`)
- **Default**: use `rlang::try_fetch()` instead of `tryCatch()` — preserves call stack for `rlang::last_trace()`
- **Error chaining**: wrap low-level errors with `rlang::abort(..., parent = cnd)` to attach context without losing the original trace
- **Mapping**: use `purrr::possibly()` (skip failures, return default) or `purrr::safely()` (keep both result and error) when iterating over vectors
- **Cleanup**: keep `on.exit()` or `tryCatch(..., finally = ...)` for resource cleanup — `try_fetch()` has no `finally`
- **Warnings without stopping**: keep `withCallingHandlers()` to record warnings while letting execution continue
- **Avoid**: `try()` + `inherits(result, "try-error")`, nested `tryCatch`, and `paste("Context:", e$message)` for wrapping

### Testing Requirements
- All new functions must have tests in `tests/testthat/test-*.R`
- Aim for >80% code coverage
- Use `vdiffr` for visual regression tests of plots
- Test both happy path and error conditions
- Font tests use helper in `tests/testthat/helper-fonts.R`

### Documentation Requirements
- All exported functions must have roxygen2 documentation
- Include `@family` tag (themes, colors, scales, plots, utilities)
- Include `@examples` with all exported functions. If examples have dependencies, like custom fonts, use `@examplesIf has_insper_fonts()` to avoid errors. If examples might break things use `\dontrun{}` to avoid errors (e.g. `setup_insper_fonts()`).
- Use `@param` with `<[data-masked]>` for rlang functions
- Include `@seealso` cross-references

**When making breaking changes:**
1. Deprecate in one release (show warnings, update NEWS.md)
2. Remove in next release
3. Provide clear migration guide in NEWS.md
4. Update all examples, tests, vignettes, README

## Package Data Management

### Creating/Updating Datasets
```bash
# Run dataset creation scripts (they save to data/)
Rscript data-raw/datasets.R

# Document datasets in R/data.R with full roxygen2
# Include: @format, @source, @details, @examples, @seealso
```

### Logo and Visual Assets
```bash
# Regenerate package logo
Rscript data-raw/create_logo.R

# Creates man/figures/logo.png
# Uses hexSticker, theme_insper(), and Insper colors
```

### Color Palette Definition
```bash
# Color palettes defined in data-raw/create_colors_and_palettes.R
# Creates R/sysdata.rda with insper_colors list
# Updates should maintain backward compatibility with old names
```

## Common Workflows

### Adding a New Color Palette
1. Edit `data-raw/create_colors_and_palettes.R` to add palette definition
2. Run `Rscript data-raw/create_colors_and_palettes.R` to regenerate `R/sysdata.rda`
3. Update `insper_palette()` documentation with new palette name
4. Add tests in `tests/testthat/test-colors.R`
5. Update `show_insper_palettes()` to support new palette (if special handling needed)

### Adding a New Plot Function
1. Create a new file `R/plot-<name>.R` (one plot function per file — see existing `plot-barplot.R`, `plot-scatterplot.R`, etc.)
2. Use `rlang::enquo()` + `rlang::quo_is_null()` for optional aesthetics
3. Apply `theme_insper()` as final layer
4. Add roxygen2 documentation with `@family plots`
5. Add tests in `tests/testthat/test-plots.R` (and `test-smart-detection.R` if the function uses `detect_aesthetic_type()`)
6. Add visual regression tests in `tests/testthat/test-visual.R`
7. Update `_pkgdown.yml` to include in "Plot Functions" section

### Adding a New Theme Variant
1. Add the function in `R/theme_insper.R` (theme variants live alongside the base theme — there is no separate `theme_variants.R`)
2. Build on `theme_insper()` using `%+replace%` operator
3. Follow font detection pattern with `detect_font()`
4. Add comprehensive parameter validation
5. Add tests in `tests/testthat/test-theme.R`
6. Update `_pkgdown.yml` to include in "Themes" section

## Important Constraints and Gotchas

### Font-Related Issues
- Font setup is the #1 user pain point - setup wizard helps
- Never assume fonts are installed - always use fallback chains
- Test theme functions without fonts installed (use system defaults)
- `import_insper_fonts()` must be called each session (not persistent)

### ggplot2 Integration
- All plot functions return ggplot objects (composable with `+`)
- Don't capture user's ggplot2 calls - let them add layers
- Theme functions use `%+replace%` not `+` to avoid accumulation
- Use `ggplot2::` prefix for all ggplot2 functions in package code

### rlang and Data Masking
- Plot functions accept both bare names and tidy-eval expressions
- Use `rlang::enquo()` to capture, `rlang::quo_is_null()` to check
- Use `{{}}` when passing to dplyr/ggplot2 functions
- Never use string parsing or `eval(parse())` patterns

### Brazilian Localization
- Formatter functions default to Brazilian conventions (comma decimal, period thousands)
- Caption function defaults to Portuguese (`lang = "pt"`)
- Consider adding English alternatives when appropriate

### Package Load Behavior (R/zzz.R)
- `.onAttach()` prints a startup message pointing users at `setup_insper_fonts()` / `import_insper_fonts()`
- Fonts are NOT auto-imported on load — users must call the setup functions explicitly each session

### Smart Aesthetic Detection (R/utils.R)
- Plot functions that accept a `color`/`fill` argument call `detect_aesthetic_type()` to distinguish a mapped variable from a constant color string
- When a user passes a constant color but also a palette, `warn_palette_ignored()` emits a `cli::cli_warn()` so the palette isn't silently dropped
- Use these helpers in any new plot function that takes optional color aesthetics

### Contrast-Aware Text on Bars (R/utils.R)
- `calculate_luminance()` + `get_contrast_text_color()` pick white or dark text per-bar based on fill luminance
- Used by `insper_barplot()` for stacked/filled variants; reuse for any plot that overlays text labels on colored shapes

## pkgdown Website Structure

The package website (_pkgdown.yml) organizes functions into categories:
- **Themes**: Theme functions and font setup utilities
- **Colors and Palettes**: Color access and palette functions
- **ggplot2 Scales**: Scale functions for continuous/discrete data
- **Plot Functions**: High-level plotting functions
- **Utilities**: Formatters, caption builder, save function
- **Data**: Package datasets

Website uses Insper colors in theme (primary: #E4002B, secondary: #009491).
