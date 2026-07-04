#' pdp: A general framework for constructing partial dependence (i.e., marginal
#' effect) plots from various types of machine learning models in R.
#'
#' Partial dependence plots (PDPs) help visualize the relationship between a
#' subset of the features (typically 1-3) and the response while accounting for
#' the average effect of the other predictors in the model. They are
#' particularly effective with black box models like random forests and support
#' vector machines.
#'
#' The development version can be found on GitHub:
#' <https://github.com/bgreenwell/pdp>. As of right now, pdp exports the
#' following functions:
#'
#' - `partial()` - construct partial dependence functions (i.e., objects of
#'   class `"partial"`) from various fitted model objects;
#' - `plot()` - plot partial dependence functions (i.e., objects of class
#'   `"partial"`) using lightweight base R graphics via
#'   [tinyplot::tinyplot()] (or **lattice** graphics whenever
#'   `lattice = TRUE`);
#' - `exemplar()` - construct a single "exemplar" record from a data frame.
#'
#' @keywords internal
"_PACKAGE"

## usethis namespace: start
## usethis namespace: end
NULL
