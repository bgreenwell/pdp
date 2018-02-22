#' @keywords internal
getIceClsLogit <- function(object, newdata, which.class, ...) {
  UseMethod("getIceClsLogit")
}


#' @keywords internal
getIceClsProb <- function(object, newdata, which.class, ...) {
  UseMethod("getIceClsProb")
}


#' @keywords internal
getIceClsLogit.default <- function(object, newdata, which.class, ...) {
  pr <- stats::predict(object, newdata = newdata, type = "prob", ...)
  multiClassLogit(pr, which.class = which.class)
}


#' @keywords internal
getIceClsProb.default <- function(object, newdata, which.class, ...) {
  pr <- stats::predict(object, newdata = newdata, type = "prob", ...)
  pr[, which.class]
}


#' @keywords internal
getIceClsLogit.BinaryTree <- function(object, newdata, which.class, ...) {
  pr <- stats::predict(object, newdata = newdata, type = "prob", ...)
  multiClassLogit(do.call(rbind, pr), which.class = which.class)
}


#' @keywords internal
getIceClsProb.BinaryTree <- function(object, newdata, which.class, ...) {
  pr <- stats::predict(object, newdata = newdata, type = "prob", ...)
  do.call(rbind, pr)[, which.class]
}


#' @keywords internal
getIceClsLogit.bagging <- function(object, newdata, which.class, ...) {
  pr <- stats::predict(object, newdata = newdata, ...)$prob
  multiClassLogit(pr, which.class = which.class)
}


#' @keywords internal
getIceClsProb.bagging <- function(object, newdata, which.class, ...) {
  pr <- stats::predict(object, newdata = newdata, ...)$prob
  pr[, which.class]
}


#' @keywords internal
getIceClsLogit.boosting <- function(object, newdata, which.class, ...) {
  pr <- stats::predict(object, newdata = newdata, ...)$prob
  multiClassLogit(pr, which.class = which.class)
}


#' @keywords internal
getIceClsProb.boosting <- function(object, newdata, which.class, ...) {
  pr <- stats::predict(object, newdata = newdata, ...)$prob
  pr[, which.class]
}


#' @keywords internal
getIceClsLogit.earth <- function(object, newdata, which.class, ...) {
  pr <- stats::predict(object, newdata = newdata, type = "response", ...)
  multiClassLogit(cbind(pr, 1 - pr), which.class = which.class)
}


#' @keywords internal
getIceClsProb.earth <- function(object, newdata, which.class, ...) {
  pr <- stats::predict(object, newdata = newdata, type = "response", ...)
  cbind(pr, 1 - pr)[, which.class]
}


#' @keywords internal
getIceClsLogit.fda <- function(object, newdata, which.class, ...) {
  pr <- stats::predict(object, newdata = newdata, type = "posterior", ...)
  multiClassLogit(pr, which.class = which.class)
}


#' @keywords internal
getIceClsProb.fda <- function(object, newdata, which.class, ...) {
  pr <- stats::predict(object, newdata = newdata, type = "posterior", ...)
  pr[, which.class]
}


#' @keywords internal
getIceClsLogit.gbm <- function(object, newdata, which.class, ...) {
  invisible(utils::capture.output(
    pr <- stats::predict(object, newdata = newdata, type = "response", ...)
  ))
  multiClassLogit(cbind(pr, 1 - pr), which.class = which.class)
}


#' @keywords internal
getIceClsProb.gbm <- function(object, newdata, which.class, ...) {
  invisible(utils::capture.output(
    pr <- stats::predict(object, newdata = newdata, type = "response", ...)
  ))
  cbind(pr, 1 - pr)[, which.class]
}


#' @keywords internal
getIceClsLogit.glm <- function(object, newdata, which.class, ...) {
  pr <- stats::predict(object, newdata = newdata, type = "response", ...)
  multiClassLogit(cbind(pr, 1 - pr), which.class = which.class)
}


#' @keywords internal
getIceClsProb.glm <- function(object, newdata, which.class, ...) {
  pr <- stats::predict(object, newdata = newdata, type = "response", ...)
  cbind(pr, 1 - pr)[, which.class]
}


#' @keywords internal
getIceClsLogit.ksvm <- function(object, newdata, which.class, ...) {
  if (is.null(object@kcall$prob.model)) {
    stop(paste("Cannot obtain predicted probabilities from",
               deparse(substitute(object))))
  }
  pr <- kernlab::predict(object, newdata = newdata, type = "probabilities", ...)
  multiClassLogit(pr, which.class = which.class)
}


#' @keywords internal
getIceClsProb.ksvm <- function(object, newdata, which.class, ...) {
  if (is.null(object@kcall$prob.model)) {
    stop(paste("Cannot obtain predicted probabilities from",
               deparse(substitute(object))))
  }
  pr <- kernlab::predict(object, newdata = newdata,
                         type = "probabilities", ...)
  pr[, which.class]
}


#' @keywords internal
getIceClsLogit.lda <- function(object, newdata, which.class, ...) {
  pr <- stats::predict(object, newdata = newdata, ...)$posterior
  multiClassLogit(pr, which.class = which.class)
}


#' @keywords internal
getIceClsProb.lda <- function(object, newdata, which.class, ...) {
  pr <- stats::predict(object, newdata = newdata, ...)$posterior
  pr[, which.class]
}


