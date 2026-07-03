# Apply `f()` to each element of `ind` and concatenate the results; uses
# foreach (and whatever parallel backend the user registered) whenever
# `parallel = TRUE`, so foreach only needs to be installed in that case
#' @keywords internal
par_loop <- function(ind, f, parallel, paropts) {
  if (isTRUE(parallel)) {
    if (!requireNamespace("foreach", quietly = TRUE)) {
      stop("Package \"foreach\" (and a registered parallel backend) is ",
           "required whenever `parallel = TRUE`. Please install it.",
           call. = FALSE)
    }
    `%dopar%` <- foreach::`%dopar%`
    i <- NULL  # to avoid R CMD check note about the foreach iterator
    foreach::foreach(i = ind, .combine = "c", .packages = paropts$.packages,
                     .export = paropts$export) %dopar% f(i)
  } else {
    unlist(lapply(ind, f))
  }
}


#' @keywords internal
pardep <- function(object, pred.var, pred.grid, pred.fun, inv.link, ice, task,
                   which.class, logit, train, progress, parallel, paropts,
                   batch.size = NULL, ...) {

  # Disable progress bar for parallel execution
  if (isTRUE(progress) && isTRUE(parallel)) {
    progress <- FALSE
    warning("progress bars are disabled whenever `parallel = TRUE`.",
            call. = FALSE, immediate. = TRUE)
  }

  # Wrap the appropriate prediction function; each returns one prediction per
  # row of `newdata`
  predfun <- if (!is.null(pred.fun)) {
    function(newdata) pred.fun(object, newdata = newdata)
  } else if (task == "regression") {
    function(newdata) {
      get_predictions(object, newdata = newdata, inv.link = inv.link, ...)
    }
  } else {
    function(newdata) {
      get_probs(object, newdata = newdata, which.class = which.class,
                logit = logit, ...)
    }
  }

  # Average the predictions for each grid point? (User-supplied prediction
  # wrappers handle their own aggregation)
  aggregate <- is.null(pred.fun) && isFALSE(ice)

  k <- nrow(pred.grid)
  n <- nrow(train)

  # Compute feature effects
  yhat <- if (is.null(batch.size)) {

    # Classic approach: one call to predict() per grid point
    if (isTRUE(progress)) {
      pb <- utils::txtProgressBar(min = 0, max = k, style = 3)
    }
    par_loop(seq_len(k), parallel = parallel, paropts = paropts, f = function(i) {
      temp <- train
      temp[, pred.var] <- pred.grid[i, pred.var]
      preds <- predfun(temp)
      if (aggregate) {
        preds <- mean(preds, na.rm = TRUE)
      }
      if (isTRUE(progress)) {
        utils::setTxtProgressBar(pb, value = i)
      }
      preds
    })

  } else {

    # Batched approach: stack copies of `train` (one per grid point) so that
    # each call to predict() scores at most (roughly) `batch.size` rows; this
    # is typically much faster since it avoids the per-call overhead of most
    # predict() methods
    rows.per.chunk <- max(1, min(k, floor(batch.size / n)))
    chunks <- split(seq_len(k), ceiling(seq_len(k) / rows.per.chunk))
    if (isTRUE(progress)) {
      pb <- utils::txtProgressBar(min = 0, max = length(chunks), style = 3)
    }
    par_loop(seq_along(chunks), parallel = parallel, paropts = paropts,
             f = function(i) {
      ids <- chunks[[i]]
      temp <- train[rep(seq_len(n), times = length(ids)), , drop = FALSE]
      temp[, pred.var] <- pred.grid[rep(ids, each = n), pred.var]
      preds <- predfun(temp)
      if (length(preds) != nrow(temp)) {
        stop("`batch.size` requires a prediction function that returns one ",
             "prediction per row of `newdata`. Received ", length(preds),
             " prediction(s) for ", nrow(temp), " row(s). If `pred.fun` ",
             "aggregates its predictions (e.g., averages them), use the ",
             "default `batch.size = NULL` instead.", call. = FALSE)
      }
      # Drop prediction names; row names of the stacked data are meaningless
      # (e.g., "1.1", "1.2", ...), so `yhat.id` falls back to integer IDs
      preds <- unname(preds)
      if (aggregate) {
        preds <- as.numeric(tapply(
          preds, INDEX = rep(seq_along(ids), each = n), FUN = mean,
          na.rm = TRUE
        ))
      }
      if (isTRUE(progress)) {
        utils::setTxtProgressBar(pb, value = i)
      }
      preds
    })

  }

  # Assemble results: a single (averaged) curve or one curve per observation
  len <- length(yhat) / k  # predictions per grid point
  res <- if (len == 1) {  # no need for `yhat.id` (e.g., averaged predictions)
    cbind(pred.grid, "yhat" = as.numeric(yhat))
  } else {  # multiple predictions per grid point (e.g., ICE curves)
    grid.id <- rep(seq_len(k), each = len)
    yhat.id <- if (!is.null(pred.fun) && !is.null(names(yhat))) {
      names(yhat)  # keep prediction names when available
    } else {
      rep(seq_len(len), times = k)
    }
    out <- data.frame(pred.grid[grid.id, ], "yhat" = as.numeric(yhat),
                      "yhat.id" = yhat.id)
    colnames(out) <- c(colnames(pred.grid), "yhat", "yhat.id")
    out
  }

  # Close progress bar
  if (isTRUE(progress)) {
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
    if (inherits(pred.grid[[i]], "factor")) {

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
