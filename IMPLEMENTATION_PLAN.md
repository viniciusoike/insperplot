# Implementation Plan for insperplot Improvements

This document outlines the remaining improvements to implement, organized by priority.

## 🎉 Phase 1: COMPLETED

### Quick Wins ✓
- ✓ [data-masked] tags already removed from documentation
- ✓ insper_heatmap() already has show_values = FALSE default
- ✓ insper_boxplot() and insper_violin() already use iris in examples
- ✓ format_num_br() already has comprehensive tests
- ✓ CLAUDE.md version references updated to 1.3.3

### Critical Improvements ✓
- ✓ **All 9 plot functions already have `...` parameter implemented**
- ✓ **Added 9 comprehensive tests for `...` functionality** (tests/testthat/test-plots.R)
- ✓ **Verified dplyr not used in package code** (only in examples)

**Files modified in Phase 1:**
- `CLAUDE.md` (version updates)
- `tests/testthat/test-plots.R` (+94 lines, 9 new test cases with 18 assertions)

---

## HIGH PRIORITY (Pre-CRAN Submission)

### ~~1. Fix Documentation Issues~~
**Status:** ✓ COMPLETED - Already done in codebase

### ~~3. Fix Version Inconsistencies~~
**Status:** ✓ COMPLETED - CLAUDE.md updated to v1.3.3

### ~~4. Better Default Parameters~~
**Status:** ✓ COMPLETED - Already done in codebase

### ~~5. Improve Dataset Examples~~
**Status:** ✓ COMPLETED - Already done in codebase

---

## MEDIUM PRIORITY (Quality & User Experience)

### 6. Add `...` Parameter to All Plot Functions
**Priority:** HIGH
**Estimated effort:** 2-3 hours
**Impact:** Significantly improves API flexibility

**Current limitation:**
```r
# These don't work:
insper_histogram(mtcars, mpg, binwidth = 5)  # Error
insper_area(data, x, y, position = "dodge")   # Error
```

**Implementation steps:**
1. Add `...` parameter to all 9 plot functions:
   - `insper_barplot()`
   - `insper_scatterplot()`
   - `insper_timeseries()`
   - `insper_area()`
   - `insper_boxplot()` ✓ (already has it)
   - `insper_violin()` ✓ (already has it)
   - `insper_heatmap()` ✓ (already has it)
   - `insper_histogram()`
   - `insper_density()`

2. Pass `...` to the primary geom layer in each function
3. Update documentation to explain `...` usage
4. Add tests for `...` parameter functionality
5. Add examples showing advanced geom customization

**Files to modify:**
- `R/plot-barplot.R`
- `R/plot-scatterplot.R`
- `R/plot-timeseries.R`
- `R/plot-area.R`
- `R/plot-histogram.R`
- `R/plot-density.R`
- `tests/testthat/test-plots.R`

**Note:** boxplot, violin, and heatmap already have `...` parameter implemented.

---

### 7. Expand Test Coverage
**Priority:** MEDIUM
**Estimated effort:** 3-4 hours
**Impact:** Increases robustness and catches edge cases

**Missing test scenarios:**

#### a. Theme Function Error Conditions
- Invalid `border` parameter values
- Invalid `align` parameter values
- Invalid `base_size` values (negative, zero)
- Font fallback chain behavior

**Files to modify:**
- `tests/testthat/test-theme.R`

#### b. Font Fallback Logic
- Test `detect_font()` with various availability scenarios
- Test behavior when systemfonts not installed
- Test behavior when fonts_imported option is set

**Files to modify:**
- `tests/testthat/test-theme.R` or create new `test-fonts.R`

#### c. Integration Tests
- Combining plot functions with custom themes
- Saving plots with different devices
- Plot + scale + theme combinations

**Files to create:**
- `tests/testthat/test-integration.R`

#### d. Edge Cases for Utilities
- `save_insper_plot()` error handling (invalid plot, bad filename)
- `show_insper_palette()` with invalid palette names
- `show_insper_colors()` with invalid family names

**Files to modify:**
- `tests/testthat/test-utilities.R`
- `tests/testthat/test-colors.R`

**Test coverage target:** Increase from current ~95% to >97%

---

### 9. Simplify Font Setup Architecture
**Priority:** MEDIUM-LOW
**Estimated effort:** 4-5 hours
**Impact:** Reduces technical debt, simplifies maintenance

