#' Extract Most "Important" Predictors (Experimental)
#'
#' Extract the most "important" predictors for regression and classification
#' models.
#'
#' @param object A fitted model object of appropriate class (e.g., \code{"gbm"},
#' \code{"lm"}, \code{"randomForest"}, etc.).
#'
#' @param n Integer specifying the number of predictors to return. Default is
#' \code{1} meaning return the single most important predictor.
#'
#' @param ... Additional optional arguments to be passed onto
#' \code{\link[caret]{varImp}}.
#'
#' @details
#' This function uses the generic function \code{\link[caret]{varImp}} to
#' calculate variable importance scores for each predictor. After that, they are
#' sorted at the names of the \code{n} highest scoring predictors are returned.
#'
#' @rdname topPredictors
#' @export
#' @examples
#' \dontrun{
#' #
#' # Regression example (requires randomForest package to run)
#' #
#'
#' Load required packages
#' library(ggplot2)
#' library(randomForest)
#'
#' # Fit a random forest to the mtcars dataset
#' data(mtcars, package = "datasets")
#' set.seed(101)
#' mtcars.rf <- randomForest(mpg ~ ., data = mtcars, mtry = 5, importance = TRUE)
#'
#' # Topfour predictors
#' top4 <- topPredictors(mtcars.rf, n = 4)
#'
#' # Construct partial dependence functions for top four predictors
#' pd <- NULL
#' for (i in top4) {
#'   tmp <- partial(mtcars.rf, pred.var = i)
#'   names(tmp) <- c("x", "y")
#'   pd <- rbind(pd,  cbind(tmp, predictor = i))
#' }
#'
#' # Display partial dependence functions
#' ggplot(pd, aes(x, y)) +
#'   geom_line() +
#'   facet_wrap(~ predictor, scales = "free") +
#'   theme_bw() +
#'   ylab("mpg")
#'
#' }
topPredictors <- function(object, n = 1L, ...) {
  UseMethod("topPredictors")
}


#' @rdname topPredictors
#' @export
topPredictors.default <- function(object, n = 1L, ...) {
  imp <- caret::varImp(object, ...)
  if (n > nrow(imp)) {
    n <- nrow(imp)
  }
  imp <- imp[order(imp[, "Overall"], decreasing = TRUE), , drop = FALSE]
  rownames(imp)[seq_len(n)]
}


#' @rdname topPredictors
#' @export
topPredictors.train <- function(object, n = 1L, ...) {
  # FIXME: What about filterVarImp?
  imp <- caret::varImp(object, ...)$importance
  if (n > nrow(imp)) {
    n <- nrow(imp)
  }
  imp <- imp[order(imp$Overall, decreasing = TRUE), , drop = FALSE]
  rownames(imp)[seq_len(n)]
}
