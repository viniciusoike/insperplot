# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Package Overview

**insperplot** is an R package that extends ggplot2 with Insper Instituto de Ensino e Pesquisa's visual identity. It provides custom themes, color palettes, scales, and specialized plotting functions for academic and institutional use.

**Key Info:**
- Version: 1.3.3 (stable lifecycle)
- License: MIT
- Minimum R version: 4.1.0
- Main dependencies: ggplot2 (≥3.4.0), rlang (≥1.0.0), scales (≥1.2.0), cli
- Testing: testthat 3rd edition with comprehensive test coverage

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

**Theme System (`R/theme_insper.R`)**:
- `theme_insper()`: Main theme with flexible grid/border/alignment options
- `theme_insper_minimal()`, `theme_insper_presentation()`, `theme_insper_print()`: Theme variants
- `detect_font()`: Internal font fallback chain (Georgia → EB Garamond → Playfair Display → serif)
- Font detection uses `systemfonts` package to check local installation

**Color System (`R/utils.R`, `R/insper_palette.R`, `R/palette-utils.R`)**:
- `show_insper_colors()`: Base color extraction (NOT `insper_col()` - removed in v1.0.0)
- `insper_pal()`: Palette generator with discrete/continuous support
- Palettes organized by type: sequential (reds, oranges, teals, grays), diverging (red_teal, diverging), qualitative (main, bright, contrast)
- IMPORTANT: Old palette names like `reds_seq` deprecated → use `reds` (warnings until v1.0.0)

**Scales (`R/scales.R`)**:
- `scale_color_insper_d()` / `scale_fill_insper_d()`: Discrete scales
- `scale_color_insper_c()` / `scale_fill_insper_c()`: Continuous scales
- CRITICAL: Old `scale_color_insper()` removed in v1.0.0 - must use `_d` or `_c` suffix

**Plotting Functions (`R/plots.R`)**:
- 10 high-level plotting functions: barplot, scatterplot, timeseries, area, lollipop, boxplot, violin, heatmap, histogram, density
- All follow pattern: accept data + aesthetics, apply `theme_insper()`, return ggplot object
- NO title/subtitle/caption parameters (removed in v0.7.0) - users must use `+ labs()` instead
- NO orientation flip parameters (removed in v0.7.0) - users swap x/y or use `+ coord_flip()`

**Utilities (`R/utils.R`)**:
- Font setup: `setup_insper_fonts()` (interactive wizard), `check_insper_fonts()`, `import_insper_fonts()` (showtext fallback)
- Graphics: `use_ragg_device()` (ragg setup helper), `save_insper_plot()` (auto-detects ragg)
- Brazilian formatters: `format_brl()`, `format_percent_br()`, `format_num_br()`
- Caption builder: `insper_caption()` with Portuguese/English support

**Data (`R/data.R`, `data/`):**
- 4 datasets: `macro_series` (Brazilian economic indicators), `rec_buslines`/`rec_passengers` (Recife public transport), `spo_metro` (São Paulo metro ridership)
- All datasets documented with complete metadata, sources, and usage examples

### Font Handling Architecture (Critical)

**Modern Approach (Recommended):**
1. Users install fonts locally (Georgia, Inter, EB Garamond, Playfair Display)
2. Install `ragg` package
3. Set RStudio backend to AGG
4. Fonts work automatically via `systemfonts` - no per-session loading

**Fallback Approach:**
- `import_insper_fonts()` uses `showtext` + `sysfonts` to load fonts from Google Fonts
- Sets `options(insperplot.fonts_loaded = TRUE)` to track state
- Theme functions check this option to enable/disable font detection

**Why This Matters:**
- Package moved away from showtext in v0.4.0 due to DPI conflicts
- hrbrthemes (inspiration package) was removed from CRAN for extrafont issues
- Current approach eliminates these problems entirely

## Development Guidelines

### Code Style (FROM claude/coding_guidelines.md)
1. **Always use native pipe `|>`** - NEVER use `%>%`
2. **Use modern dplyr patterns**: `.by` for grouping (not `group_by() |> ... |> ungroup()`)
3. **Use rlang correctly**:
   - `{{}}` (embrace) for forwarding function arguments
   - `!!` for single injection, `!!!` for splicing
   - `.data[[]]` for programmatic column access
