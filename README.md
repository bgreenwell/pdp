# pdp <img src="man/figures/pdp-logo.png" align="right" width="130" height="150" />

<!-- badges: start -->

[![r-universe status](https://bgreenwell.r-universe.dev/badges/pdp)](https://bgreenwell.r-universe.dev/pdp)
[![r-universe version](https://bgreenwell.r-universe.dev/pdp/badges/version)](https://bgreenwell.r-universe.dev/pdp)
[![R-CMD-check](https://github.com/bgreenwell/pdp/workflows/R-CMD-check/badge.svg)](https://github.com/bgreenwell/pdp/actions)
[![Codecov test
coverage](https://codecov.io/gh/bgreenwell/pdp/branch/main/graph/badge.svg)](https://app.codecov.io/gh/bgreenwell/pdp?branch=main)
[![Total
Downloads](https://cranlogs.r-pkg.org/badges/grand-total/pdp)](https://cranlogs.r-pkg.org/badges/grand-total/pdp)
<!-- badges: end -->

## Overview

[pdp](https://bgreenwell.r-universe.dev/pdp) is an R package for
constructing ***p**artial **d**ependence **p**lots* (PDPs) and
***i**ndividual **c**onditional **e**xpectation* (ICE) curves. PDPs and
ICE curves are part of a larger framework referred to as *interpretable
machine learning* (IML), which also includes (but not limited to)
***v**ariable **i**mportance **p**lots* (VIPs). While VIPs (available in
the R package [vip](https://koalaverse.github.io/vip/index.html)) help
visualize feature impact (either locally or globally), PDPs and ICE
curves help visualize feature effects. An in-progress, but
comprehensive, overview of IML can be found at the following URL:
<https://github.com/christophM/interpretable-ml-book>.

A detailed introduction to [pdp](https://bgreenwell.r-universe.dev/pdp)
has been published in The R Journal: “pdp: An R Package for Constructing
Partial Dependence Plots”,
<https://journal.r-project.org/articles/RJ-2017-016/index.html>. You
can track development at <https://github.com/bgreenwell/pdp>. To report
bugs or issues, contact the main author directly or submit them to
<https://github.com/bgreenwell/pdp/issues>. For additional documentation
and examples, visit the [package
website](https://bgreenwell.github.io/pdp/index.html).

As of right now, `pdp` exports the following functions:

-   `partial()` - compute partial dependence functions and individual
    conditional expectations (i.e., objects of class `"partial"` and
    `"ice"`, respectively) from various fitted model objects;

-   `plotPartial()` - construct `lattice`-based PDPs and ICE curves;

-   `plot()` - construct lightweight base R PDPs and ICE curves via
    [tinyplot](https://grantmcdermott.com/tinyplot/);

-   ~~`topPredictors()` extract most “important” predictors from various
    types of fitted models.~~ see
    [vip](https://koalaverse.github.io/vip/index.html) instead for a
    more robust and flexible replacement;

-   `exemplar()` - construct an exemplar record from a data frame
    (**experimental** feature that may be useful for constructing fast,
    approximate feature effect plots.)

## Installation

**pdp** is no longer available on CRAN due to CRAN's stringent and ever-changing
policies. It is now hosted on [r-universe](https://bgreenwell.r-universe.dev/pdp),
which provides a reliable alternative for distributing R packages.

``` r
# Install the latest stable release from r-universe (recommended):
install.packages("pdp", repos = c("https://bgreenwell.r-universe.dev", "https://cloud.r-project.org"))

# Or install with pak (if needed: install.packages("pak")):
pak::pak("bgreenwell/pdp@main")  # latest stable release
pak::pak("bgreenwell/pdp")       # development version (devel branch)
```

## Development

Development happens on the [`devel`](https://github.com/bgreenwell/pdp/tree/devel)
branch (the repository default); the `main` branch is reserved for stable
releases, which is what [r-universe](https://bgreenwell.r-universe.dev/pdp)
builds and the [package website](https://bgreenwell.github.io/pdp/) documents.
Please open pull requests against `devel`.
