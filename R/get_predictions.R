# Prediction wrappers

# Generics ---------------------------------------------------------------------

# Regression

#' @keywords internal
get_predictions <- function(object, newdata, ...) {
  UseMethod("get_predictions")
}


#' @keywords internal
get_predictions.default <- function(object, newdata, inv.link, ...) {
  pred <- stats::predict(object, newdata = newdata, ...)
  if (is.matrix(pred) || is.data.frame(pred)) {
    pred <- pred[, 1L, drop = TRUE]
  }
  if (is.null(inv.link)) {
    pred
  } else {
    inv.link(pred)
  }
}


# Classification

#' @keywords internal
get_probs <- function(object, newdata, which.class, logit, ...) {
  UseMethod("get_probs")
}


#' @keywords internal
get_probs.default <- function(object, newdata, which.class, logit, ...) {
  pr <- stats::predict(object, newdata = newdata, type = "prob", ...)
  if (isTRUE(logit)) {
    multiclass_logit(pr, which.class = which.class)
  } else {
    pr[, which.class]
  }
}


# Package: adabag --------------------------------------------------------------

# Classification

#' @keywords internal
get_probs.bagging <- function(object, newdata, which.class, logit, ...) {
  pr <- stats::predict(object, newdata = newdata, ...)$prob
  if (isTRUE(logit)) {
    multiclass_logit(pr, which.class = which.class)
  } else {
    pr[, which.class]
  }
}

# Classification

#' @keywords internal
get_probs.boosting <- function(object, newdata, which.class, logit, ...) {
  pr <- stats::predict(object, newdata = newdata, ...)$prob
  if (isTRUE(logit)) {
    multiclass_logit(pr, which.class = which.class)
  } else {
    pr[, which.class]
  }
}


# Package: e1071 ---------------------------------------------------------------

# Classification

#' @keywords internal
get_probs.naiveBayes <- function(object, newdata, which.class, logit, ...) {
  pr <- stats::predict(object, newdata = newdata, type = "raw", ...)
  if (isTRUE(logit)) {
    multiclass_logit(pr, which.class = which.class)
  } else {
    pr[, which.class]
  }
}

#' @keywords internal
get_probs.svm <- function(object, newdata, which.class, logit, ...) {
  if (is.null(object$call$probability)) {
    stop(paste("Cannot obtain predicted probabilities from",
               deparse(substitute(object))))
  }
  pr <- attr(stats::predict(object, newdata = newdata, probability = TRUE, ...),
             which = "probabilities")
  if (isTRUE(logit)) {
    multiclass_logit(pr, which.class = which.class)
  } else {
    pr[, which.class]
  }
}


# Package: earth ---------------------------------------------------------------

# Classification

#' @keywords internal
get_probs.earth <- function(object, newdata, which.class, logit, ...) {
  pr <- stats::predict(object, newdata = newdata, type = "response", ...)
  if (isTRUE(logit)) {
    multiclass_logit(cbind(pr, 1 - pr), which.class = which.class)
  } else {
    cbind(pr, 1 - pr)[, which.class]
  }
}


# Package: gbm -----------------------------------------------------------------

# Regression

#' @keywords internal
get_predictions.gbm <- function(object, newdata, inv.link, ...) {
  invisible(utils::capture.output(
    pred <- stats::predict(object, newdata = newdata, ...)
  ))
  if (is.null(inv.link)) {
    pred
  } else {
    inv.link(pred)
  }
}

# Classification

#' @keywords internal
get_probs.gbm <- function(object, newdata, which.class, logit, ...) {
  invisible(utils::capture.output(
    pr <- stats::predict(object, newdata = newdata, type = "response", ...)
  ))
  if (isTRUE(logit)) {
    multiclass_logit(cbind(pr, 1 - pr), which.class = which.class)
  } else {
    cbind(pr, 1 - pr)[, which.class]
  }
}


# Package: kernlab -------------------------------------------------------------

# Regression

#' @keywords internal
get_predictions.ksvm <- function(object, newdata, ...) {
  kernlab::predict(object, newdata = newdata, ...)[, 1L, drop = TRUE]
}

# Classification

#' @keywords internal
get_probs.ksvm <- function(object, newdata, which.class, logit, ...) {
  if (is.null(object@kcall$prob.model)) {
    stop(paste("Cannot obtain predicted probabilities from",
               deparse(substitute(object))))
  }
  pr <- kernlab::predict(object, newdata = newdata, type = "probabilities", ...)
  if (isTRUE(logit)) {
    multiclass_logit(pr, which.class = which.class)
  } else {
    pr[, which.class]
  }
}


