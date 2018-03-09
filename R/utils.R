#' Pipe operator
#'
#' See \code{\link[magrittr]{\%>\%}} for more details.
#'
#' @name %>%
#' @rdname pipe
#' @keywords internal
#' @export
#' @importFrom magrittr %>%
#' @usage lhs \%>\% rhs
NULL


#' Arrange multiple grobs on a page
#'
#' See \code{\link[gridExtra]{grid.arrange}} for more details.
#'
#' @name grid.arrange
#' @rdname grid.arrange
#' @keywords internal
#' @export
#' @importFrom gridExtra grid.arrange
#' @usage grid.arrange(..., newpage = TRUE)
NULL


#' Retrieve the last Trellis Object
#'
#' See \code{\link[lattice]{trellis.last.object}} for more details.
#'
#' @name trellis.last.object
#' @rdname trellis.last.object
#' @keywords internal
#' @export
#' @importFrom lattice  trellis.last.object
#' @usage trellis.last.object(..., prefix)
NULL


#' @keywords internal
averageIceCurves <- function(object) {
  UseMethod("averageIceCurves")
}


#' @keywords internal
averageIceCurves.ice <- function(object) {
  yhat <- tapply(object[["yhat"]], INDEX = as.factor(object[[1L]]),
                 FUN = mean, simplify = FALSE)
  res <- data.frame("x" = object[seq_len(length(yhat)), 1L, drop = TRUE],
                    "yhat" = unlist(yhat))
  names(res)[1L] <- names(object)[1L]
  res
}


#' @keywords internal
averageIceCurves.cice <- function(object) {
  averageIceCurves.ice(object)
}


#' @keywords internal
averageIceCurves.partial <- function(object) {
  averageIceCurves.ice(object)
}


#' @keywords internal
centerIceCurves <- function(object) {
  UseMethod("centerIceCurves")
}


#' @keywords internal
centerIceCurves.ice <- function(object) {
  yhat <- tapply(object[["yhat"]], INDEX = as.factor(object[["yhat.id"]]),
                 FUN = function(x) x - x[1L], simplify = FALSE)
  res <- data.frame("x" = object[[1L]],
                    "yhat" = unlist(yhat),
                    "yhat.id" = object["yhat.id"])
  names(res)[1L] <- names(object)[1L]
  class(res) <- c("data.frame", "cice")
  res
}


#' @keywords internal
checkFactorLevels <- function(x, y) {

}


#' @keywords internal
copyClasses <- function(x, y) {
  x.names <- names(x)
  y.names <- names(y)
  if (length(setdiff(x.names, y.names)) > 0) {
    stop("Data frame x contains columns not present in data frame y.")
  }
  column.names <- intersect(x.names, y.names)
  for (name in column.names) {
    # Do the classes match?
    if (!identical(class(x[[name]]), class(y[[name]])) ||
        !identical(levels(x[[name]]), levels(y[[name]]))) {
      # Convert to numeric or integer class
      if (is.numeric(y[[name]])) {
        if (is.integer(y[[name]])) {
          x[[name]] <- as.integer(x[[name]])
        } else {
          x[[name]] <- as.numeric(x[[name]])
        }
      }
      # Convert to factor or ordered class
      if (is.factor(y[[name]])) {
        if (is.ordered(y[[name]])) {
          x[[name]] <- as.ordered(x[[name]])
        } else {
          x[[name]] <- as.factor(x[[name]])
        }
        levels(x[[name]]) <- levels(y[[name]])
        # if (!all(levels(y[[name]]) %in% x[[name]])) {
        #   stop("Factors levels ", paste0("{", paste(
        #     levels(y[[name]])[!(levels(y[[name]]) %in% x[[name]])],
        #     collapse = ", "), "}"), " for predictor variable ", name,
        #     " found in training data, but not in data supplied to `pred.grid`.",
        #     call. = FALSE)
        # } else {
        #   levels(x[[name]]) <- levels(y[[name]])
        # }
      }
      # Convert to character
      if (is.character(y[[name]])) {
        x[[name]] <- as.character(x[[name]])
      }
      # Convert to logical
      if (is.logical(y[[name]])) {
        x[[name]] <- as.logical(x[[name]])
      }
    }
  }
  # Sanity check
  stopifnot(all.equal(sapply(x[column.names], class),
                      sapply(y[column.names], class)))
  x  # return x with copied classes
}


#' @keywords internal
multiClassLogit <- function(x, which.class = 1L) {
  if (is.data.frame(x)) {
    x <- data.matrix(x)
  }
  stopifnot(is.matrix(x))  # x should be a nclass by n probability matrix
  eps <- .Machine$double.eps
  log(ifelse(x[, which.class] > 0, x[, which.class], eps)) -
    rowMeans(log(ifelse(x > 0, x, eps)))
}


#' #' @keywords internal
#' avgLogit <- function(x, which.class = 1L) {
#'   if (is.data.frame(x)) {
#'     x <- data.matrix(x)
#'   }
#'   stopifnot(is.matrix(x))  # x should be a nclass by n probability matrix
#'   eps <- .Machine$double.eps
#'   mean(log(ifelse(x[, which.class] > 0, x[, which.class], eps)) -
#'          rowMeans(log(ifelse(x > 0, x, eps))), na.rm = TRUE)
#' }


#' @keywords internal
trainCHull <- function(pred.var, pred.grid, train) {
  if (length(pred.var) >= 2 && is.numeric(pred.grid[, 1L]) &&
      is.numeric(pred.grid[, 2L])) {  # if the first two columns are numeric
    if (is.data.frame(train)) {
      train <- data.matrix(train)  # mgcv::in.out requires a matrix
    }
    X <- stats::na.omit(train[, pred.var[1L:2L]])
    Y <- stats::na.omit(data.matrix(pred.grid[, 1L:2L]))
    hpts <- grDevices::chull(X)
    hpts <- c(hpts, hpts[1L])
    keep <- mgcv::in.out(X[hpts, ], Y)
    pred.grid[keep, ]
  } else {
    pred.grid
  }
}