#' @keywords internal
getIceClsLogit.naiveBayes <- function(object, newdata, which.class, ...) {
  pr <- stats::predict(object, newdata = newdata, type = "raw", ...)
  multiClassLogit(pr, which.class = which.class)
}


#' @keywords internal
getIceClsProb.naiveBayes <- function(object, newdata, which.class, ...) {
  pr <- stats::predict(object, newdata = newdata, type = "raw", ...)
  pr[, which.class]
}


#' @keywords internal
getIceClsLogit.nnet <- function(object, newdata, which.class, ...) {
  pr <- if (inherits(object, "multinom")) {
    stats::predict(object, newdata = newdata, type = "probs", ...)
  } else {
    stats::predict(object, newdata = newdata, type = "raw", ...)
  }
  # It seems that when the response has more than two levels, predict.nnet
  # returns a matrix whose column names are the same as the factor levels. When
  # the response is binary, a single-columned matrix with no column name is
  # returned. For multinomial models, a vector is returned when the response has
  # only two classes.
  if (is.null(ncol(pr)) || ncol(pr) == 1) {
    multiClassLogit(cbind(pr, 1 - pr), which.class = which.class)
  } else {
    multiClassLogit(pr, which.class = which.class)
  }
}


#' @keywords internal
getIceClsProb.nnet <- function(object, newdata, which.class, ...) {
  pr <- if (inherits(object, "multinom")) {
    stats::predict(object, newdata = newdata, type = "probs", ...)
  } else {
    stats::predict(object, newdata = newdata, type = "raw", ...)
  }
  # It seems that when the response has more than two levels, predict.nnet
  # returns a matrix whose column names are the same as the factor levels. When
  # the response is binary, a single-columned matrix with no column name is
  # returned. For multinomial models, a vector is returned when the response has
  # only two classes.
  if (is.null(ncol(pr)) || ncol(pr) == 1) {
    cbind(pr, 1 - pr)[, which.class]
  } else {
    pr[, which.class]
  }
}


#' @keywords internal
getIceClsLogit.qda <- function(object, newdata, which.class, ...) {
  pr <- stats::predict(object, newdata = newdata, ...)$posterior
  multiClassLogit(pr, which.class = which.class)
}


#' @keywords internal
getIceClsProb.qda <- function(object, newdata, which.class, ...) {
  pr <- stats::predict(object, newdata = newdata, ...)$posterior
  pr[, which.class]
}



#' @keywords internal
getIceClsLogit.RandomForest <- function(object, newdata, which.class, ...) {
  pr <- stats::predict(object, newdata = newdata, type = "prob", ...)
  multiClassLogit(do.call(rbind, pr), which.class = which.class)
}


#' @keywords internal
getIceClsProb.RandomForest <- function(object, newdata, which.class, ...) {
  pr <- stats::predict(object, newdata = newdata, type = "prob", ...)
  do.call(rbind, pr)[, which.class]
}


#' @keywords internal
getIceClsLogit.ranger <- function(object, newdata, which.class, ...) {
  if (object$treetype != "Probability estimation") {
    stop(paste("Cannot obtain predicted probabilities from",
               deparse(substitute(object))))
  }
  pr <- stats::predict(object, data = newdata, ...)$predictions
  multiClassLogit(pr, which.class = which.class)
}


#' @keywords internal
getIceClsProb.ranger <- function(object, newdata, which.class, ...) {
  if (object$treetype != "Probability estimation") {
    stop(paste("Cannot obtain predicted probabilities from",
               deparse(substitute(object))))
  }
  pr <- stats::predict(object, data = newdata, ...)$predictions
  pr[, which.class]
}


#' @keywords internal
getIceClsLogit.svm <- function(object, newdata, which.class, ...) {
  if (is.null(object$call$probability)) {
    stop(paste("Cannot obtain predicted probabilities from",
               deparse(substitute(object))))
  }
  pr <- attr(stats::predict(object, newdata = newdata, probability = TRUE, ...),
             which = "probabilities")
  multiClassLogit(pr, which.class = which.class)
}


#' @keywords internal
getIceClsProb.svm <- function(object, newdata, which.class, ...) {
  if (is.null(object$call$probability)) {
    stop(paste("Cannot obtain predicted probabilities from",
               deparse(substitute(object))))
  }
  pr <- attr(stats::predict(object, newdata = newdata, probability = TRUE, ...),
             which = "probabilities")
  pr[, which.class]
}


#' @keywords internal
getIceClsLogit.xgb.Booster <- function(object, newdata, which.class,
                                        ...) {
  pr <- stats::predict(object, newdata = newdata, reshape = TRUE, ...)
  if (object$params$objective == "binary:logistic") {
    pr <- cbind(pr, 1 - pr)
  }
  multiClassLogit(pr, which.class = which.class)
}


#' @keywords internal
getIceClsProb.xgb.Booster <- function(object, newdata, which.class,
                                       ...) {
  pr <- stats::predict(object, newdata = newdata, reshape = TRUE, ...)
  if (object$params$objective == "binary:logistic") {
    pr <- cbind(pr, 1 - pr)
  }
  pr[, which.class]
}
