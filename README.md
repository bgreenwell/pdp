# pdp <img src="man/figures/pdp-logo.png" align="right" width="130" height="150" />

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/investr)](https://CRAN.R-project.org/package=investr)
[![R-CMD-check](https://github.com/bgreenwell/pdp/workflows/R-CMD-check/badge.svg)](https://github.com/bgreenwell/pdp/actions)
[![Codecov test
coverage](https://codecov.io/gh/bgreenwell/pdp/branch/master/graph/badge.svg)](https://app.codecov.io/gh/bgreenwell/pdp?branch=master)
[![Total
Downloads](https://cranlogs.r-pkg.org/badges/grand-total/pdp)](https://cranlogs.r-pkg.org/badges/grand-total/pdp)
<!-- badges: end -->

## Overview

[pdp](https://cran.r-project.org/package=pdp) is an R package for
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

A detailed introduction to [pdp](https://cran.r-project.org/package=pdp)
has been published in The R Journal: “pdp: An R Package for Constructing
Partial Dependence Plots”,
<https://journal.r-project.org/archive/2017/RJ-2017-016/index.html>. You
can track development at <https://github.com/bgreenwell/pdp>. To report
bugs or issues, contact the main author directly or submit them to
<https://github.com/bgreenwell/pdp/issues>. For additional documentation
and examples, visit the [package
website](https://bgreenwell.github.io/pdp/index.html).

As of right now, `pdp` exports the following functions:

-   `partial()` - compute partial dependence functions and individual
    conditional expectations (i.e., objects of class `"partial"` and
    `"ice"`, respectively) from various fitted model objects;

-   `plotPartial()"` - construct `lattice`-based PDPs and ICE curves;

-   `autoplot()` - construct `ggplot2`-based PDPs and ICE curves;

-   ~~`topPredictors()` extract most “important” predictors from various
    types of fitted models.~~ see
    [vip](https://koalaverse.github.io/vip/index.html) instead for a
    more robust and flexible replacement;

-   `exemplar()` - construct an exemplar record from a data frame
    (**experimental** feature that may be useful for constructing fast,
    approximate feature effect plots.)

## Installation

``` r
# The easiest way to get pdp is to install it from CRAN:
install.packages("pdp")

# Alternatively, you can install the development version from GitHub:
if (!("remotes" %in% installed.packages()[, "Package"])) {
  install.packages("remotes")
}
remotes::install_github("bgreenwell/pdp")
```
