#' @keywords internal
getParDepReg <- function(object, pred.var, pred.grid, inv.link, ice, train,
                         progress, parallel, paropts, in.memory, ...) {

  # Use-supplied inverse link function
  if (!is.null(inv.link)) {

    # Ice curves with user-specified inverse link function
    if (ice) {

      # Get predictions
      plyr::adply(pred.grid, .margins = 1, .progress = progress,
                  .parallel = parallel, .paropts = paropts,
                  .fun = function(x) {
                    temp <- train
                    temp[, pred.var] <- x
                    pred <- getIcePredRegInvLink(object, newdata = temp,
                                                 inv.link = inv.link, ...)
                    if (is.null(names(pred))) {
                      stats::setNames(pred, paste0("yhat.", 1L:length(pred)))
                    } else {
                      stats::setNames(pred, paste0("yhat.", names(pred)))
                    }
                  }, .id = NULL)

    # PDP with user-specified inverse link function
    } else {

      # Get predictions
      plyr::adply(pred.grid, .margins = 1, .progress = progress,
                  .parallel = parallel, .paropts = paropts,
                  .fun = function(x) {
                    temp <- train
                    temp[, pred.var] <- x
                    stats::setNames(
                      getParPredRegInvLink(object, newdata = temp,
                                           inv.link = inv.link, ...), "yhat"
                    )
                  }, .id = NULL)

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
        .fun = function(x) {
          temp <- train
          temp[, pred.var] <- x
          pred <- getIcePredReg(object, newdata = temp, ...)
          if (is.null(names(pred))) {
            stats::setNames(pred, paste0("yhat.", 1L:length(pred)))
          } else {
            stats::setNames(pred, paste0("yhat.", names(pred)))
          }
        },
        .id = NULL
      )

    # DANGER: Work in progress #################################################

    # Default PDP
    } else {

      if (in.memory) {

        # Compute partial dependence all at once
        getParDepRegInMem(object, pred.var, pred.grid, train)

      } else {

        # Get predictions
        plyr::adply(
          .data = pred.grid,
          .margins = 1,
          .progress = progress,
          .parallel = parallel,
          .paropts = paropts,
          .fun = function(x) {
            temp <- train
            temp[, pred.var] <- x
            stats::setNames(getParPredReg(object, newdata = temp, ...), "yhat")
          },
          .id = NULL
        )

      }

    }

    ############################################################################

  }

}
