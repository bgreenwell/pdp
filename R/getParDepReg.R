#' @keywords internal
getParDepReg <- function(object, pred.var, pred.grid, inv.link, ice, train,
                         progress, parallel, paropts, ...) {

  # User-supplied inverse link function
  if (!is.null(inv.link)) {

    # ICE curves with user-specified inverse link function
    if (ice) {

      # Get predictions
      plyr::adply(
        .data = pred.grid,
        .margins = 1,
        .progress = progress,
        .parallel = parallel,
        .paropts = paropts,
        .id = NULL,
        .fun = function(x) {
          temp <- train
          temp[, pred.var] <- x
          pred <- getIcePredRegInvLink(
            object = object, newdata = temp, inv.link = inv.link, ...
          )
          if (is.null(names(pred))) {
            stats::setNames(pred, paste0("yhat.", 1L:length(pred)))
          } else {
            stats::setNames(pred, paste0("yhat.", names(pred)))
          }
        })

    # PDP with user-specified inverse link function
    } else {

      # Get predictions
      plyr::adply(
        .data = pred.grid,
        .margins = 1,
        .progress = progress,
        .parallel = parallel,
        .paropts = paropts,
        .id = NULL,
        .fun = function(x) {
          temp <- train
          temp[, pred.var] <- x
          stats::setNames(
          getParPredRegInvLink(
            object = object, newdata = temp, inv.link = inv.link, ...), "yhat"
          )
        })

    }

  # Default
  } else {

    # Default Ice curves
    if (ice) {

      # Get predictions
      plyr::adply(
        .data = pred.grid,
        .margins = 1,
        .progress = progress,
        .parallel = parallel,
        .paropts = paropts,
        .id = NULL,
        .fun = function(x) {
          temp <- train
          temp[, pred.var] <- x
          pred <- getIcePredReg(object, newdata = temp, ...)
          if (is.null(names(pred))) {
            stats::setNames(pred, paste0("yhat.", 1L:length(pred)))
          } else {
            stats::setNames(pred, paste0("yhat.", names(pred)))
          }
        }
      )

    # Default PDP
    } else {

      # Get predictions
      plyr::adply(
        .data = pred.grid,
        .margins = 1,
        .progress = progress,
        .parallel = parallel,
        .paropts = paropts,
        .id = NULL,
        .fun = function(x) {
          temp <- train
          temp[, pred.var] <- x
          stats::setNames(getParPredReg(object, newdata = temp, ...), "yhat")
        }
      )

    }

  }

}
