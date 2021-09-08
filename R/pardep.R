i <- NULL

#' @keywords internal
#'
#' @importFrom foreach foreach %do% %dopar%
pardep <- function(object, pred.var, pred.grid, pred.fun, inv.link, ice, task,
                   which.class, logit, train, progress, parallel, paropts, ...) {

  # Disable progress bar for parallel execution
  if (progress != "none" && isTRUE(parallel)) {
    progress <- "none"
    warning("progress bars are disabled whenever `parallel = TRUE`.",
            call. = FALSE, immediate. = TRUE)
  }

  # Define "pardo" operator
  `%pardo%` <- if (isTRUE(parallel)) {
    `%dopar%`
  } else {
    `%do%`
  }

  # Compute feature effects
  if (is.null(pred.fun)) {

    # Partial dependence: regression case
    if (task == "regression" && isFALSE(ice)) {
      if (progress != "none") {
        pb <- utils::txtProgressBar(min = 0, max = nrow(pred.grid), style = 3)
      }
      yhat <- foreach(i = seq_len(nrow(pred.grid)), .combine = "c",
                      .packages = paropts$.packages, .export = paropts$export) %pardo% {
        temp <- train
        temp[, pred.var] <- pred.grid[i, pred.var]
        preds <- mean(get_predictions(object, newdata = temp,
                                      inv.link = inv.link, ...), na.rm = TRUE)
        if (progress != "none") {
          utils::setTxtProgressBar(pb, value = i)
        }
        preds
      }
      res <- cbind(pred.grid, "yhat" = yhat)
    }

    # Partial dependence: classification case
    if (task == "classification" && isFALSE(ice)) {
      if (progress != "none") {
        pb <- utils::txtProgressBar(min = 0, max = nrow(pred.grid), style = 3)
      }
      yhat <- foreach(i = seq_len(nrow(pred.grid)), .combine = "c",
                      .packages = paropts$.packages, .export = paropts$export) %pardo% {
        temp <- train
        temp[, pred.var] <- pred.grid[i, pred.var]
        preds <- mean(get_probs(object, newdata = temp,
                                which.class = which.class, logit = logit, ...),
                      na.rm = TRUE)
        if (progress != "none") {
          utils::setTxtProgressBar(pb, value = i)
        }
       preds
      }
      res <- cbind(pred.grid, "yhat" = yhat)
    }

    # ICE curves: regression case
    if (task == "regression" && isTRUE(ice)) {
      if (progress != "none") {
        pb <- utils::txtProgressBar(min = 0, max = nrow(pred.grid), style = 3)
      }
      yhat <- foreach(i = seq_len(nrow(pred.grid)), .combine = "c",
                      .packages = paropts$.packages, .export = paropts$export) %pardo% {
        temp <- train
        temp[, pred.var] <- pred.grid[i, pred.var]
        preds <- get_predictions(object, newdata = temp, inv.link = inv.link, ...)
        if (progress != "none") {
          utils::setTxtProgressBar(pb, value = i)
        }
        preds
      }
      grid.id <- rep(seq_len(nrow(pred.grid)), each = nrow(train))
      yhat.id <- rep(seq_len(nrow(train)), times = nrow(pred.grid))
      res <- data.frame(pred.grid[grid.id, ], "yhat" = yhat, "yhat.id" = yhat.id)
      names(res) <- c(names(pred.grid), "yhat", "yhat.id")
    }

    # ICE curves: classification case
    if (task == "classification" && isTRUE(ice)) {
      if (progress != "none") {
        pb <- utils::txtProgressBar(min = 0, max = nrow(pred.grid), style = 3)
      }
      yhat <- foreach(i = seq_len(nrow(pred.grid)), .combine = "c",
                      .packages = paropts$.packages, .export = paropts$export) %pardo% {
        temp <- train
        temp[, pred.var] <- pred.grid[i, pred.var]
        preds <- get_probs(object, newdata = temp, which.class = which.class,
                           logit = logit, ...)
        if (progress != "none") {
          utils::setTxtProgressBar(pb, value = i)
        }
        preds
      }
      if (progress != "none") {
        utils::setTxtProgressBar(pb, value = i)
      }
      grid.id <- rep(seq_len(nrow(pred.grid)), each = nrow(train))
      yhat.id <- rep(seq_len(nrow(train)), times = nrow(pred.grid))
      res <- data.frame(pred.grid[grid.id, ], "yhat" = yhat, "yhat.id" = yhat.id)
      names(res) <- c(names(pred.grid), "yhat", "yhat.id")
    }

  } else {

    # Partial dependence/ICE curves: user-supplied prediction wrapper
    if (progress != "none") {
      pb <- utils::txtProgressBar(min = 0, max = nrow(pred.grid), style = 3)
    }
    yhat <- foreach(i = seq_len(nrow(pred.grid)), .combine = "c",
                    .packages = paropts$.packages, .export = paropts$export) %pardo% {
      temp <- train
      temp[, pred.var] <- pred.grid[i, pred.var]
      preds <- pred.fun(object, newdata = temp)
      if (progress != "none") {
        utils::setTxtProgressBar(pb, value = i)
      }
      preds
    }
    len <- length(yhat) / nrow(pred.grid)  # FIXME: Is there a more robust way?
    if (len == 1L) {  # no need for `yhat.id` when `pred.fun()` returns a singleton
      res <- cbind(pred.grid, "yhat" = yhat)
    } else {  # multiple predictions per call to `pred.fun()`
      grid.id <- rep(seq_len(nrow(pred.grid)), each = len)
      yhat.id <- if (is.null(names(yhat))) {
        rep(seq_len(len), times = nrow(pred.grid))
      } else {
        names(yhat)
      }
      res <- data.frame(pred.grid[grid.id, ], "yhat" = yhat, "yhat.id" = yhat.id)
      names(res) <- c(names(pred.grid), "yhat", "yhat.id")
    }

  }

  # Close progress bar
  if (progress != "none") {
    close(pb)
  }

  # Return results
  return(res)

}