# Package: MASS ----------------------------------------------------------------

# Classification

#' @keywords internal
get_probs.lda <- function(object, newdata, which.class, logit, ...) {
  pr <- stats::predict(object, newdata = newdata, ...)$posterior
  if (isTRUE(logit)) {
    multiclass_logit(pr, which.class = which.class)
  } else {
    pr[, which.class]
  }
}

#' @keywords internal
get_probs.qda <- function(object, newdata, which.class, logit, ...) {
  pr <- stats::predict(object, newdata = newdata, ...)$posterior
  if (isTRUE(logit)) {
    multiclass_logit(pr, which.class = which.class)
  } else {
    pr[, which.class]
  }
}


# Package: mda -----------------------------------------------------------------

# Regression

#' @keywords internal
get_predictions.mars <- function(object, newdata, ...) {
  stats::predict(object, newdata = data.matrix(newdata), ...)[, 1L, drop = TRUE]
}

# Classification

#' @keywords internal
get_probs.fda <- function(object, newdata, which.class, logit, ...) {
  pr <- stats::predict(object, newdata = newdata, type = "posterior", ...)
  if (isTRUE(logit)) {
    multiclass_logit(pr, which.class = which.class)
  } else {
    pr[, which.class]
  }
}


# Package: nnet ----------------------------------------------------------------

# Classification

#' @keywords internal
get_probs.nnet <- function(object, newdata, which.class, logit, ...) {
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
  if (isTRUE(logit)) {
    if (is.null(ncol(pr)) || ncol(pr) == 1) {
      multiclass_logit(cbind(pr, 1 - pr), which.class = which.class)
    } else {
      multiclass_logit(pr, which.class = which.class)
    }
  } else {
    if (is.null(ncol(pr)) || ncol(pr) == 1) {
      cbind(pr, 1 - pr)[, which.class]
    } else {
      pr[, which.class]
    }
  }
}


# Package: party ---------------------------------------------------------------

# Regression

#' @keywords internal
get_probs.BinaryTree <- function(object, newdata, which.class, logit, ...) {
  pr <- stats::predict(object, newdata = newdata, type = "prob", ...)
  if (isTRUE(logit)) {
    multiclass_logit(do.call(rbind, pr), which.class = which.class)
  } else {
    do.call(rbind, pr)[, which.class]
  }
}

# Classification

#' @keywords internal
get_probs.RandomForest <- function(object, newdata, which.class, logit, ...) {
  pr <- stats::predict(object, newdata = newdata, type = "prob", ...)
  if (isTRUE(logit)) {
    multiclass_logit(do.call(rbind, pr), which.class = which.class)
  } else {
    do.call(rbind, pr)[, which.class]
  }
}


# Package: ranger --------------------------------------------------------------

# Regression

#' @keywords internal
get_predictions.ranger <- function(object, newdata, ...) {
  stats::predict(object, data = newdata, ...)$predictions
}

# Classification

#' @keywords internal
get_probs.ranger <- function(object, newdata, which.class, logit, ...) {
  if (object$treetype != "Probability estimation") {
    stop(paste("Cannot obtain predicted probabilities from",
               deparse(substitute(object))))
  }
  pr <- stats::predict(object, data = newdata, ...)$predictions
  if (isTRUE(logit)) {
    multiclass_logit(pr, which.class = which.class)
  } else {
    pr[, which.class]
  }
}


# Package: stats ---------------------------------------------------------------

# Classification

#' @keywords internal
get_probs.glm <- function(object, newdata, which.class, logit, ...) {
  pr <- stats::predict(object, newdata = newdata, type = "response", ...)
  if (isTRUE(logit)) {
    multiclass_logit(cbind(pr, 1 - pr), which.class = which.class)
  } else {
    cbind(pr, 1 - pr)[, which.class]
  }
}


# Package: xgboost -------------------------------------------------------------

# Regression

#' @keywords internal
get_predictions.xgb.Booster <- function(object, newdata, inv.link, ...) {
  pred <- stats::predict(object, newdata = newdata, ...)
  if (is.null(inv.link)) {
    pred
  } else {
    inv.link(pred)
  }
}

# Classification

#' @keywords internal
get_probs.xgb.Booster <- function(object, newdata, which.class, logit, ...) {
  pr <- stats::predict(object, newdata = newdata, reshape = TRUE, ...)
  if (object$params$objective == "binary:logistic") {
    pr <- cbind(pr, 1 - pr)
  }
  if (isTRUE(logit)) {
    multiclass_logit(pr, which.class = which.class)
  } else {
    pr[, which.class]
  }
}
