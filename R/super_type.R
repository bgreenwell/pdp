#' @keywords internal
super_type <- function(object) {
  UseMethod("super_type")
}


#' @keywords internal
super_type.default <- function(object) {
  warning('`type` could not be determined; assuming `type = "regression"`')
  "regression"
}


#' @keywords internal
super_type.BinaryTree <- function(object) {
  if (object@responses@is_nominal) {
    "classification"
  } else if (object@responses@is_ordinal || object@responses@is_censored) {
    "other"
  } else {
    "regression"
  }
}


#' @keywords internal
super_type.bagging <- function(object) {
  "classification"
}


#' @keywords internal
super_type.boosting <- function(object) {
  "classification"
}


#' @keywords internal
super_type.C5.0 <- function(object) {
  "classification"
}


super_type.cforest <- function(object) {
  if (is.factor(object$fitted[["(response)"]])) {
    "classification"
  } else if (is.numeric(object$fitted[["(response)"]])) {
    "regression"
  } else {
    "other"
  }
}


#' @keywords internal
super_type.classbagg <- function(object) {
  "classification"
}


#' @keywords internal
super_type.cubist <- function(object) {
  "regression"
}


#' @keywords internal
super_type.earth <- function(object) {
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
super_type.fda<- function(object) {
  "classification"
}


#' @keywords internal
super_type.gbm <- function(object) {
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
super_type.glm <- function(object) {
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
super_type.ksvm <- function(object) {
  if (grepl("svr$", object@type)) {
    "regression"
  } else if (grepl("svc$", object@type)) {
    "classification"
  } else {
    "other"
  }
}


#' @keywords internal
super_type.lda <- function(object) {
  "classification"
}


#' @keywords internal
super_type.lm <- function(object) {
  # FIXME: What about multivariate response models?
  "regression"
}


#' @keywords internal
super_type.mars <- function(object) {
  if (ncol(object$fitted.values) > 1) {
    stop("`partial` does not currently support multivariate response models.")
  }
  "regression"
}


#' @keywords internal
super_type.multinom <- function(object) {
  # FIXME: What about multivariate response models?
  "classification"
}


#' @keywords internal
super_type.naiveBayes <- function(object) {
  "classification"
}


#' @keywords internal
super_type.nls <- function(object) {
  "regression"
}


#' @keywords internal
super_type.nnet <- function(object) {
  if (is.null(object$lev)) {
    "regression"
  } else {
    "classification"
  }
}


super_type.party <- function(object) {
  if (is.factor(object$fitted[["(response)"]])) {
    "classification"
  } else if (is.numeric(object$fitted[["(response)"]])) {
    "regression"
  } else {
    "other"
  }
}


#' @keywords internal
super_type.ppr <- function(object) {
  if (object$q > 1) {
    stop("`partial` does not currently support multivariate response models.")
  }
  "regression"
}


#' @keywords internal
super_type.qda<- function(object) {
  "classification"
}


#' @keywords internal
super_type.RandomForest <- function(object) {
  if (object@responses@is_nominal) {
    "classification"
  } else if (object@responses@is_ordinal || object@responses@is_censored) {
    "other"
  } else {
    "regression"
  }
}


#' @keywords internal
super_type.randomForest <- function(object) {
  if (object$type == "regression") {
    "regression"
  } else if (object$type == "classification") {
    "classification"
  } else {
    "unsupervised"
  }
}


#' @keywords internal
super_type.ranger <- function(object) {
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
super_type.regbagg <- function(object) {
  "regression"
}


#' @keywords internal
super_type.rpart <- function(object) {
  if (object$method == "anova") {
    "regression"
  } else if (object$method == "class") {
    "classification"
  } else {
    "other"
  }
}


#' @keywords internal
super_type.svm <- function(object) {
  if (object$type %in% c(3, 4)) {
    "regression"
  } else {
    "classification"
  }
}


#' @keywords internal
super_type.train <- function(object) {
  if (object$modelType == "Classification") {
    "classification"
  } else if (object$modelType == "Regression") {
    "regression"
  } else {
    "other"
  }
}


#' @keywords internal
super_type.xgb.Booster <- function(object) {
  if (object$params$objective %in%
      c("reg:linear", "reg:logistic", "count:poisson", "reg:gamma")) {
    "regression"
  } else if (object$params$objective %in%
             c("binary:logistic", "multi:softprob")) {
    # FIXME: Throw a warning if objective function is classification, but does
    # not return the predicted probabilities (e.g., "binary:logitraw").
    "classification"
  } else if (object$params$objective %in%
             c("binary:logitraw", "multi:softmax")) {
    stop(paste("For classification, switch to an objective function",
               "that returns the predicted probabilities."))
  } else {
    "other"
  }
}
