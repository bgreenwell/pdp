## Resubmission

This is a resubmission. In this version I have:

* Replaced the invalid UCI repository URL in `man/boston.Rd`.
* Updated the moved vip repository URL in NEWS.md.

## Submission

Update from 0.8.3 to 0.10.0. The ggplot2-based `autoplot()` methods were
replaced by lightweight base-graphics `plot()` methods (tinyplot), dropping
the ggplot2 and rlang dependencies; the long-deprecated `topPredictors()` was
removed; and the bundled `pima` data set now contains synthetic data from
mlbench 2.1-11 (`SynthDiabetes2`), since mlbench withdrew the original Pima
Indians diabetes data over consent concerns.

## R CMD check results

0 errors | 0 warnings | 0 notes

## Reverse dependencies

We checked the 13 reverse dependencies on CRAN. One is affected:

* fastml: `plot_ice()` calls `ggplot2::autoplot()` on a `pdp::partial()`
  result, which no longer has an `autoplot()` method. The maintainer has been
  notified and pointed to `plot()` on the result as the replacement.

mvtweedie's vignette calls `plotPartial()`, which still works but now emits a
deprecation warning.
