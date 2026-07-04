# pdp <img src="man/figures/pdp-logo.png" align="right" width="130" height="150" />

<!-- badges: start -->
[![r-universe version](https://bgreenwell.r-universe.dev/badges/pdp)](https://bgreenwell.r-universe.dev/pdp)
[![R-CMD-check](https://github.com/bgreenwell/pdp/workflows/R-CMD-check/badge.svg)](https://github.com/bgreenwell/pdp/actions)
[![Codecov test coverage](https://codecov.io/gh/bgreenwell/pdp/branch/main/graph/badge.svg)](https://app.codecov.io/gh/bgreenwell/pdp?branch=main)
[![Total Downloads](https://cranlogs.r-pkg.org/badges/grand-total/pdp)](https://cranlogs.r-pkg.org/badges/grand-total/pdp)
<!-- badges: end -->

Partial dependence plots (PDPs) and individual conditional expectation (ICE)
curves for R: visualize how a fitted model's predictions depend on a subset of
its features.

- **Model-agnostic** — works with dozens of model classes out of the box
  (randomForest, ranger, gbm, xgboost, caret, e1071, …) and with *any* model
  via a user-supplied prediction function (`pred.fun`)
- **PDPs and ICE/c-ICE curves** for regression and classification
- **Lightweight plotting** via [tinyplot](https://grantmcdermott.com/tinyplot/)
  (base R graphics), with [lattice](https://cran.r-project.org/package=lattice)
  displays (3-D surfaces, paneled three-predictor plots) behind
  `plot(..., lattice = TRUE)`
- **Fast**: batched predictions (`batch.size`), parallel execution via
  [foreach](https://cran.r-project.org/package=foreach), training-data
  subsampling (`frac`), and Friedman's exact weighted tree-traversal method
  for [gbm](https://cran.r-project.org/package=gbm) models
- **Minimal dependencies**: imports only base R packages plus lattice and
  tinyplot

## Installation

**pdp** is no longer available on CRAN due to CRAN's stringent and
ever-changing policies. It is now hosted on
[r-universe](https://bgreenwell.r-universe.dev/pdp), which provides a reliable
alternative for distributing R packages.

``` r
# Latest stable release (recommended)
install.packages("pdp", repos = c("https://bgreenwell.r-universe.dev", "https://cloud.r-project.org"))

# Or with pak
pak::pak("bgreenwell/pdp@main")  # latest stable release
pak::pak("bgreenwell/pdp")       # development version (devel branch)
```

## Quick start

``` r
library(pdp)
library(randomForest)

data(boston)  # ships with pdp
set.seed(101)
rfo <- randomForest(cmedv ~ ., data = boston)

# Partial dependence of cmedv on lstat
pd <- partial(rfo, pred.var = "lstat", train = boston)
plot(pd, rug = TRUE, train = boston)

# Two predictors (false color level plot), restricted to the convex hull
partial(rfo, pred.var = c("lstat", "rm"), chull = TRUE, train = boston,
        plot = TRUE)

# ICE curves colored by another feature
ice <- partial(rfo, pred.var = "rm", ice = TRUE, train = boston)
plot(ice, alpha = 0.1, color.by = "lstat", train = boston)
```

`partial()` returns a plain data frame, so results are easy to post-process or
plot with any graphics package.

## Documentation

- [Package website](https://bgreenwell.github.io/pdp/) — function reference
  and vignettes ([getting started](https://bgreenwell.github.io/pdp/articles/pdp.html),
  [ICE curves](https://bgreenwell.github.io/pdp/articles/ice-curves.html),
  [performance tips](https://bgreenwell.github.io/pdp/articles/faster-pdp.html))
- Greenwell, B. M. (2017). "pdp: An R Package for Constructing Partial
  Dependence Plots." *The R Journal*, 9(1), 421–436.
  [doi:10.32614/RJ-2017-016](https://doi.org/10.32614/RJ-2017-016)
  (`citation("pdp")`)
- For variable importance (which pairs naturally with feature effects), see
  [vip](https://bgreenwell.github.io/vip/)

## Development

Development happens on the [`devel`](https://github.com/bgreenwell/pdp/tree/devel)
branch (the repository default); `main` holds stable releases, which is what
r-universe builds and the website documents. Please open pull requests against
`devel` and report bugs via the
[issue tracker](https://github.com/bgreenwell/pdp/issues).
