#' pdp: A general framework for constructing partial dependence (i.e., marginal
#' effect) plots from various types machine learning models in R.
#'
#' Partial dependence plots (PDPs) help visualize the relationship between a
#' subset of the features (typically 1-3) and the response while accounting for
#' the average effect of the other predictors in the model. They are
#' particularly effective with black box models like random forests and support
#' vector machines.
#'
#' The development version can be found on GitHub: https://github.com/bgreenwell/pdp.
#' As of right now, \code{pdp} exports four functions:
#' \itemize{
#'   \item{\code{partial}} - construct partial dependence functions (i.e., objects of class \code{"partial"}) from various fitted model objects;
#'   \item{\code{plotPartial}} - plot partial dependence functions (i.e., objects of class \code{"partial"}) using \code{\link[lattice]{lattice}} graphics;
#'   \item{\code{autoplot}} - plot partial dependence functions (i.e., objects of class \code{"partial"}) using \code{\link[ggplot2]{ggplot2}} graphics;
#'   \item{\code{topPredictors}} - extract most "important" predictors from various types of fitted models.
#' }
#'
#' @docType package
#' @name pdp
NULL
