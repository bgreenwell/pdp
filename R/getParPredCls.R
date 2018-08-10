#' @keywords internal
getParClsLogit <- function(object, newdata, which.class, ...) {
  UseMethod("getParClsLogit")
}


#' @keywords internal
getParClsProb <- function(object, newdata, which.class, ...) {
  UseMethod("getParClsProb")
}


#' @keywords internal
getParClsLogit.default <- function(object, newdata, which.class, ...) {
  pr <- stats::predict(object, newdata = newdata, type = "prob", ...)
  mean(multiclass_logit(pr, which.class = which.class), na.rm = TRUE)
}


#' @keywords internal
getParClsProb.default <- function(object, newdata, which.class, ...) {
  pr <- stats::predict(object, newdata = newdata, type = "prob", ...)
  mean(pr[, which.class], na.rm = TRUE)
}


#' @keywords internal
getParClsLogit.BinaryTree <- function(object, newdata, which.class, ...) {
  pr <- stats::predict(object, newdata = newdata, type = "prob", ...)
  mean(multiclass_logit(do.call(rbind, pr), which.class = which.class),
       na.rm = TRUE)
}


#' @keywords internal
getParClsProb.BinaryTree <- function(object, newdata, which.class, ...) {
  pr <- stats::predict(object, newdata = newdata, type = "prob", ...)
  mean(do.call(rbind, pr)[, which.class], na.rm = TRUE)
}


#' @keywords internal
getParClsLogit.bagging <- function(object, newdata, which.class, ...) {
  pr <- stats::predict(object, newdata = newdata, ...)$prob
  mean(multiclass_logit(pr, which.class = which.class), na.action = TRUE)
}


#' @keywords internal
getParClsProb.bagging <- function(object, newdata, which.class, ...) {
  pr <- stats::predict(object, newdata = newdata, ...)$prob
  mean(pr[, which.class], na.rm = TRUE)
}


#' @keywords internal
getParClsLogit.boosting <- function(object, newdata, which.class, ...) {
  pr <- stats::predict(object, newdata = newdata, ...)$prob
  mean(multiclass_logit(pr, which.class = which.class), na.rm = TRUE)
}


#' @keywords internal
getParClsProb.boosting <- function(object, newdata, which.class, ...) {
  pr <- stats::predict(object, newdata = newdata, ...)$prob
  mean(pr[, which.class], na.rm = TRUE)
}


#' @keywords internal
getParClsLogit.earth <- function(object, newdata, which.class, ...) {
  pr <- stats::predict(object, newdata = newdata, type = "response", ...)
  mean(multiclass_logit(cbind(pr, 1 - pr), which.class = which.class),
       na.rm = TRUE)
}


#' @keywords internal
getParClsProb.earth <- function(object, newdata, which.class, ...) {
  pr <- stats::predict(object, newdata = newdata, type = "response", ...)
  mean(cbind(pr, 1 - pr)[, which.class], na.rm = TRUE)
}


#' @keywords internal
getParClsLogit.fda <- function(object, newdata, which.class, ...) {
  pr <- stats::predict(object, newdata = newdata, type = "posterior", ...)
  mean(multiclass_logit(pr, which.class = which.class),
       na.rm = TRUE)
}


#' @keywords internal
getParClsProb.fda <- function(object, newdata, which.class, ...) {
  pr <- stats::predict(object, newdata = newdata, type = "posterior", ...)
  mean(pr[, which.class], na.rm = TRUE)
}


#' @keywords internal
getParClsLogit.gbm <- function(object, newdata, which.class, ...) {
  invisible(utils::capture.output(
    pr <- stats::predict(object, newdata = newdata, type = "response", ...)
  ))
  # It seems that when the response has more than two levels, predict.gbm
  # returns an array. When the response is binary, a vector with predictions
  # for the positive class is returned returned.
  if (NCOL(pr) == 1) {
    mean(multiclass_logit(cbind(pr, 1 - pr), which.class = which.class),
         na.rm = TRUE)
  } else {
    mean(multiclass_logit(pr[, , 1], which.class = which.class), na.rm = TRUE)
  }
}


#' @keywords internal
getParClsProb.gbm <- function(object, newdata, which.class, ...) {
  invisible(utils::capture.output(
    pr <- stats::predict(object, newdata = newdata, type = "response", ...)
  ))
  # It seems that when the response has more than two levels, predict.gbm
  # returns an array. When the response is binary, a vector with predictions
  # for the positive class is returned returned.
  if (NCOL(pr) == 1) {
    mean(cbind(pr, 1 - pr)[, which.class], na.rm = TRUE)
  } else {
    mean(pr[, which.class, 1], na.rm = TRUE)
  }
}


#' @keywords internal
getParClsLogit.glm <- function(object, newdata, which.class, ...) {
  pr <- stats::predict(object, newdata = newdata, type = "response", ...)
  mean(multiclass_logit(cbind(pr, 1 - pr), which.class = which.class),
       na.rm = TRUE)
}


#' @keywords internal
getParClsProb.glm <- function(object, newdata, which.class, ...) {
  pr <- stats::predict(object, newdata = newdata, type = "response", ...)
  mean(cbind(pr, 1 - pr)[, which.class], na.rm = TRUE)
}


#' @keywords internal
getParClsLogit.ksvm <- function(object, newdata, which.class, ...) {
  if (is.null(object@kcall$prob.model)) {
    stop(paste("Cannot obtain predicted probabilities from",
               deparse(substitute(object))))
  }
  pr <- kernlab::predict(object, newdata = newdata, type = "probabilities", ...)
  mean(multiclass_logit(pr, which.class = which.class), na.rm = TRUE)
}


