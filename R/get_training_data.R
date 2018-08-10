# Error message to display when training data cannot be extracted form object
mssg <- paste0(
  "The training data could not be extracted from object. Please supply the ",
  "raw training data using the `train` argument in the call to `partial`."
)


#' @keywords internal
get_training_data <- function(object) {
  UseMethod("get_training_data")
}


#' @keywords internal
get_training_data.default <- function(object) {
  if (isS4(object)) {
    stop(mssg)
  } else {
    train <- eval(stats::getCall(object)$data)
    if (is.null(train)) {
      stop(mssg)
    } else {
      if (!(is.data.frame(train))) {
        if (is.matrix(train) || is.list(train)) {
          train <- as.data.frame(train)
        } else {
          stop(mssg)
        }
      }
    }
  }
  train
}


#' @keywords internal
get_training_data.BinaryTree <- function(object) {
  object@data@get("input")
}


#' @keywords internal
get_training_data.cforest <- function(object) {
  stop(mssg)
}


#' @keywords internal
get_training_data.ctree <- function(object) {
  stop(mssg)
}


#' @keywords internal
get_training_data.RandomForest <- function(object) {
  object@data@get("input")
}


#' @keywords internal
get_training_data.train <- function(object) {
  # By default, "train" object have a copy of the training data stored in
  # a components called "trainingData"
  train <- object$trainingData
  if (is.null(train)) {
    stop(mssg)
  }
  train$.outcome <- NULL  # remove .outcome column
  train
}
