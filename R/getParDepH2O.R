#' @keywords internal
getParDepH2O <- function(
  object, pred.var, pred.grid, pred.fun, train, progress, parallel, paropts,
  ...
) {
  plyr::adply(
    pred.grid, .margins = 1, .progress = progress, .parallel = parallel,
    .paropts = paropts, .id = NULL,
    .fun = function(x) {
      temp <- train
      temp[, pred.var] <- x[1L, 1L]
      out <- mean(predict(object, newdata = temp))
      print(out)
      if (length(out) == 1) {
        stats::setNames(out, "yhat")
      } else {
        if (is.null(names(out))) {
          stats::setNames(out, paste0("yhat.", 1L:length(out)))
        } else {
          stats::setNames(out, paste0("yhat.", names(out)))
        }
      }
    }
  )
}
