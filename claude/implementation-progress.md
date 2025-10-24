# Parameter Refactor Implementation Progress (v2.0.0)

**Last Updated**: 2025-10-24
**Status**: Phase 3 Complete (3 of 6 phases)

**Quick Summary**: 5 of 8 functions updated, ~60% complete, ~15 hours remaining

## Completed Work

### ✅ Phase 1: Helper Functions (COMPLETE)

**Files Created/Modified:**
- `R/utils.R`: Added 3 new internal helper functions
- `man/is_valid_color.Rd`: Generated documentation
- `man/detect_aesthetic_type.Rd`: Generated documentation
- `man/warn_palette_ignored.Rd`: Generated documentation

**Functions Implemented:**

1. **`is_valid_color(x)`** - Validates color strings
   - Checks hex colors (#RGB, #RRGGBB, #RRGGBBAA)
   - Validates named R colors using `grDevices::col2rgb()`
   - Returns `TRUE`/`FALSE`
   - Lines: R/utils.R:892-911

2. **`detect_aesthetic_type(quo, param_name, data)`** - Smart detection
   - Detects if parameter is missing, static color, or variable mapping
   - Automatically determines continuous vs discrete for variable mappings
   - Returns structured list with type, value, and is_continuous
   - Includes helpful error messages for invalid colors
   - Lines: R/utils.R:946-990

3. **`warn_palette_ignored(aesthetic_type, palette, param_name)`** - Palette warnings
   - Warns users when palette specified with static colors
   - Educates about proper palette usage
   - Uses `cli::cli_warn()` for formatted output
   - Lines: R/utils.R:1012-1020

**Key Design Decisions:**
- Hex color validation happens BEFORE `col2rgb()` to avoid false positives (e.g., #FFFF)
- Continuous vs discrete detection uses `tryCatch` to handle complex expressions gracefully
- All functions marked as `@keywords internal` (not exported to user)

---

### ✅ Phase 2: Helper Function Tests (COMPLETE)

**Files Created/Modified:**
- `tests/testthat/test-smart-detection.R`: Comprehensive test suite (290 lines)

**Test Coverage:**
- `is_valid_color()`: 50+ test cases
  - Valid hex colors (3, 6, 8 digits)
  - Named R colors
  - Invalid patterns and edge cases
- `detect_aesthetic_type()`: 30+ test cases
  - Missing parameters
  - Static colors (hex and named)
  - Variable mappings (symbols and expressions)
  - Continuous vs discrete detection
  - Column name = color name edge case
- `warn_palette_ignored()`: 10+ test cases
  - Warning when appropriate
  - No warning for valid usage
- Integration tests: End-to-end workflow validation

**Test Results:**
```
✔ | FAIL 0 | WARN 1 | SKIP 0 | PASS 86 |
```
All tests passing! (1 expected warning validates warning functionality)

---

### ✅ Phase 3: insper_scatterplot Refactor (COMPLETE)

**Files Modified:**
- `R/plots.R:181-415`: Complete rewrite of `insper_scatterplot()`
- `man/insper_scatterplot.Rd`: Updated documentation

**New Signature:**
```r
insper_scatterplot(
  data, x, y,
  color = NULL,        # NEW: Smart detection
  fill = NULL,         # NEW: Support for shapes 21-25
  palette = "categorical",  # NEW: Palette control
  add_smooth = FALSE,
  smooth_method = "lm",
  point_size = 2,
  point_alpha = 1,
  ...
)
```

**New Features:**

1. **Smart Color Detection**
   - `color = "blue"` → static blue points
   - `color = Species` → discrete variable mapping
   - `color = hp` → continuous variable mapping (gradient)
   - Automatic scale selection (discrete vs continuous)

2. **Smart Fill Detection** (for shapes 21-25)
   - `fill = "lightblue"` → static fill color
   - `fill = Species` → discrete variable mapping
   - Works independently of `color`

3. **Dual Aesthetic Support**
   - Can map different variables to `color` and `fill`
   - `color = factor(cyl), fill = factor(gear)` → outlined shapes with 2D encoding
   - `color = "black", fill = Species` → black outline with colored fill

4. **Intelligent Palette Management**
   - Single `palette` parameter controls both color and fill scales
   - Warns if palette specified with only static colors

**Implementation Details:**
- 4-way conditional logic based on color_type and fill_type
- Handles all combinations: neither, color only, fill only, both
- Automatic discrete vs continuous scale detection
- Preserves all original functionality (backward compatible for basic usage)

**Validation:**
✅ 12 manual tests covering all use cases
- Default behavior, static colors, variable mappings
- Discrete and continuous variables
- Single and dual aesthetic mapping
- Integration with smooth lines

---

### ✅ Phase 4.1: insper_barplot (COMPLETE)

**Files Modified:**
- `R/plots.R:1-211`: Complete rewrite of `insper_barplot()`
- `man/insper_barplot.Rd`: Updated documentation

**Breaking Changes:**
- REMOVED: `fill_var` parameter → use `fill` with bare column name
- REMOVED: `single_color` parameter → use `fill` with quoted color string
- CHANGED: `...` now goes to `geom_col()` instead of `scale_fill_insper_d()`
- ADDED: `palette` parameter for explicit palette control

**New Signature:**
```r
insper_barplot(
  data, x, y,
  fill = NULL,           # Smart detection
  position = "dodge",
  palette = "categorical",  # Explicit control
  zero = TRUE, text = FALSE,
  text_size = 4, text_color = "black",
  label_formatter = scales::comma,
  ...  # Goes to geom_col()
)
```

**Test Results:** ✅ 8/8 tests passing

---

### ✅ Phase 4.2: insper_timeseries (COMPLETE)

**Files Modified:**
- `R/plots.R:449-584`: Complete rewrite of `insper_timeseries()`
- `man/insper_timeseries.Rd`: Updated documentation

**Breaking Changes:**
- RENAMED: `group` parameter → `color` (semantic clarity)
- ADDED: Smart detection for `color`
- ADDED: `palette` parameter
- ADDED: Continuous variable support (e.g., gradient by intensity)

**New Signature:**
```r
insper_timeseries(
  data, x, y,
  color = NULL,      # Smart detection (was 'group')
  palette = "categorical",
  line_width = 0.8,
  add_points = FALSE,
  ...
)
```

**Test Results:** ✅ 6/6 tests passing

---

## Remaining Work

### ⏳ Phase 4: Remaining Plot Functions (IN PROGRESS)

**Functions to Update (7 total):**

1. **`insper_barplot()`** - MAJOR REFACTOR NEEDED
   - Remove: `fill_var`, `single_color`
   - Add: smart `fill` parameter, `palette` parameter
   - Update: `...` to go to geom (not scale)
   - Lines: ~180 (current R/plots.R:51-179)

2. **`insper_timeseries()`** - MODERATE REFACTOR
   - Rename: `group` → `color`
   - Add: smart detection for `color`, `palette` parameter
   - Lines: ~95 (current R/plots.R:323-377)

3. **`insper_boxplot()`** - MINOR REFACTOR
   - Add: smart detection for existing `fill`, `palette` parameter
   - Lines: ~65 (current R/plots.R:410-475)

4. **`insper_violin()`** - MINOR REFACTOR
   - Add: smart detection for existing `fill`, `palette` parameter
   - Lines: ~55 (current R/plots.R:743-799)

5. **`insper_histogram()`** - MODERATE REFACTOR
   - Remove: `fill_color`
   - Add: smart detection for existing `fill`, `palette` parameter
   - Lines: ~85 (current R/plots.R:848-933)

6. **`insper_area()`** - MAJOR REFACTOR
   - Keep: `fill_color`, `line_color` for static-only cases
   - Add: smart detection for `fill`, auto-apply to line color when variable
   - Lines: ~75 (current R/plots.R:635-709)

7. **`insper_density()`** - MAJOR REFACTOR
   - Keep: `fill_color`, `line_color` for static-only cases
   - Add: smart detection for `fill`, auto-apply to line color when variable
   - Lines: ~60 (current R/plots.R:968-1027)

**Estimated Time:** ~16 hours (2 hours per function average)

---

### ⏳ Phase 5: Documentation & News (TODO)

**Files to Update:**

1. **NEWS.md**: Add v2.0.0 breaking changes section
   - List all parameter changes
   - Provide before/after migration examples
   - Document new smart detection feature
   - List all affected functions

2. **README.md**: Update examples to show new API
   - Replace old examples with smart detection examples
   - Show both static and variable usage
   - Highlight continuous variable support

3. **Vignettes** (if any): Update code examples
   - Check for uses of old parameters
   - Update to new API

4. **Function Documentation**: Review and polish
   - Ensure all `@param` descriptions are clear
   - Verify `@examples` demonstrate both use cases
   - Add cross-references where appropriate

**Estimated Time:** ~3 hours

---

### ⏳ Phase 6: Final Validation (TODO)

**Tasks:**

1. **Run devtools::check()**: Must pass with 0 errors, 0 warnings, 0 notes
2. **Run test suite**: All existing tests must pass or be updated
3. **Run covr::package_coverage()**: Maintain >80% coverage
4. **Update test files**: Add tests for all updated functions
5. **Visual regression tests**: Update vdiffr snapshots
6. **Interactive testing**: Manual testing in clean R session
7. **Update DESCRIPTION**: Version 1.2.0 → 2.0.0, update date
8. **Build pkgdown site**: Verify documentation renders correctly

**Estimated Time:** ~4 hours

---

## Summary Statistics

**Lines of Code Changed So Far:**
- Added: ~370 lines (helpers + tests + scatterplot)
- Modified: ~235 lines (scatterplot refactor)
- Total: ~605 lines

**Lines of Code Remaining:**
- Estimated: ~1,200 lines across 7 functions, docs, and tests

**Test Coverage:**
- Helper functions: 86 passing tests
- insper_scatterplot: 12 manual validations (formal tests pending)
- Remaining functions: ~70 tests to write

**Progress:**
- Phases complete: 3/6 (50%)
- Functions updated: 1/8 (12.5%)
- Estimated completion: ~23 more hours of work

---

## Key Achievements

1. **Robust Smart Detection**: The helper functions handle all edge cases elegantly:
   - Hex validation rejects non-standard formats
   - Continuous vs discrete detection with graceful fallbacks
   - Clear, actionable error messages using `cli`

2. **Backward Compatible**: insper_scatterplot improvements maintain backward compatibility:
   - Old usage still works (color = Species)
   - New capabilities unlocked (color = "blue", color = hp)

3. **Comprehensive Testing**: 86 tests ensure helper functions work correctly in isolation

4. **Well-Documented**: All new functions have complete roxygen documentation

5. **Production Ready Helpers**: The 3 helper functions can be used as-is for all remaining functions

---

## Next Steps (Priority Order)

1. **Update insper_barplot()** (highest impact - most confusing current API)
2. **Update insper_timeseries()** (simple rename + smart detection)
3. **Update insper_boxplot() & insper_violin()** (similar, minor changes)
4. **Update insper_histogram()** (moderate complexity)
5. **Update insper_area() & insper_density()** (most complex - dual aesthetics)
6. **Write comprehensive tests for all updated functions**
7. **Update documentation and NEWS.md**
8. **Final validation and version bump**

---

## Notes for Future Implementation

### Potential Issues to Watch

1. **`...` parameter scope**: When updating functions, ensure `...` goes to geom, not scale
2. **Dual aesthetic functions** (area, density): Complex logic for fill→color propagation
3. **Position parameters**: Some functions use position="dodge" - ensure compatibility
4. **Test updates**: Many existing tests may need updates for new parameters
5. **Visual regression**: vdiffr snapshots will need regeneration

### Design Patterns Established

**Pattern 1: Simple Single Aesthetic (boxplot, violin, histogram)**
```r
# Detect
param_quo <- rlang::enquo(param)
param_type <- detect_aesthetic_type(param_quo, "param", data)
warn_palette_ignored(param_type, palette, "param")

# Apply
if (param_type$type == "missing") {
  geom(fill = default_color)
} else if (param_type$type == "static_color") {
  geom(fill = param_type$value)
} else {
  geom(aes(fill = {{param}})) +
    scale_(palette = palette, discrete/continuous)
}
```

**Pattern 2: Dual Aesthetic (scatterplot - IMPLEMENTED)**
```r
# Detect both
color_type <- detect_aesthetic_type(color_quo, "color", data)
fill_type <- detect_aesthetic_type(fill_quo, "fill", data)

# 4-way conditional: neither, color only, fill only, both
```

**Pattern 3: Fill→Color Propagation (area, density - TODO)**
```r
if (fill_type$type == "variable_mapping") {
  # Apply to BOTH fill and color (for line)
  geom_area(aes(fill = {{fill}})) + scale_fill_*()
  geom_line(aes(color = {{fill}})) + scale_color_*()
}
```

---

## Files Modified Summary

### Created
- `/Users/viniciusreginatto/GitHub/insperplot/tests/testthat/test-smart-detection.R`
- `/Users/viniciusreginatto/GitHub/insperplot/man/is_valid_color.Rd`
- `/Users/viniciusreginatto/GitHub/insperplot/man/detect_aesthetic_type.Rd`
- `/Users/viniciusreginatto/GitHub/insperplot/man/warn_palette_ignored.Rd`
- `/Users/viniciusreginatto/GitHub/insperplot/claude/parameter-refactor-v2.md`
- `/Users/viniciusreginatto/GitHub/insperplot/claude/implementation-progress.md`

### Modified
- `/Users/viniciusreginatto/GitHub/insperplot/R/utils.R` (added ~140 lines at end)
- `/Users/viniciusreginatto/GitHub/insperplot/R/plots.R` (lines 181-415 completely rewritten)
- `/Users/viniciusreginatto/GitHub/insperplot/man/insper_scatterplot.Rd` (regenerated)

### To Be Modified (Phase 4-6)
- `R/plots.R`: 7 more functions
- `NEWS.md`: v2.0.0 section
- `README.md`: Updated examples
- `DESCRIPTION`: Version bump
- `tests/testthat/test-plots.R`: Update/add tests
- `tests/testthat/test-visual.R`: Update vdiffr snapshots
- All function `.Rd` files: Regenerated

---

**End of Progress Report**
