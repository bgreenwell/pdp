#' @keywords internal
get_task <- function(object) {
  UseMethod("get_task")
}


#' @keywords internal
get_task.default <- function(object) {
  warning('`type` could not be determined; assuming `type = "regression"`')
  "regression"
}


#' @keywords internal
get_task.BinaryTree <- function(object) {
  if (object@responses@is_nominal) {
    "classification"
  } else if (object@responses@is_ordinal || object@responses@is_censored) {
    "other"
  } else {
    "regression"
  }
}


#' @keywords internal
get_task.bagging <- function(object) {
  "classification"
}


#' @keywords internal
get_task.boosting <- function(object) {
  "classification"
}


#' @keywords internal
get_task.C5.0 <- function(object) {
  "classification"
}


get_task.cforest <- function(object) {
  if (is.factor(object$fitted[["(response)"]])) {
    "classification"
  } else if (is.numeric(object$fitted[["(response)"]])) {
    "regression"
  } else {
    "other"
  }
}


#' @keywords internal
get_task.classbagg <- function(object) {
  "classification"
}


#' @keywords internal
get_task.cubist <- function(object) {
  "regression"
}


#' @keywords internal
get_task.earth <- function(object) {
  if (!is.null(object$glm.list) &&
      object$glm.list[[1L]]$family$family == "binomial") {
    "classification"
  } else if (is.null(object$glm.list) ||
             object$glm.list[[1L]]$family$family %in%
             c("gaussian", "Gamma", "inverse.gaussian", "poisson")) {
    "regression"
  } else {
    "other"
  }
}


#' @keywords internal
get_task.fda <- function(object) {
  "classification"
}


#' @keywords internal
get_task.gbm <- function(object) {
  if (object$distribution %in%
      c("coxph", "gaussian", "laplace", "tdist", "gamma", "poisson", "tweedie")) {
    "regression"
  } else if (object$distribution %in%
             c("bernoulli", "huberized", "multinomial", "adaboost")) {
    "classification"
  } else {
    "other"
  }
}


#' @keywords internal
get_task.glm <- function(object) {
  if(object$family$family == "binomial") {
    "classification"
  } else if (object$family$family %in%
             c("gaussian", "Gamma", "inverse.gaussian", "poisson")) {
    "regression"
  } else {
    "other"
  }
}


#' @keywords internal
get_task.ksvm <- function(object) {
  if (grepl("svr$", object@type)) {
    "regression"
  } else if (grepl("svc$", object@type)) {
    "classification"
  } else {
    "other"
  }
}


#' @keywords internal
get_task.lda <- function(object) {
  "classification"
}


#' @keywords internal
get_task.lm <- function(object) {
  # FIXME: What about multivariate response models?
  "regression"
}


#' @keywords internal
get_task.mars <- function(object) {
  if (ncol(object$fitted.values) > 1) {
    stop("`partial` does not currently support multivariate response models.")
  }
  "regression"
}


#' @keywords internal
get_task.multinom <- function(object) {
  # FIXME: What about multivariate response models?
  "classification"
}


#' @keywords internal
get_task.naiveBayes <- function(object) {
  "classification"
}


#' @keywords internal
get_task.nls <- function(object) {
  "regression"
}


#' @keywords internal
get_task.nnet <- function(object) {
  if (is.null(object$lev)) {
    "regression"
  } else {
    "classification"
  }
}


get_task.party <- function(object) {
  if (is.factor(object$fitted[["(response)"]])) {
    "classification"
  } else if (is.numeric(object$fitted[["(response)"]])) {
    "regression"
  } else {
    "other"
  }
}


#' @keywords internal
get_task.ppr <- function(object) {
  if (object$q > 1) {
    stop("`partial` does not currently support multivariate response models.")
  }
  "regression"
}


#' @keywords internal
get_task.qda<- function(object) {
  "classification"
}


#' @keywords internal
get_task.RandomForest <- function(object) {
  if (object@responses@is_nominal) {
    "classification"
  } else if (object@responses@is_ordinal || object@responses@is_censored) {
    "other"
  } else {
    "regression"
  }
}


#' @keywords internal
get_task.randomForest <- function(object) {
  if (object$type == "regression") {
    "regression"
  } else if (object$type == "classification") {
    "classification"
  } else {
    "unsupervised"
  }
}


#' @keywords internal
get_task.ranger <- function(object) {
  if (object$treetype == "Regression") {
    "regression"
  } else if (object$treetype == "Probability estimation") {
    "classification"
  } else if (object$treetype == "Classification") {
    stop("Partial dependence for classification tasks with \"ranger\" objects ",
         "requires a probability forest. Try refitting the model with ",
         "`probability = TRUE`; see `?ranger::ranger` for details.",
         call. = FALSE)
  } else {
    "other"
  }
}


#' @keywords internal
get_task.regbagg <- function(object) {
  "regression"
}


#' @keywords internal
get_task.rpart <- function(object) {
  if (object$method == "anova") {
    "regression"
  } else if (object$method == "class") {
    "classification"
  } else {
    "other"
  }
}


#' @keywords internal
get_task.svm <- function(object) {
  if (object$type %in% c(3, 4)) {
    "regression"
  } else {
    if (is.null(object$call$probability)) {
      stop("Partial dependence for classification tasks with \"svm\" objects ",
           "requires estimating predicted class probabilities. Try refitting ",
           "the model with `probability = TRUE`; see `?e1071::svm` for ",
           "details.", call. = FALSE)
    }
    "classification"
  }
}


#' @keywords internal
get_task.train <- function(object) {
  if (object$modelType == "Classification") {
    "classification"
  } else if (object$modelType == "Regression") {
    "regression"
  } else {
    "other"
  }
}


#' @keywords internal
get_task.xgb.Booster <- function(object) {
  # FIXME: "reg:linear" was changed to "reg:squarederror" in v0.90.0, but the
  # following should suffice without having to check package version.
  if (object$params$objective %in%
      c("reg:gamma", "reg:linear", "reg:logistic", "reg:squarederror",
        "reg:squaredlogerror", "count:poisson")) {
    "regression"
  } else if (object$params$objective %in%
             c("binary:logistic", "multi:softprob")) {
    "classification"
  } else if (object$params$objective %in%
             c("binary:logitraw", "multi:softmax")) {
    stop(paste("For classification, switch to an objective function",
               "that returns the predicted probabilities."))
  } else {
    "other"
  }
}
