# insperplot Modernization Plan: v0.1.0 → v1.0.0

## 🎯 Overview
Transform insperplot into a professional, well-documented ggplot2 theme package that reflects Insper's visual identity while following modern R development best practices.

---

## 📦 **v0.2.0 - Foundation & Cleanup** (Estimated: 2-3 hours)

### 1. Git & GitHub Setup
- Initialize git repository
- Create `.gitignore` for R packages
- Set up GitHub repository
- Add **disclaimer** in README: "This is an unofficial package created by an Insper employee, not an official Insper product"
- Configure GitHub Actions for R CMD check

### 2. Code Cleanup & Modernization
- **Fix duplicate code** in `DATASET.R` (has duplicate palette definitions)
- **Fix duplicate functions** in `plots.R` (two `insper_barplot` definitions)
- **Modernize pipes**: Replace `%>%` with `|>` throughout codebase
- **Update DESCRIPTION**: Replace placeholder author info, add proper URLs
- **Remove deprecated patterns**: Fix `dplyr %>%` import in plots.R

### 3. Package Structure
- Add `README.Rmd` with installation, quickstart, and disclaimer
- Add `NEWS.md` for changelog
- Create `.Rbuildignore` properly
- Add `cran-comments.md` template

### 4. Validation
- Run `devtools::check()` - fix all errors/warnings
- Run `devtools::spell_check()`
- Run `goodpractice::gp()`

---

## 📚 **v0.3.0 - Documentation & Testing** (Estimated: 3-4 hours)

### 1. Complete Documentation
- **Verify all exported functions** have complete roxygen2 docs
- Add `@family` tags to group related functions
- Document utility functions properly (format_brl, format_percent_br, format_num_br)
- Add package-level documentation (`package.R`)
- Create logo using `hexSticker` package

### 2. Testing Infrastructure
- Set up `testthat` framework
- Write tests for:
  - `theme_insper()` with different parameters
  - Color palette functions
  - Scale functions
  - Utility functions (formatters, caption builder)
  - Plot functions (basic functionality)
- Target: 80%+ code coverage with `covr`

### 3. Examples & Data
- Add example dataset (similar to metro_sp data)
- Document all datasets properly
- Ensure all examples run without errors
- Add `\donttest{}` where appropriate

### 4. Validation
- Run `devtools::check()` - 0 errors, 0 warnings
- Check test coverage with `covr::package_coverage()`

---

## 🎨 **v0.4.0 - Visual Identity Enhancement** (Estimated: 2-3 hours)

### 1. Font & Typography
- Verify DIN Alternate is correct Insper font (or update)
- Add font installation helper function
- Implement font fallbacks for systems without custom fonts
- Add `extrafont` or `systemfonts` integration

### 2. Color Palette Refinement
- Clean up `insper_colors` list (remove duplicates)
- Add color accessibility checks
- Create palette preview function improvements
- Add colorblind-friendly palette option
- Document color meanings/use cases

### 3. Theme Variants
- Create `theme_insper_minimal()` - ultra-clean variant
- Create `theme_insper_grid()` - grid-focused variant
- Create `theme_insper_presentation()` - for slides
- Create `theme_insper_print()` - optimized for printing

### 4. Validation
- Visual regression tests with `vdiffr`
- Check all theme variants render correctly
- Run `devtools::check()`

---

## 📊 **v0.5.0 - Enhanced Plotting Functions** (Estimated: 3-4 hours)

### 1. Modernize Existing Plot Functions
- Apply modern tidyverse patterns (`.by`, `pick()`, `reframe()`)
- Use `{{}}` properly for data-masking
- Add proper input validation with `cli` messages
- Ensure all functions follow coding guidelines

### 2. New Plot Functions
- `insper_lollipop()` - lollipop charts
- `insper_area()` - area charts for time series
- `insper_boxplot()` - violin plots
- `insper_waffle()` - waffle/square pie charts

### 3. Export Enhancement
- Improve `save_insper_plot()` function
- Add `finalise_plot()` (inspired by bbplot) for adding Insper logo/branding
- Support multiple output formats (PNG, PDF, SVG)
- Add preset dimensions (social media, presentation, publication)

### 4. Validation
- Test all plot functions with various inputs
- Add visual regression tests
- Run `devtools::check()`

---

## 📖 **v0.6.0 - Vignettes & Examples** (Estimated: 4-5 hours)