#' @keywords internal
#' @useDynLib pdp, .registration = TRUE
pardep_gbm <- function(object, pred.var, pred.grid, which.class, prob, ...) {

  # Extract number of trees
  dots <- list(...)
  if ("n.trees" %in% names(dots)) {
    n.trees <- dots$n.trees
    if (!is.numeric(n.trees) || length(n.trees) != 1) {
      stop("\"n.trees\" must be a single integer")
    }
  } else {
    stop("argument \"n.trees\" is missing, with no default")
  }

  # Extract number of response classes for gbm_plot
  if (is.null(object$num.classes)) {
    object$num.classes <- 1
  }

  ##############################################################################

  # FIXME: What's the best way to do this?

  # Convert categorical variables to integer (i.e., 0, 1, 2, ..., K)
  for (i in seq_len(length(pred.grid))) {

    # For `"gbm"` objects, possibilities are "numeric", "ordered", or "factor".
    # But ordered factors actually inherit from class `"factor"`, so only need
    # to check for that here.
    if (inherits(pred.grid, "factor")) {

      # Save original factor values (could possibly be "ordered")
      levs <- levels(pred.grid[[i]])
      vals <- as.character(pred.grid[[i]])
      type <- class(pred.grid[[i]])

      # Convert from categorical to integer (i.e., 0, 1, ..., K). For example,
      # c("low", "hot", "med"), w/ low < med < hot, should be converted to
      # c(0, 2, 1).
      pred.grid[[i]] <- as.numeric(pred.grid[[i]]) - 1

      # Store original categorical values, class information, etc.
      attr(pred.grid[[i]], which = "cat") <- TRUE  # categorical indicator
      attr(pred.grid[[i]], which = "levs") <- levs  # factor levels
      attr(pred.grid[[i]], which = "vals") <- vals  # factor values
      attr(pred.grid[[i]], which = "original_class") <- type  # factor type

    }

  }

  ##############################################################################

  # Partial dependence values
  y <- .Call("PartialGBM",
             X = as.double(data.matrix(pred.grid)),
             cRows = as.integer(nrow(pred.grid)),
             cCols = as.integer(ncol(pred.grid)),
             n.class = as.integer(object$num.classes),
             pred.var = as.integer(match(pred.var, object$var.names) - 1),
             n.trees = as.integer(n.trees),
             initF = as.double(object$initF),
             trees = object$trees,
             c.splits = object$c.splits,
             var.type = as.integer(object$var.type),
             PACKAGE = "pdp")

  # Data frame of predictor values (pd values will be added to this)
  pd.df <- pred.grid

  # Transform/rescale predicted values
  if (object$distribution$name == "multinomial") {
    y <- matrix(y, ncol = object$num.classes)
    colnames(y) <- object$classes
    y <- exp(y)
    y <- y / matrix(rowSums(y), ncol = ncol(y), nrow = nrow(y))
    if (prob) {  # use class probabilities
      pd.df$yhat <- y[, which.class]
    } else {  # use centered logit
      pd.df$yhat <- multiclass_logit(y, which.class = which.class)
    }
  } else if (object$distribution$name %in% c("bernoulli", "pairwise")) {
    pr <- stats::plogis(y)
    pr <- cbind(pr, 1 - pr)
    if (prob) {
      pd.df$yhat <- pr[, which.class]
    } else {
      eps <- .Machine$double.eps
      pd.df$yhat <- log(ifelse(pr[, which.class] > 0, pr[, which.class], eps)) -
        rowMeans(log(ifelse(pr > 0, pr, eps)))
    }
  } else {
    pd.df$yhat <- y
  }

  ##############################################################################

  # FIXME: Is there a better way to do this?

  # Transform categorical variables back to factors
  for (i in seq_len(length(pred.var))) {
    if (isTRUE(attr(pd.df[[i]], which = "cat"))) {
      if ("ordered" %in% attr(pd.df[[i]], which = "original_class")) {
        pd.df[[i]] <- ordered(  # ordered factor
          x = attr(pd.df[[i]], which = "vals"),
          levels = attr(pd.df[[i]], which = "levs")
        )
      } else {
        pd.df[[i]] <- factor(  # plain vanilla factor
          x = attr(pd.df[[i]], which = "vals"),
          levels = attr(pd.df[[i]], which = "levs")
        )
      }
    }
  }

  ##############################################################################

  # Return data frame of predictor and partial dependence values
  pd.df

}
