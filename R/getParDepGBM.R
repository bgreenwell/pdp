#' @keywords internal
#' @useDynLib pdp, .registration = TRUE
getParDepGBM <- function(object, pred.var, pred.grid, which.class, prob, ...) {

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

  # FIXME: What's the best way to do this?

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
