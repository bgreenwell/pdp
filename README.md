pdp <img src="man/figures/pdp-logo.png" align="right" width="130" height="150" />
=================================================================================

[![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/pdp)](https://cran.r-project.org/package=pdp)
[![Build
Status](https://travis-ci.org/bgreenwell/pdp.svg?branch=master)](https://travis-ci.org/bgreenwell/pdp)
[![AppVeyor Build
Status](https://ci.appveyor.com/api/projects/status/github/bgreenwell/pdp?branch=master&svg=true)](https://ci.appveyor.com/project/bgreenwell/pdp)
[![Coverage
Status](https://img.shields.io/codecov/c/github/bgreenwell/pdp.svg)](https://codecov.io/github/bgreenwell/pdp?branch=master)
[![Downloads](http://cranlogs.r-pkg.org/badges/pdp)](http://cranlogs.r-pkg.org/badges/pdp)
[![Total
Downloads](http://cranlogs.r-pkg.org/badges/grand-total/pdp)](http://cranlogs.r-pkg.org/badges/grand-total/pdp)
[![lifecycle](https://img.shields.io/badge/lifecycle-maturing-brightgreen.svg)](https://www.tidyverse.org/lifecycle/#stable)

Overview
--------

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

As of right now, `pdp` exports four functions:

-   `partial()` - compute partial dependence functions and individual
    conditional expectations (i.e., objects of class `"partial"` and
    `"ice"`, respectively) from various fitted model objects;

-   `plotPartial()"` - construct `lattice`-based PDPs and ICE curves;

-   `autoplot()` - construct `ggplot2`-based PDPs and ICE curves;

-   `topPredictors()` extract most “important” predictors from various
    types of fitted models. (Will soon be replaced by functionality from
    [vip](https://koalaverse.github.io/vip/index.html).)

Installation
------------

``` r
# The easiest way to get pdp is to install it from CRAN:
install.packages("pdp")

# Alternatively, you can install the development version from GitHub:
if (!requireNamespace("devtools")) {
  install.packages("devtools")
}
devtools::install_github("bgreenwell/pdp")
```
