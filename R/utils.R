#' Retrieve the last trellis object
#'
#' See \code{\link[lattice]{trellis.last.object}} for more details.
#'
#' @name trellis.last.object
#' @rdname trellis.last.object
#' @keywords internal
#' @export
#' @importFrom lattice trellis.last.object
#' @usage trellis.last.object(..., prefix)
NULL


#' @keywords internal
average_ice_curves <- function(object) {
  UseMethod("average_ice_curves")
}


#' @keywords internal
average_ice_curves.ice <- function(object) {
  yhat <- tapply(
    object[["yhat"]], INDEX = as.factor(object[[1L]]), FUN = mean,
    simplify = FALSE
  )
  res <- data.frame(
    "x" = object[seq_len(length(yhat)), 1L, drop = TRUE],
    "yhat" = unlist(yhat)
  )
  names(res)[1L] <- names(object)[1L]
  res
}


#' @keywords internal
average_ice_curves.cice <- function(object) {
  average_ice_curves.ice(object)
}


#' @keywords internal
average_ice_curves.partial <- function(object) {
  average_ice_curves.ice(object)
}


#' @keywords internal
center_ice_curves <- function(object) {
  UseMethod("center_ice_curves")
}


#' @keywords internal
center_ice_curves.ice <- function(object) {
  yhat <- tapply(
    object[["yhat"]], INDEX = as.factor(object[["yhat.id"]]),
    FUN = function(x) x - x[1L], simplify = FALSE
  )
  res <- data.frame(
    "x" = object[[1L]],
    "yhat" = unlist(yhat),
    "yhat.id" = object["yhat.id"]
  )
  names(res)[1L] <- names(object)[1L]
  class(res) <- c("cice", "data.frame")
  res
}

#' @keywords internal
copy_classes <- function(x, y) {
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
          x[[name]] <- ordered(x[[name]], levels = levels(y[[name]]))
        } else {
          x[[name]] <- factor(x[[name]], levels = levels(y[[name]]))
        }
        # levels(x[[name]]) <- levels(y[[name]])
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
  stopifnot(all.equal(
    target = sapply(x[column.names], class),
    current = sapply(y[column.names], class))
  )
  x  # return x with copied classes
}


#' @keywords internal
multiclass_logit <- function(x, which.class = 1L) {
  if (is.data.frame(x)) {
    x <- data.matrix(x)
  }
  stopifnot(is.matrix(x))  # x should be a nclass by n probability matrix
  eps <- .Machine$double.eps
  log(ifelse(x[, which.class] > 0, x[, which.class], eps)) -
    rowMeans(log(ifelse(x > 0, x, eps)))
}


#' @keywords internal
train_chull <- function(pred.var, pred.grid, train) {
  if (length(pred.var) >= 2 && is.numeric(pred.grid[, 1L]) &&
      is.numeric(pred.grid[, 2L])) {  # if the first two columns are numeric
    if (is.data.frame(train)) {
      train <- data.matrix(train)  # `in.out()` requires a matrix
    }
    X <- stats::na.omit(train[, pred.var[1L:2L]])
    Y <- stats::na.omit(data.matrix(pred.grid[, 1L:2L]))
    hpts <- grDevices::chull(X)
    hpts <- c(hpts, hpts[1L])
    keep <- in.out(X[hpts, ], Y)
    pred.grid[keep, ]
  } else {
    pred.grid
  }
}


#' @keywords internal
in.out <- function(bnd, x) {
  #
  # Taken from mgcv:::in.out
  #
  ## tests whether point defined by each row of x is inside
  ## or outside boundary defined by bnd. bnd my be made up of multiple
  ## nested loops.
  if (!is.matrix(x)) x <- matrix(x, 1, 2)
  if (is.list(bnd)) { ## convert list of lists to matrix form
    b1 <- bnd[[1]][[1]]
    b2 <- bnd[[1]][[2]]
    if (length(bnd) > 1) for (i in 2:length(bnd)) {
      b1 <- c(b1, NA, bnd[[i]][[1]])
      b2 <- c(b2, NA, bnd[[i]][[2]])
    }
    bnd <- cbind(b1,b2)
  }
  ## replace NA segment separators with a numeric code
  lowLim <- min(bnd, na.rm = TRUE) - mean(abs(bnd), na.rm = TRUE)
  ind <- is.na(rowSums(bnd))
  bnd[ind, ] <- lowLim
  n <- nrow(bnd)
  um <- .C(in_out, bx = as.double(bnd[, 1]), by = as.double(bnd[, 2]),
           break.code = as.double(lowLim), x = as.double(x[, 1]),
           y = as.double(x[, 2]), inside = as.integer(x[, 2] * 0),
           nb = as.integer(n), n = as.integer(nrow(x)))
  as.logical(um$inside)
}
