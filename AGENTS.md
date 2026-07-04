# AGENTS.md — pdp

R package for **partial dependence plots (PDPs)** and **individual conditional
expectation (ICE) curves** from fitted ML models. Exports: `partial()` (the
workhorse), `plot()` methods (tinyplot/base graphics, default engine),
`plotPartial()` (lattice), `exemplar()`, and the deprecated `topPredictors()`.

## Branches & releases

- **`devel`** (default): all development and PRs. Version carries a `.9000`
  suffix; NEWS.md starts with `# pdp (development version)`.
- **`main`**: stable releases only, tagged `vX.Y.Z`. r-universe
  (pinned to main in bgreenwell/bgreenwell.r-universe.dev) and the pkgdown
  site both build from main — never push experimental work there.
- Release: merge devel → main (`--no-ff`), drop the `.9000` suffix and dev
  NEWS heading, tag, push, `gh release create`; then **merge main back into
  devel** (else the release merge commit leaves devel "behind" main) and bump
  devel to the next `.9000`.
- Shared fixes that main needs immediately (CI, README): commit to **main
  first, then merge main → devel**. Never cherry-pick devel → main — it
  duplicates commits and makes main appear "ahead" of devel.

## Dependency philosophy

Keep Imports minimal: `graphics, grDevices, lattice, methods, stats, tinyplot,
utils` — nothing else without strong justification. Plotting is
**tinyplot** (zero-dep base graphics), *not* ggplot2 (removed in 0.9.0).
`foreach` lives in Suggests and is only touched when `parallel = TRUE`
(see `par_loop()` in `R/pardep.R`). Use `pkg::fun()` for Suggests packages.

## Commands

```bash
Rscript -e 'devtools::document()'                                        # after roxygen edits
Rscript -e 'pkgload::load_all("."); tinytest::run_test_dir("inst/tinytest")'  # full test suite
Rscript -e 'devtools::check()'                                           # before pushing
```

Tests use **tinytest** (not testthat) in `inst/tinytest/`. Model-specific
tests (`test_pkg_*.R`) are gated behind `at_home()` and skip on CRAN-style
checks. Always add a NEWS.md entry; never edit `man/` by hand.

## Architecture (R/)

- `partial.R` — `partial()` orchestrator: extracts training data, builds the
  grid, dispatches to the compute engine, optionally plots.
- `pardep.R` — brute-force engine. One unified loop; `batch.size` stacks grid
  points per `predict()` call (fast path); `par_loop()` = lapply or foreach.
  `pardep_gbm()` calls the C++ recursive method (`src/PartialGBM.cpp`).
- `get_predictions.R` — per-model `get_predictions()` / `get_probs()` S3
  wrappers; probability→output goes through `finalize_probs()`. Identical
  methods are aliased (e.g., `get_probs.qda <- get_probs.lda`).
- `get_task.R` / `get_training_data.R` — infer regression vs. classification;
  recover training data from the model call.
- `pred_grid.R` — grid construction (`grid.resolution`, `quantiles`,
  `trim.outliers`, `cats`).
- `plot.R` — tinyplot engine (`plot.partial/ice/cice`); `plotPartial.R` —
  lattice engine; `utils.R` — ICE centering/averaging, `multiclass_logit()`.

## Supporting a new model class

1. `get_task.newclass()` in `R/get_task.R` (or rely on `type` arg).
2. `get_predictions.newclass()` and/or `get_probs.newclass()` (funnel through
   `finalize_probs()`); `get_training_data.newclass()` only if the default
   call-recovery fails.
3. Add `inst/tinytest/test_pkg_newclass.R`; add the package to Suggests.

## Gotchas

- **gbm recursive method (C++)**: factor grid columns must be converted to
  **0-based** integer codes before `.Call("PartialGBM", ...)`; `data.matrix()`
  alone gives 1-based codes and silently corrupts results (bug fixed in
  0.9.0 — keep `test_pkg_gbm.R`'s recursive-vs-brute-force comparison green).
- **tinyplot lazily evaluates some args** (e.g., `legend`) in another
  environment, and records calls for `tinyplot_add()`. Build internal tinyplot
  calls with `do.call()` so stored calls contain values, never `...`.
- `batch.size` requires one prediction per row of `newdata`; incompatible
  with aggregating `pred.fun`s (informative error exists).
- `partial(plot = TRUE)` draws via tinyplot and returns data invisibly;
  `plot.engine = "lattice"` returns a trellis object instead.

## CI / site

GitHub Actions (r-lib/actions v2): R-CMD-check + test-coverage on pushes/PRs
to main and devel; pkgdown builds from **main only** and deploys to
`gh-pages` (served at https://bgreenwell.github.io/pdp/). Vignettes are plain
Rmd in `vignettes/` and run at build time — keep their chunks fast.