**Current situation:**
- Three font approaches: local install, showtext remote loading, fallback
- Legacy showtext code maintained despite known DPI issues
- Confusing for users

**Recommended approach:**
1. **Deprecate showtext path** in documentation (v1.4.0)
   - Keep code for backward compatibility
   - Update documentation to emphasize ragg-only approach
   - Add deprecation notice to `import_insper_fonts()`

2. **Simplify setup wizard** (`setup_insper_fonts()`)
   - Focus on: Install fonts locally → Install ragg → Configure RStudio
   - De-emphasize showtext option

3. **Update vignette** (getting-started.Rmd)
   - Modern best practice: ragg + local fonts
   - Legacy approach: showtext (with warnings)

**Files to modify:**
- `R/utils.R` (update `import_insper_fonts()` docs)
- `R/utils.R` (update `setup_insper_fonts()` logic)
- `vignettes/getting-started.Rmd`
- `README.Rmd`
- `CLAUDE.md`

**Breaking change consideration:** Plan for v2.0.0 to remove showtext code entirely.

---

### 10. ~~Add Missing Formatter Tests~~
**Status:** ✓ COMPLETED - Tests already comprehensive in test-utilities.R

---

## LOW PRIORITY (Nice-to-Have)

### 11. Decide on insper_lollipop()
**Priority:** LOW
**Estimated effort:** 2-3 hours OR 10 minutes (decision only)
**Impact:** API completeness OR API clarity

**Current status:**
- Mentioned in suggestions.R as "poorly implemented" or "should be removed"
- Not found in current R/ directory
- Not in NAMESPACE

**Options:**

**Option A: Implement properly**
- Create `R/plot-lollipop.R` with robust implementation
- Handle both horizontal/vertical orientations
- Smart detection for aggregated vs raw data
- Comprehensive tests

**Option B: Document intentional exclusion**
- Add note to CLAUDE.md explaining why excluded
- Remove from suggestions.R
- Consider for future version if user demand arises

**Recommendation:** Option B (document exclusion). Lollipop charts can be created with `insper_barplot()` + `coord_flip()` or standard ggplot2.

**Files to modify (if Option B):**
- `CLAUDE.md` (add note to Plotting Functions section)
- `suggestions.R` (remove lollipop references)

---

### 12. Performance Optimizations
**Priority:** LOW
**Estimated effort:** 1-2 hours
**Impact:** Minor performance gains

**Opportunities:**

#### a. Memoize Palette Lookups
```r
# Current: evaluates on every call
colors <- insper_palettes[[palette]]

# Proposed: cache with memoise package
get_palette_memoized <- memoise::memoise(function(name) insper_palettes[[name]])
```

**Consideration:** May not be worth the added dependency for minor gains.

#### b. Benchmark Suite
- Create benchmark scripts to prevent regressions
- Track plot creation time, scale application time, theme application time

**Files to create:**
- `benchmarks/plot-performance.R`
- `benchmarks/theme-performance.R`

---

### 13. Code Quality Automation
**Priority:** LOW
**Estimated effort:** 1 hour
**Impact:** Consistent code style, catches typos

**Additions to CI/CD:**

#### a. Add lintr to GitHub Actions
```yaml
# .github/workflows/lint.yaml
- name: Lint code
  run: Rscript -e "lintr::lint_package()"
```

#### b. Add spelling check
```yaml
- name: Spell check
  run: Rscript -e "spelling::spell_check_package()"
```

#### c. Add styler check (optional)
```yaml
- name: Check code style
  run: Rscript -e "styler::style_pkg(dry = 'on')"
```

**Files to create/modify:**
- `.github/workflows/lint.yaml` (new)
- `inst/WORDLIST` (for spelling, if needed)

---

### 14. Expand pkgdown Website
**Priority:** LOW
**Estimated effort:** 2-3 hours
**Impact:** Better documentation discoverability

**Additions:**

#### a. Articles Section
- "Advanced Theme Customization"
- "Working with Insper Color Palettes"
- "Creating Publication-Ready Plots"

#### b. Gallery Section
- Showcase complex examples
- Before/after comparisons (default ggplot2 vs insperplot)
- Real-world use cases