4. **Use cli package for messages**: `cli::cli_abort()`, `cli::cli_warn()`, `cli::cli_alert_*()`
5. **Snake_case for everything** except S3 methods
6. **Type-stable outputs**: prefer `map_dbl()` over `sapply()`

### Testing Requirements
- All new functions must have tests in `tests/testthat/test-*.R`
- Aim for >80% code coverage
- Use `vdiffr` for visual regression tests of plots
- Test both happy path and error conditions
- Font tests use helper in `tests/testthat/helper-fonts.R`

### Documentation Requirements
- All exported functions must have roxygen2 documentation
- Include `@family` tag (themes, colors, scales, plots, utilities)
- Include `@examples` with `\dontrun{}` if needed
- Use `@param` with `<[data-masked]>` for rlang functions
- Include `@seealso` cross-references

### Breaking Change Protocol (Critical)
This package follows a deliberate API evolution:
- v0.7.0: Removed orientation/label parameters from plot functions
- v0.8.0: Renamed scale functions, deprecated `insper_col()`
- v0.9.0: Simplified palette names
- v1.0.0+: Removed deprecated functions, achieved stable API

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
# Color palettes defined in data-raw/create_palettes.R
# Creates R/sysdata.rda with insper_colors list
# Updates should maintain backward compatibility with old names
```

## Common Workflows

### Adding a New Color Palette
1. Edit `data-raw/create_palettes.R` to add palette definition
2. Run `Rscript data-raw/create_palettes.R` to regenerate `R/sysdata.rda`
3. Update `insper_pal()` documentation with new palette name
4. Add tests in `tests/testthat/test-colors.R`
5. Update `show_insper_palette()` to support new palette (if special handling needed)

### Adding a New Plot Function
1. Create function in `R/plots.R` following existing patterns
2. Use `rlang::enquo()` + `rlang::quo_is_null()` for optional aesthetics
3. Apply `theme_insper()` as final layer
4. Add roxygen2 documentation with `@family plots`
5. Add tests in `tests/testthat/test-plots.R`
6. Add visual regression tests in `tests/testthat/test-visual.R`
7. Update `_pkgdown.yml` to include in "Plot Functions" section

### Adding a New Theme Variant
1. Create function in `R/theme_variants.R` or `R/theme_insper.R`
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
- `.onLoad()` attempts to load fonts automatically via `import_insper_fonts()`
- Fails silently if showtext/sysfonts unavailable
- This provides best UX for users with showtext installed

## pkgdown Website Structure

The package website (_pkgdown.yml) organizes functions into categories:
- **Themes**: Theme functions and font setup utilities
- **Colors and Palettes**: Color access and palette functions
- **ggplot2 Scales**: Scale functions for continuous/discrete data
- **Plot Functions**: High-level plotting functions
- **Utilities**: Formatters, caption builder, save function
- **Data**: Package datasets

Website uses Insper colors in theme (primary: #E4002B, secondary: #009491).

## Recent Major Changes (v1.3.x)

**v1.3.3 (Latest):**
- Fixed parameter naming in `insper_density()`: `bandwidth` → `bw` for ggplot2 consistency
- Comprehensive test coverage for all plot functions (100% coverage milestone)
- Added tests for `insper_density()` and `insper_histogram()`

**v1.3.2:**
- Added `get_palette_colors()` function for direct palette color extraction
- Improved palette utilities

**Earlier Breaking Changes (v0.9.0 - v1.0.0):**
- Removed `scale_color_insper()` / `scale_fill_insper()` - use `_d` or `_c` suffix
- Removed `insper_col()` - use `show_insper_colors()`
- Simplified palette names: `reds_seq` → `reds`, `diverging_red_teal` → `red_teal`, etc.
- All deprecated functions removed; API now stable

## Future Considerations

Based on git log and current state:
1. Consider CRAN submission after v1.0.0 (when API stabilized)
2. May need to expand theme variants for specific use cases (poster, slides variations)
3. Consider adding more Brazilian economic/social datasets
4. Monitor ggplot2 evolution for coord_flip() full deprecation
5. Watch for ragg/systemfonts becoming standard (may simplify font setup)
