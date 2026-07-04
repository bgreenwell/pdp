# pdp 0.9.1

## Deprecations

* `plotPartial()` is deprecated in favor of the consolidated `plot()`
interface: the `plot()` methods gained a `lattice` argument, so
`plot(..., lattice = TRUE)` now produces the same lattice-based displays
(including 3-D wireframe surfaces and paneled three-predictor plots).
`plotPartial()` continues to work (with a warning) but will be removed in a
future release.

## Bug fixes

* Plotting now works for non-syntactic predictor names (e.g., names containing
dashes or spaces) in both the tinyplot and lattice engines
[(#113)](https://github.com/bgreenwell/pdp/issues/113).

* `partial(chull = TRUE)` no longer fails for sparse (`"dgCMatrix"`) training
data [(#77)](https://github.com/bgreenwell/pdp/issues/77).

* Plotting multi-predictor output from `pred.fun` (i.e., objects with a
`yhat.id` column and more than one predictor) now throws an informative error
instead of producing a nonsense display
[(#111)](https://github.com/bgreenwell/pdp/issues/111),
[(#112)](https://github.com/bgreenwell/pdp/issues/112).

* Failing to recover the training data (e.g., for recent **xgboost** models
when `train` is not supplied) now always produces the informative "please
supply the training data" error rather than a cryptic `match.call()` failure
[(#137)](https://github.com/bgreenwell/pdp/issues/137).

## New features

* `pred.var` can now be omitted whenever `pred.grid` is supplied; it defaults
to `colnames(pred.grid)`
[(#122)](https://github.com/bgreenwell/pdp/issues/122).

* New `frac` argument in `partial()` for randomly sampling a fraction of the
training data before computing the partial dependence function; mostly useful
for reducing the number of ICE curves and/or computation time
[(#74)](https://github.com/bgreenwell/pdp/issues/74).

* New `color.by` argument in the `plot()` methods for coloring ICE/c-ICE
curves by another feature [(#81)](https://github.com/bgreenwell/pdp/issues/81).

* New `bars` argument in `plot.partial()` for displaying factor predictors as
bar plots instead of points
[(#132)](https://github.com/bgreenwell/pdp/issues/132).

* `exemplar()` gained a `cats` argument for matrix-like objects so categorical
columns are summarized by their most frequent value (rather than a rounded
median); used by `partial(approx = TRUE)`
[(#115)](https://github.com/bgreenwell/pdp/issues/115).

## Miscellaneous

* Removed the (long stale) `slowtests/` directory; its coverage is redundant
with the `tinytest` suite and the new vignettes.

* Pruned Suggests packages that were no longer used anywhere in the package
(**adabag**, **AmesHousing**, **Cubist**, **ipred**, **mda**, **partykit**,
and **vip**).


# pdp 0.9.0

## Breaking changes

* The ggplot2-based `autoplot()` methods have been removed in favor of new,
lightweight base R `plot()` methods built on
[tinyplot](https://grantmcdermott.com/tinyplot/). Consequently,
`partial()`'s `plot.engine` argument now accepts `"tinyplot"` in place of
`"ggplot2"`, and **pdp** no longer depends on **ggplot2** or **rlang**.

* `"tinyplot"` is now the default plotting engine for
`partial(..., plot = TRUE)`; note that it draws the plot directly (as a side
effect) and returns the data frame of partial dependence values invisibly.
Use `plot.engine = "lattice"` for the previous behavior (i.e., a returned
`"trellis"` object).

## Bug fixes

* Fixed a serious bug in the recursive (i.e., weighted tree traversal) method
for `"gbm"` objects that produced incorrect partial dependence values for
factor predictors; the factor levels were passed to the underlying C++ routine
using 1-based (rather than 0-based) integer codes, shifting each level's value
and reading out of bounds for the last level.

* `partial()` no longer errors for `"gbm"` objects fit with list-valued
distributions (e.g., `distribution = list(name = "quantile", alpha = 0.5)`).

* The convex hull displayed by `plotPartial(chull = TRUE)` is now correct
whenever the training data contain missing values.

* Conflicting grid options (e.g., specifying both `grid.resolution` and
`quantiles`) now always throw an error, even when all of the predictors listed
in `pred.var` are factors.

* Removed a stray `"FALSE"` that was appended to the message displayed when
requesting a progress bar with the recursive method.

## New features

* New tinyplot-based `plot()` methods for `"partial"`, `"ice"`, and `"cice"`
objects; see `?plot.partial` for details and examples.

* New `batch.size` argument in `partial()` for scoring multiple grid points
per call to `predict()` (i.e., batching); this is often substantially faster
than the default one-call-per-grid-point approach at the cost of additional
memory. For example, try `batch.size = 1e6` to score (roughly) one million
rows per call.

## Miscellaneous

* **foreach** was moved from Imports to Suggests; it is now only required for
parallel execution (i.e., whenever `parallel = TRUE`).

* Removed unused packages from Suggests (**keras**, **reticulate**, and
**dplyr**).

* `topPredictors()` (which is deprecated) now throws an informative error when
**caret** is not installed.

* Internal cleanup: the brute force method (`pardep()`) was consolidated from
four nearly identical loops into one, and the prediction wrappers in
`get_predictions.R` now share a common helper.

* Fixed failing tests due to changes in the `xgboost` package.


# pdp 0.8.2

## Minor changes

* Set `R_NO_REMAP` per changes in CRAN policies.

* Updated package documentation since `@docType "package"` is deprecated.

* Removed unnecessary `get_training_data.Rd` file and cleaned up arguments.

* Update citation file to use `c()` instead of `personList()` and `bibentry()` instead of `citEntry()`.


# pdp 0.8.1

## Bug fixes

* Fixed an ICE plot issue for XGBoost models caused by switching to the [foreach](https://cran.r-project.org/package=foreach) package.

## Minor changes

* Fixed a couple of URLs in the package documentation.

## Breaking changes

* `partial()`'s progress argument now only accepts a logical and defaults to `FALSE`.


# pdp 0.8.0

## New features

* New (experimental) function `exemplar()` for constructing an "exemplar" record from a data frame or matrix-like object. See `?pdp::exemplar` for details [(#91)](https://github.com/bgreenwell/pdp/issues/91).

* `partial()` gained a new (experimental) feature via the new `approx` argument. If `approx = TRUE`, then `partial()` will compute predictions across the predictors specified in `pred.var` while holding the other predictors constant (a "poor man's partial dependence" function as Stephen Milborrow, the author of [plotmo](https://cran.r-project.org/package=plotmo), puts it). See `?pdp::partial` for details.

## Breaking changes

* Bumped the R dependency to R (>= 3.6.0) to support the use of `grDevices::hcl.colors()` in `plotPartial()`.

* Function `grid.arrange()` and the forward pipe operator `%>%` are no longer automatically imported from packages [gridExtra](https://cran.r-project.org/package=gridExtra) and [magrittr](https://cran.r-project.org/package=magrittr), respectively; users are encouraged to load them manually if needed.

* Removed the `palette` and `alpha` arguments from `plotPartial()` and `autoplot()`; the latter just got absorbed into the `...` argument. By default, `plotPartial()`'s `col.regions` argument now corresponds to `grDevices::hcl.colors(100)`, which defaults to the same viridis color palette as before, just without the dependency.

* `topPredictors()` is now deprecated and will be removed in the next update. Users are advised to use the [vip](https://github.com/koalaverse/vip) package instead.

## Minor changes

* Added support for gradient boosted Cox proportional hazards models in [gbm](https://cran.r-project.org/package=gbm).

* Removed dependency on the retired [plyr](https://cran.r-project.org/package=plyr) package by relying directly on the [foreach](https://cran.r-project.org/package=foreach) package. Consequently, ICE curves (`ice = TRUE`) are now slightly faster to compute (since the code refactoring avoids having to post-process ICE data from wide to long format) and the corresponding progress bar (`progress = "text"`) is more honest.

  * As a further consequence, the `partial()` function only supports a simple text-based progress bar (`progress = "text"`), but more options will possibly be added later.

* Removed dependency on [viridis](https://cran.r-project.org/package=viridis); consequently, to keep the 'viridis' color palettes in `autoplot()`, this required bumping the [ggplot2](https://cran.r-project.org/package=ggplot2) dependency to version 3.0.0, as well as some other code tweaks under the hood [(#106)](https://github.com/bgreenwell/pdp/issues/106). 

* Removed dependency on [mgcv](https://cran.r-project.org/package=mgcv) by switching to an internal C implementation of [mgcv](https://cran.r-project.org/package=mgcv)'s `in.out()` function [(#107)](https://github.com/bgreenwell/pdp/issues/107). (This is used behind the scenes whenever `partial()` is called with `chull = TRUE`.)

* `"partial"` is now a proper subclass of `"data.frame"` [(#104)](https://github.com/bgreenwell/pdp/issues/104); thanks to @RoelVerbelen for pointing this out.

* Fixed a bug where `rug = TRUE` would not work properly for **xgboost** models whenever calling `partial()` with `plot = TRUE`.

* Fixed a bug in `partial()` where the `cats` argument was never actually passed to `pred_grid()` [(#86)](https://github.com/bgreenwell/pdp/issues/86).

* Fixed a bug in `partial()` for `"gbm"` objects when `recursive = TRUE` that caused factors (including ordered factors) to be coerced to characters. 

## Miscellaneous

* Switched from Travis-CI to GitHub Actions for continuous integration.

* Added [ICEbox](https://cran.r-project.org/package=ICEbox) and [mlbench](https://cran.r-project.org/package=mlbench) to the list of suggested packages.

* Refactored code for easier maintenance.

* Switched to **tinytest** framework and increased test coverage [(#84)](https://github.com/bgreenwell/pdp/issues/84).

* The internal function `get_training_data()`, which is used to (attempt to) extract a fitted model's training data whenever `train` is not specified, is (hopefully) a bit more flexible and robust in certain special cases[(#90)](https://github.com/bgreenwell/pdp/issues/90).

* Minor bug fixes in plotting functions (i.e., `autoplot()` and `plotPartial()`). 

* Training data that inherits from class `"tibble"` is still not officially supported, but shouldn't cause as many errors from this point on.

* Using `autoplot()` with a factor followed by numeric in `pred.var` no longer seems to be an issue [(#79)](https://github.com/bgreenwell/pdp/issues/79).


# pdp 0.7.0

* Added support for `e1071::naiveBayes()`, an implementation of the standard naive Bayes classifier [(#42)](https://github.com/bgreenwell/pdp/issues/42).

* Fixed a bug in `plotPartial()` that caused the `col.regions` argument to have no effect when `levelplot = FALSE` [(#58)](https://github.com/bgreenwell/pdp/issues/58).

* Fixed a bug with categorical variables in `gbm` models when `recursive = TRUE` [(#63)](https://github.com/bgreenwell/pdp/issues/63).

* More informative progress bars (with estimated time to completion!!) powered by the [`progress`](https://cran.r-project.org/package=progress) package. To use, simply call `partial()` with the option `progress = "progress"` [(#66)](https://github.com/bgreenwell/pdp/issues/66).

* Added ORCiD ID to the author field in the `DESCRIPTION` file.

* Way cooler logo?

* `partial()` gained several new plotting options: `plot.engine`, which controls the plotting engine used whenever `plot = TRUE` (current options include `"lattice"` (the default) and `"ggplot2"` [(#71)](https://github.com/bgreenwell/pdp/issues/71). 

* The arguments to `autoplot()` and `plotPartial()` are now more consistent with each other.

* The names of (most) helper functions have changed from lowerCamelCase to snake_case.

* `partial()` now works (better) with tibbles [(#59)](https://github.com/bgreenwell/pdp/issues/59).

* `partial()` now treats `"xgb.Booster"` objects with `objective = "reg:logistc"`
as regression [(#68)](https://github.com/bgreenwell/pdp/issues/68). 

* Removed use of `ggplot2::aes_string()` in `autoplot()` (which is soft deprecated as of `ggplot2` version 3.0.0) [(#73)](https://github.com/bgreenwell/pdp/issues/73).


# pdp 0.6.0

* Properly registered native routines and disabled symbol search.

* Fixed a bug for `gbm` models using the multinomial distribution.

* Refactored code to improve structure.

* `partial()` gained three new options: `inv.link` (experimental), `ice`, and `center`. The latter two have to do with constructing individual conditional expectation (ICE) curves and centered ICE (c-ICE) curves. The `inv.link` option is for transforming predictions from models that can use non-Gaussian distributions (e.g., `glm`, `gbm`, and `xgboost`). Note that these options were added for convenience and the same results (plus much more) can still be obtained using the flexible `pred.fun` argument. [(#36)](https://github.com/bgreenwell/pdp/issues/36).

* `plotPartial()` gained five new options: `center`, `plot.pdp`, `pdp.col`, `pdp.lwd`, and `pdp.lty`; see `?plotPartial` for details.

* Fixed default y-axis label for `autoplot()` with two numeric predictors [(#48)](https://github.com/bgreenwell/pdp/issues/48).

* Added `CITATION` file.

* Better support for neural networks from the `nnet` package.

* Fixed a bug for `nnet::multinom()` models with binary response.


# pdp 0.5.2

* Fixed minor pandoc conversion issue with `README.md`.

* Added subdirectory called `tools` to hold figures for `README.md`.


# pdp 0.5.1

* Registered native routines and disabled symbol search.


# pdp 0.5.0

* Added support for `MASS::lda()`, `MASS::qda()`, and `mda::mars()`.

* New arguments `quantiles`, `probs`, and `trim.outliers` in `partial`. These arguments make it easier to construct PDPs over the relevant range of a numeric predictor without having to specify `pred.grid`, especially when outliers are present in the predictors (which can distort the plotted relationship).

* The `train` argument can now accept matrices; in particular, object of class `"matrix"` or `"dgCMatrix"`. This is useful, for example, when working with XGBoost models (i.e., objects of class `"xgb.Booster"`).

* New logical argument `prob` indicating whether or not partial dependence values for classification problems should be returned on the original probability scale, rather than the centered logit; details for the centered logit can be found on page 370 in the second edition of *The Elements of Statistical Learning*.

* Fixed some typos in `NEWS.md`.

* New function `autoplot` for automatically creating `ggplot2` graphics from `"partial"` objects.


# pdp 0.4.0

* `partial()` is now much faster with `"gbm"` object due to a call to `gbm::plot.gbm()` whenever `pred.grid` is not explicitly given by the user. (`gbm::plot.gbm()` exploits a computational shortcut that does not involve any passes over the training data.)

* New (experimental) function `topPredictors()` for extracting the names of the most "important" predictors. This should make it one step easier (in most cases) to construct PDPs for the most "important"" features in a fitted model.

* A new argument, `pred.fun`, allows the user to supply their own prediction function. Hence, it is possible to obtain PDPs based on the median, rather than the mean. It is also possible to obtain PDPs for classification problems on the probability scale. See `?partial` for examples.

* Minor bug fixes and documentation tweaks.


# pdp 0.3.0

* The `...` argument in the call to `partial()` now refers to additional arguments to be passed onto `stats::predict()` rather than `plyr::aaply()`. For example, using `partial()` with `"gbm"` objects will require specification of `n.trees` which can now simply be passed to `partial()` via the `...` argument.

* Added the following arguments to `partial()`: `progress` (`plyr`-based progress bars), `parallel` (`plyr`/`foreach`-based parallel execution), and `paropts` (list of additional arguments passed onto `foreach` when `parallel = TRUE`).

* Various bug fixes.

* `partial()` now throws an informative error message when the `pred.grid` argument refers to predictors not in the original training data.

* The column name for the predicted value has been changed from `"y"` to `"yhat"`.


# pdp 0.2.0

* `randomForest` is no longer imported.

* Added support for the `caret` package (i.e., objects of class `"train"`).

* Added example data sets: `boston` (corrected Boston housing data) and `pima` (corrected Pima Indians diabetes data).

* Fixed error that sometimes occurred when `chull = TRUE` causing the convex hull to not be computed.

* Refactored `plotPartial()` to be more modular.

* Added `gbm` support for most non-`"binomial"` families`.


# pdp 0.1.0

* `randomForest` is now imported.

* Added examples.


# pdp 0.0.6

* Fixed a non canonical CRAN URL in the README file.


# pdp 0.0.5

* `partial()` now makes sure each column of `pred.grid` has the correct class, levels, etc.

* `partial()` gained a new option, `levelplot`, which defaults to `TRUE`. The original option, `contour`, has changed and now specifies whether or not to add contour lines whenever `levelplot = TRUE`.


# pdp 0.0.4

* Fixed a number of URLs.

* More thorough documentation.


# pdp 0.0.2

* Fixed a couple of URLs and typos.

* Added more thorough documentation.

* Added support for C5.0, Cubist, nonlinear least squares, and XGBoost models.


# pdp 0.0.1

* Initial release.