#### c. Lifecycle Badges
- Add lifecycle badges to function documentation
- Mark experimental features (if any)
- Mark superseded functions (if any)

**Files to modify:**
- `_pkgdown.yml`
- Create articles in `vignettes/articles/`

---

### 16. ~~Accelerate to v1.0.0~~
**Status:** N/A - Package already at v1.3.3 (stable)

**Current situation:**
- Package is at v1.3.3 (stable lifecycle)
- Old palette name warnings reference "removed in v1.0.0"
- These warnings should be removed or updated

**Action:** Check if deprecated palette names still show warnings, remove if so.

---

## STRATEGIC CONSIDERATIONS

### 17. CRAN Submission Readiness
**Priority:** MEDIUM (if planning submission)
**Estimated effort:** 2-4 hours
**Impact:** Makes package available on CRAN

**Current status:**
- ✓ License: MIT + file LICENSE
- ✓ Dependencies: All reasonable, all in Suggests
- ✓ Documentation: Complete
- ✓ Tests: Good coverage
- ✓ Namespace: Clean
- ✓ R CMD check: Should pass with 0 errors, 0 warnings, 0 notes

**Items to verify:**

#### a. Update cran-comments.md
- Verify package passes R CMD check locally
- Test on win-builder (Windows)
- Test on R-hub (multiple platforms)

#### b. Examples Execution
- Current: `@examplesIf has_insper_fonts()` skips examples in non-interactive mode
- Note: User specified keeping this to avoid CRAN check failures
- CRAN may flag "no examples" - monitor submission feedback

#### c. Submission Checklist
- [ ] Update `cran-comments.md` with test results
- [ ] Verify all URLs are valid (documentation, README)
- [ ] Check for any remaining TODOs in code
- [ ] Verify NEWS.md is up to date
- [ ] Submit via devtools::submit_cran() or web form

**Files to modify:**
- `cran-comments.md`

---

### 18. Dependency Discrepancy
**Priority:** LOW
**Estimated effort:** 5 minutes
**Impact:** Clarity, correctness

**Issue:**
- CLAUDE.md previously mentioned dplyr (≥1.1.0) as main dependency
- DESCRIPTION doesn't list dplyr in Imports (only used in examples)
- **Fixed:** Updated CLAUDE.md to correct dependencies

**Verification needed:**
- Grep codebase for dplyr usage
- Confirm it's only in examples, not package code
- If found in package code, add to Imports

**Files to check:**
```bash
# Search for dplyr usage in R/ directory
grep -r "dplyr::" R/
grep -r "library(dplyr)" R/
grep -r "require(dplyr)" R/
```

---

## IMPLEMENTATION SEQUENCE

### Phase 1: Critical Improvements (Week 1)
1. ✓ Quick wins (COMPLETED)
2. Add `...` parameter to plot functions (#6)
3. Verify dependency discrepancy (#18)

### Phase 2: Quality & Testing (Week 2)
4. Expand test coverage (#7)
5. Decide on insper_lollipop() (#11)
6. Check deprecated palette warnings (#16)

### Phase 3: Documentation & CI (Week 3)
7. Code quality automation (#13)
8. Simplify font setup documentation (#9)
9. Update cran-comments.md (#17)

### Phase 4: Polish (Optional)
10. Performance optimizations (#12)
11. Expand pkgdown website (#14)

---

## EXCLUDED FROM PLAN

Per user request, these items are **NOT** being implemented:

- ~~#2: Improve Example Execution~~ (intentional to avoid CRAN errors)
- ~~#8: Add More Vignettes~~ (single vignette is sufficient for now)
- ~~#15: Additional Plot Types~~ (not needed at this time)
- ~~#19: API Enhancement for theme_insper()~~ (intentionally removed in v0.7.0)

---

## SUCCESS METRICS

- ✓ All quick wins completed
- [ ] `...` parameter works in all plot functions
- [ ] Test coverage >97%
- [ ] R CMD check passes with 0 errors, 0 warnings, 0 notes
- [ ] CI includes linting and spell checking
- [ ] Documentation clearly recommends ragg approach
- [ ] Ready for CRAN submission (if desired)

---

## NOTES

- Package is in excellent shape - most improvements are polish
- API is stable (v1.3.3)
- Breaking changes should wait for v2.0.0
- Focus on user experience and test coverage
- CRAN submission is optional but package is nearly ready
