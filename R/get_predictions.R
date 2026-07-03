# Prediction wrappers

# Helpers ----------------------------------------------------------------------

# Return either the probability for the "focus" class or the corresponding
# centered logit; every get_probs() method funnels through this
#' @keywords internal
finalize_probs <- function(pr, which.class, logit) {
  if (isTRUE(logit)) {
    multiclass_logit(pr, which.class = which.class)
  } else {
    pr[, which.class]
  }
}


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
  finalize_probs(pr, which.class = which.class, logit = logit)
}


# Package: adabag --------------------------------------------------------------

# Classification

#' @keywords internal
get_probs.bagging <- function(object, newdata, which.class, logit, ...) {
  pr <- stats::predict(object, newdata = newdata, ...)$prob
  finalize_probs(pr, which.class = which.class, logit = logit)
}

#' @keywords internal
get_probs.boosting <- get_probs.bagging


# Package: e1071 ---------------------------------------------------------------

# Classification

#' @keywords internal
get_probs.naiveBayes <- function(object, newdata, which.class, logit, ...) {
  pr <- stats::predict(object, newdata = newdata, type = "raw", ...)
  finalize_probs(pr, which.class = which.class, logit = logit)
}

#' @keywords internal
get_probs.svm <- function(object, newdata, which.class, logit, ...) {
  if (is.null(object$call$probability)) {
    stop(paste("Cannot obtain predicted probabilities from",
               deparse(substitute(object))))
  }
  pr <- attr(stats::predict(object, newdata = newdata, probability = TRUE, ...),
             which = "probabilities")
  finalize_probs(pr, which.class = which.class, logit = logit)
}


# Package: earth ---------------------------------------------------------------

# Classification

#' @keywords internal
get_probs.earth <- function(object, newdata, which.class, logit, ...) {
  pr <- stats::predict(object, newdata = newdata, type = "response", ...)
  finalize_probs(cbind(pr, 1 - pr), which.class = which.class, logit = logit)
}


# Package: gbm -----------------------------------------------------------------

# NOTE: predict.gbm() prints a message about the value of `n.trees` it decided
# to use whenever `n.trees` is not specified, so only capture (and discard) the
# output in that case

# Regression

#' @keywords internal
get_predictions.gbm <- function(object, newdata, inv.link, ...) {
  pred <- if ("n.trees" %in% names(list(...))) {
    stats::predict(object, newdata = newdata, ...)
  } else {
    invisible(utils::capture.output(
      res <- stats::predict(object, newdata = newdata, ...)
    ))
    res
  }
  if (is.null(inv.link)) {
    pred
  } else {
    inv.link(pred)
  }
}

# Classification

#' @keywords internal
get_probs.gbm <- function(object, newdata, which.class, logit, ...) {
  pr <- if ("n.trees" %in% names(list(...))) {
    stats::predict(object, newdata = newdata, type = "response", ...)
  } else {
    invisible(utils::capture.output(
      res <- stats::predict(object, newdata = newdata, type = "response", ...)
    ))
    res
  }
  finalize_probs(cbind(pr, 1 - pr), which.class = which.class, logit = logit)
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
  finalize_probs(pr, which.class = which.class, logit = logit)
}


# Package: MASS ----------------------------------------------------------------

# Classification

#' @keywords internal
get_probs.lda <- function(object, newdata, which.class, logit, ...) {
  pr <- stats::predict(object, newdata = newdata, ...)$posterior
  finalize_probs(pr, which.class = which.class, logit = logit)
}

#' @keywords internal
get_probs.qda <- get_probs.lda


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
  finalize_probs(pr, which.class = which.class, logit = logit)
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
  if (is.null(ncol(pr)) || ncol(pr) == 1) {
    pr <- cbind(pr, 1 - pr)
  }
  finalize_probs(pr, which.class = which.class, logit = logit)
}


# Package: party ---------------------------------------------------------------

# Classification

#' @keywords internal
get_probs.BinaryTree <- function(object, newdata, which.class, logit, ...) {
  pr <- stats::predict(object, newdata = newdata, type = "prob", ...)
  finalize_probs(do.call(rbind, pr), which.class = which.class, logit = logit)
}

#' @keywords internal
get_probs.RandomForest <- get_probs.BinaryTree


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
  finalize_probs(pr, which.class = which.class, logit = logit)
}


# Package: stats ---------------------------------------------------------------

# Classification

#' @keywords internal
get_probs.glm <- function(object, newdata, which.class, logit, ...) {
  pr <- stats::predict(object, newdata = newdata, type = "response", ...)
  finalize_probs(cbind(pr, 1 - pr), which.class = which.class, logit = logit)
}


# Package: xgboost -------------------------------------------------------------

# Regression

#' @keywords internal
get_predictions.xgboost <- function(object, newdata, inv.link, ...) {
  pred <- stats::predict(object, newdata = newdata, ...)
  if (is.null(inv.link)) {
    pred
  } else {
    inv.link(pred)
  }
}

# Classification

#' @keywords internal
get_probs.xgboost <- function(object, newdata, which.class, logit, ...) {
  pr <- stats::predict(object, newdata = newdata, type = "response", ...)
  obj <- attr(object, "params")$objective
  if (obj == "binary:logistic") {
    pr <- cbind(pr, 1 - pr)
  }
  finalize_probs(pr, which.class = which.class, logit = logit)
}