#' @keywords internal
getParClsProb.ksvm <- function(object, newdata, which.class, ...) {
  if (is.null(object@kcall$prob.model)) {
    stop(paste("Cannot obtain predicted probabilities from",
               deparse(substitute(object))))
  }
  pr <- kernlab::predict(object, newdata = newdata,
                         type = "probabilities", ...)
  mean(pr[, which.class], na.rm = TRUE)
}


#' @keywords internal
getParClsLogit.lda <- function(object, newdata, which.class, ...) {
  pr <- stats::predict(object, newdata = newdata, ...)$posterior
  mean(multiclass_logit(pr, which.class = which.class), na.rm = TRUE)
}


#' @keywords internal
getParClsProb.lda <- function(object, newdata, which.class, ...) {
  pr <- stats::predict(object, newdata = newdata, ...)$posterior
  mean(pr[, which.class], na.rm = TRUE)
}


#' @keywords internal
getParClsLogit.naiveBayes <- function(object, newdata, which.class, ...) {
  pr <- stats::predict(object, newdata = newdata, type = "raw", ...)
  mean(multiclass_logit(pr, which.class = which.class), na.rm = TRUE)
}


#' @keywords internal
getParClsProb.naiveBayes <- function(object, newdata, which.class, ...) {
  pr <- stats::predict(object, newdata = newdata, type = "raw", ...)
  mean(pr[, which.class], na.rm = TRUE)
}


#' @keywords internal
getParClsLogit.nnet <- function(object, newdata, which.class, ...) {
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
    mean(multiclass_logit(cbind(pr, 1 - pr), which.class = which.class),
         na.rm = TRUE)
  } else {
    mean(multiclass_logit(pr, which.class = which.class), na.rm = TRUE)
  }
}


#' @keywords internal
getParClsProb.nnet <- function(object, newdata, which.class, ...) {
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
    mean(cbind(pr, 1 - pr)[, which.class], na.rm = TRUE)
  } else {
    mean(pr[, which.class], na.rm = TRUE)
  }
}


#' @keywords internal
getParClsLogit.qda <- function(object, newdata, which.class, ...) {
  pr <- stats::predict(object, newdata = newdata, ...)$posterior
  mean(multiclass_logit(pr, which.class = which.class), na.rm = TRUE)
}


#' @keywords internal
getParClsProb.qda <- function(object, newdata, which.class, ...) {
  pr <- stats::predict(object, newdata = newdata, ...)$posterior
  mean(pr[, which.class], na.rm = TRUE)
}



#' @keywords internal
getParClsLogit.RandomForest <- function(object, newdata, which.class, ...) {
  pr <- stats::predict(object, newdata = newdata, type = "prob", ...)
  mean(multiclass_logit(do.call(rbind, pr), which.class = which.class),
       na.rm = TRUE)
}


#' @keywords internal
getParClsProb.RandomForest <- function(object, newdata, which.class, ...) {
  pr <- stats::predict(object, newdata = newdata, type = "prob", ...)
  mean(do.call(rbind, pr)[, which.class], na.rm = TRUE)
}


#' @keywords internal
getParClsLogit.ranger <- function(object, newdata, which.class, ...) {
  if (object$treetype != "Probability estimation") {
    stop(paste("Cannot obtain predicted probabilities from",
               deparse(substitute(object))))
  }
  pr <- stats::predict(object, data = newdata, ...)$predictions
  mean(multiclass_logit(pr, which.class = which.class), na.rm = TRUE)
}


#' @keywords internal
getParClsProb.ranger <- function(object, newdata, which.class, ...) {
  if (object$treetype != "Probability estimation") {
    stop(paste("Cannot obtain predicted probabilities from",
               deparse(substitute(object))))
  }
  pr <- stats::predict(object, data = newdata, ...)$predictions
  mean(pr[, which.class], na.rm = TRUE)
}


#' @keywords internal
getParClsLogit.svm <- function(object, newdata, which.class, ...) {
  if (is.null(object$call$probability)) {
    stop(paste("Cannot obtain predicted probabilities from",
               deparse(substitute(object))))
  }
  pr <- attr(stats::predict(object, newdata = newdata, probability = TRUE, ...),
             which = "probabilities")
  mean(multiclass_logit(pr, which.class = which.class), na.rm = TRUE)
}


#' @keywords internal
getParClsProb.svm <- function(object, newdata, which.class, ...) {
  if (is.null(object$call$probability)) {
    stop(paste("Cannot obtain predicted probabilities from",
               deparse(substitute(object))))
  }
  pr <- attr(stats::predict(object, newdata = newdata, probability = TRUE, ...),
             which = "probabilities")
  mean(pr[, which.class], na.rm = TRUE)
}


#' @keywords internal
getParClsLogit.xgb.Booster <- function(object, newdata, which.class,
                                        ...) {
  pr <- stats::predict(object, newdata = newdata, reshape = TRUE, ...)
  if (object$params$objective == "binary:logistic") {
    pr <- cbind(pr, 1 - pr)
  }
  mean(multiclass_logit(pr, which.class = which.class), na.rm = TRUE)
}


#' @keywords internal
getParClsProb.xgb.Booster <- function(object, newdata, which.class,
                                       ...) {
  pr <- stats::predict(object, newdata = newdata, reshape = TRUE, ...)
  if (object$params$objective == "binary:logistic") {
    pr <- cbind(pr, 1 - pr)
  }
  mean(pr[, which.class], na.rm = TRUE)
}
