#' @keywords internal
superType <- function(object) {
  UseMethod("superType")
}


#' @keywords internal
superType.default <- function(object) {
  warning('`type` could not be determined; assuming `type = "regression"`')
  "regression"
}


#' @keywords internal
superType.BinaryTree <- function(object) {
  if (object@responses@is_nominal) {
    "classification"
  } else if (object@responses@is_ordinal || object@responses@is_censored) {
    "other"
  } else {
    "regression"
  }
}


#' @keywords internal
superType.bagging <- function(object) {
  "classification"
}


#' @keywords internal
superType.boosting <- function(object) {
  "classification"
}


#' @keywords internal
superType.C5.0 <- function(object) {
  "classification"
}


superType.cforest <- function(object) {
  if (attr(object$terms, "response") == 1 &&
      attr(object$terms, "dataClasses")[1L] == "numeric") {
    "regression"
  } else if (attr(object$terms, "response") == 1 &&
             attr(object$terms, "dataClasses")[1L] == "factor") {
    "classification"
  } else {
    "other"
  }
}


#' @keywords internal
superType.classbagg <- function(object) {
  "classification"
}


#' @keywords internal
superType.cubist <- function(object) {
  "regression"
}


#' @keywords internal
superType.earth <- function(object) {
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
superType.fda<- function(object) {
  "classification"
}


#' @keywords internal
superType.gbm <- function(object) {
  if (object$distribution %in%
      c("gaussian", "laplace", "tdist", "gamma", "poisson", "tweedie")) {
    "regression"
  } else if (object$distribution %in%
             c("bernoulli", "huberized", "multinomial", "adaboost")) {
    "classification"
  } else {
    "other"
  }
}


#' @keywords internal
superType.glm <- function(object) {
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
superType.ksvm <- function(object) {
  if (grepl("svr$", object@type)) {
    "regression"
  } else if (grepl("svc$", object@type)) {
    "classification"
  } else {
    "other"
  }
}


#' @keywords internal
superType.lda<- function(object) {
  "classification"
}


#' @keywords internal
superType.lm <- function(object) {
  # FIXME: What about multivariate response models?
  "regression"
}


#' @keywords internal
superType.mars <- function(object) {
  if (ncol(object$fitted.values) > 1) {
    stop("`partial` does not currently support multivariate response models.")
  }
  "regression"
}


#' @keywords internal
superType.multinom <- function(object) {
  # FIXME: What about multivariate response models?
  "classification"
}


#' @keywords internal
superType.naiveBayes <- function(object) {
  "classification"
}


#' @keywords internal
superType.nls <- function(object) {
  "regression"
}


#' @keywords internal
superType.nnet <- function(object) {
  if (is.null(object$lev)) {
    "regression"
  } else {
    "classification"
  }
}


superType.party <- function(object) {
  if (attr(object$terms, "response") == 1 &&
      attr(object$terms, "dataClasses")[1L] == "numeric") {
    "regression"
  } else if (attr(object$terms, "response") == 1 &&
             attr(object$terms, "dataClasses")[1L] == "factor") {
    "classification"
  } else {
    "other"
  }
}


#' @keywords internal
superType.ppr <- function(object) {
  if (object$q > 1) {
    stop("`partial` does not currently support multivariate response models.")
  }
  "regression"
}


#' @keywords internal
superType.qda<- function(object) {
  "classification"
}


#' @keywords internal
superType.RandomForest <- function(object) {
  if (object@responses@is_nominal) {
    "classification"
  } else if (object@responses@is_ordinal || object@responses@is_censored) {
    "other"
  } else {
    "regression"
  }
}


#' @keywords internal
superType.randomForest <- function(object) {
  if (object$type == "regression") {
    "regression"
  } else if (object$type == "classification") {
    "classification"
  } else {
    "unsupervised"
  }
}


#' @keywords internal
superType.ranger <- function(object) {
  if (object$treetype == "Regression") {
    "regression"
  } else if (object$treetype %in%
             c("Classification", "Probability estimation")) {
    "classification"
  } else {
    "other"
  }
}


#' @keywords internal
superType.regbagg <- function(object) {
  "regression"
}


#' @keywords internal
superType.rpart <- function(object) {
  if (object$method == "anova") {
    "regression"
  } else if (object$method == "class") {
    "classification"
  } else {
    "other"
  }
}


#' @keywords internal
superType.svm <- function(object) {
  if (object$type %in% c(3, 4)) {
    "regression"
  } else {
    "classification"
  }
}


#' @keywords internal
superType.train <- function(object) {
  if (object$modelType == "Classification") {
    "classification"
  } else if (object$modelType == "Regression") {
    "regression"
  } else {
    "other"
  }
}


#' @keywords internal
superType.xgb.Booster <- function(object) {
  if (object$params$objective %in%
      c("reg:linear", "count:poisson", "reg:gamma")) {
    "regression"
  } else if (object$params$objective %in%
             c("binary:logistic", "multi:softprob")) {
    # FIXME: Throw a warning if objective function is classification, but does
    # not return the predicted probabilities (e.g., "binary:logitraw").
    "classification"
  } else if (object$params$objective %in%
             c("reg:logistic", "binary:logitraw", "multi:softmax")) {
    stop(paste("For classification, switch to an objective function",
               "that returns the predicted probabilities."))
  } else {
    "other"
  }
}
