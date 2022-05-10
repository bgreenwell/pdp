#' Exemplar observation
#'
#' Construct a single "exemplar" record from a data frame. For now, all numeric
#' columns (including \code{"\link{Date}"} objects) are replaced with their
#' corresponding median value and non-numeric columns are replaced with their
#' most frequent value.
#'
#' @param object A data frame, matrix, or
#' \code{\link[Matrix:dgCMatrix-class]{dgCMatrix}} (the latter two are
#' supported by \code{\link[xgboost]{xgboost}}).
#'
#' @return A data frame with the same number of columns as \code{object} and a
#' single row.
#'
#' @rdname exemplar
#'
#' @export
#'
#' @examples
#' set.seed(1554)  # for reproducibility
#' train <- data.frame(
#'   x = rnorm(100),
#'   y = sample(letters[1L:3L], size = 100, replace = TRUE,
#'              prob = c(0.1, 0.1, 0.8))
#' )
#' exemplar(train)
exemplar <- function(object) {
  UseMethod("exemplar")
}


#' @rdname exemplar
#'
#' @export
exemplar.data.frame <- function(object) {
  res <- as.data.frame(lapply(object, FUN = function(x) {
    if (inherits(x, what = c("numeric", "integer", "Date"))) {
      stats::median(x, na.rm = TRUE)
    } else {
      names(which.max(table(x, useNA = "no")))
    }
  }))
  copy_classes(res, y = object)  # make sure column types are the same
}


#' @rdname exemplar
#'
#' @export
exemplar.matrix <- function(object) {
  # FIXME: For now, just use the median rounded up to the nearest integer
  res <- ceiling(apply(object, MARGIN = 2, FUN = stats::median))
  data.matrix(t(res))
}


#' @rdname exemplar
#'
#' @export
exemplar.dgCMatrix <- function(object) {
  res <- exemplar.matrix(data.matrix(object))
  methods::as(data.matrix(res), Class = "dgCMatrix")
}