### 1. Create Vignettes
- **"Getting Started with insperplot"** - basic usage, installation, fonts
- **"Color Palettes and Scales"** - comprehensive palette guide
- **"Creating Publication-Ready Plots"** - complete workflow
- **"Customizing Insper Themes"** - advanced theme modifications

### 2. Gallery & Examples
- Create comprehensive example gallery
- Add real-world use cases (economic data, academic papers)
- Include before/after comparisons
- Add accessibility considerations guide

### 3. Reference Documentation
- Create cheat sheet (1-page PDF)
- Add function reference with categories
- Include color palette reference card

### 4. Validation
- Build vignettes successfully
- Check all code chunks run
- Run `devtools::check()`

---

## 🌐 **v0.7.0 - pkgdown Website** (Estimated: 2-3 hours)

### 1. Setup pkgdown
- Run `usethis::use_pkgdown()`
- Configure `_pkgdown.yml` with Insper colors
- Set up GitHub Pages deployment
- Add custom CSS matching Insper style

### 2. Website Content
- Customize homepage with package overview
- Add "Get Started" article
- Add logo and favicon
- Create articles from vignettes
- Add gallery page with plot examples

### 3. Branding
- Use Insper colors in website theme
- Add footer with disclaimer
- Link to GitHub repo
- Add contribution guidelines

### 4. Deployment
- Deploy to GitHub Pages
- Test website on different devices
- Add website URL to DESCRIPTION

---

## 🔧 **v0.8.0 - Advanced Features** (Estimated: 3-4 hours)

### 1. Scale Enhancements
- Add `scale_*_insper_c()` for continuous scales
- Add `scale_*_insper_d()` for discrete scales
- Add `scale_*_insper_b()` for binned scales
- Implement proper scale limits and breaks

### 2. Utility Functions
- Add `set_insper_theme()` - set as default theme
- Add `theme_insper_update()` - modify existing theme
- Add `gg_insper_save()` - enhanced save with auto-sizing
- Add label helper functions (spell check, formatting)

### 3. Brazilian Localization
- Enhance Portuguese language support
- Add Brazilian number/date formatters
- Add economic indicators formatters (IPCA, SELIC, etc.)
- Month/date labels in Portuguese

### 4. Validation
- Test all new functions
- Update documentation
- Run `devtools::check()`

---

## 🎓 **v0.9.0 - Educational Resources** (Estimated: 2-3 hours)

### 1. Tutorials
- Create R Markdown tutorial templates
- Add Quarto template for reports
- Add RStudio snippets for common patterns

### 2. Documentation Polish
- Review all documentation for clarity
- Add cross-references between functions
- Ensure consistent terminology
- Add troubleshooting section

### 3. Community
- Add `CONTRIBUTING.md`
- Add `CODE_OF_CONDUCT.md`
- Create issue templates
- Add pull request template

### 4. Accessibility
- Add accessibility vignette
- Document colorblind-safe palettes
- Add alt-text guidelines for plots
- Test with screen readers

---

## 🚀 **v1.0.0 - Launch** (Estimated: 2-3 hours)

### 1. Final Validation
- Run `devtools::check()` - **0 errors, 0 warnings, 0 notes**
- Run `devtools::check_win_devel()`
- Run `rhub::check_for_cran()`
- Achieve 90%+ test coverage
- Run reverse dependency checks

### 2. Documentation Review
- Proofread all documentation
- Verify all examples work
- Update all version numbers
- Finalize NEWS.md

### 3. Polish
- Final pkgdown site update
- Create release announcement
- Prepare presentation/demo
- Create social media graphics

### 4. Release
- Tag v1.0.0 in git
- Create GitHub release
- Deploy final website
- Share with Insper community
- *Optional:* Submit to CRAN

---

## 📋 Summary Checklist

**By v1.0.0, the package will have:**
- ✅ GitHub repository with CI/CD
- ✅ pkgdown website hosted on GitHub Pages
- ✅ Minimum 2-3 comprehensive vignettes
- ✅ 90%+ test coverage
- ✅ All functions documented with examples
- ✅ `devtools::check()` returns 0 errors, 0 warnings
- ✅ Modern tidyverse patterns throughout
- ✅ Reflects Insper visual identity
- ✅ Clear disclaimer about unofficial status
- ✅ Professional documentation
- ✅ Publication-ready examples
- ✅ Accessibility considerations

**Estimated Total Time:** 23-31 hours across all versions
