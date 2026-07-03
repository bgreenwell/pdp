#' Plotting Partial Dependence Functions
#'
#' Plot partial dependence functions (i.e., marginal effects) and individual
#' conditional expectation (ICE) curves using lightweight base R graphics via
#' the \href{https://grantmcdermott.com/tinyplot/}{tinyplot} package.
#'
#' @param x An object that inherits from class \code{"partial"}, \code{"ice"},
#' or \code{"cice"}; typically the result of a call to \code{\link{partial}}.
#'
#' @param center Logical indicating whether or not to produce centered ICE
#' curves (c-ICE curves). Only useful when \code{x} represents a set of ICE
#' curves; see \code{\link[pdp]{partial}} for details. Default is \code{FALSE}.
#'
#' @param plot.pdp Logical indicating whether or not to plot the partial
#' dependence function on top of the ICE curves. Default is \code{TRUE}.
#'
#' @param pdp.col Character string specifying the color to use for the partial
#' dependence function when \code{plot.pdp = TRUE}. Default is \code{"red2"}.
#'
#' @param pdp.lwd Integer specifying the line width to use for the partial
#' dependence function when \code{plot.pdp = TRUE}. Default is \code{2}. See
#' \code{\link[graphics]{par}} for more details.
#'
#' @param pdp.lty Integer or character string specifying the line type to use
#' for the partial dependence function when \code{plot.pdp = TRUE}. Default is
#' \code{1}. See \code{\link[graphics]{par}} for more details.
#'
#' @param smooth Logical indicating whether or not to overlay a LOESS smooth.
#' Default is \code{FALSE}.
#'
#' @param rug Logical indicating whether or not to include rug marks (i.e.,
#' the min/max and deciles of the predictor distribution) on the predictor
#' axes. Not currently supported for faceted displays (i.e., partial dependence
#' of two predictors where at least one is a factor). Default is \code{FALSE}.
#'
#' @param contour Logical indicating whether or not to add contour lines to the
#' false color level plot used for two continuous predictors. Default is
#' \code{FALSE}.
#'
#' @param contour.color Character string specifying the color to use for the
#' contour lines when \code{contour = TRUE}. Default is \code{"white"}.
#'
#' @param train Data frame containing the original training data. Only required
#' if \code{rug = TRUE}.
#'
#' @param alpha Numeric value in \code{[0, 1]} specifying the opacity alpha;
#' most useful when plotting ICE/c-ICE curves. Default is \code{1} (i.e., no
#' transparency).
#'
#' @param color.by Optional character string specifying the name of a column in
#' \code{train} used to color the individual ICE/c-ICE curves; continuous
#' variables are binned into (at most) five groups. Requires \code{train} and
#' assumes the curve IDs (i.e., the \code{yhat.id} column) correspond to the
#' rows of \code{train} (which is the case whenever \code{ice = TRUE}).
#' Default is \code{NULL}.
#'
#' @param bars Logical indicating whether or not to use a bar plot (rather than
#' points) whenever the predictor of interest is a factor. Default is
#' \code{FALSE}.
#'
#' @param legend.title Character string specifying the text for the legend
#' title of the false color level plot used for two continuous predictors.
#' Default is \code{"yhat"}.
#'
#' @param ... Additional optional arguments to be passed on to
#' \code{\link[tinyplot]{tinyplot}} (e.g., \code{palette}, \code{main}, or
#' \code{theme}).
#'
#' @return Draws a plot as a side effect and (invisibly) returns \code{x}.
#'
#' @rdname plot.partial
#'
#' @export
#'
#' @examples
#' \dontrun{
#' #
#' # Regression example (requires randomForest package to run)
#' #
#'
#' # Fit a random forest to the Boston housing data
#' library(randomForest)
#' data (boston)  # load the boston housing data
#' set.seed(101)  # for reproducibility
#' boston.rf <- randomForest(cmedv ~ ., data = boston)
#'
#' # Partial dependence of cmedv on lstat
#' pd <- partial(boston.rf, pred.var = "lstat")
#' plot(pd, rug = TRUE, train = boston)
#'
#' # Partial dependence of cmedv on lstat and rm
#' pd2 <- partial(boston.rf, pred.var = c("lstat", "rm"), chull = TRUE)
#' plot(pd2, contour = TRUE)
#'
#' # ICE and c-ICE curves
#' rm.ice <- partial(boston.rf, pred.var = "rm", ice = TRUE)
#' plot(rm.ice, rug = TRUE, train = boston, alpha = 0.2)
#' plot(rm.ice, center = TRUE, alpha = 0.2)
#' }
plot.partial <- function(x, center = FALSE, plot.pdp = TRUE, pdp.col = "red2",
                         pdp.lwd = 2, pdp.lty = 1, smooth = FALSE, rug = FALSE,
                         contour = FALSE, contour.color = "white", train = NULL,
                         alpha = 1, color.by = NULL, bars = FALSE,
                         legend.title = "yhat", ...) {

  # Determine if object contains multiple curves
  multi <- "yhat.id" %in% names(x)

  # Determine number of predictors
  nx <- if (multi) {
    ncol(x) - 2  # don't count yhat or yhat.id
  } else {
    ncol(x) - 1  # don't count yhat
  }

  # Determine which type of plot to draw based on the number of predictors
  if (multi) {

    # Curves from a user-specified prediction function
    tinyplot_ice_curves(
      object = x, center = center, plot.pdp = plot.pdp, pdp.col = pdp.col,
      pdp.lwd = pdp.lwd, pdp.lty = pdp.lty, rug = rug, train = train,
      alpha = alpha, color.by = color.by, ...
    )

  } else if (nx == 1L) {

    tinyplot_one_predictor_pdp(  # single predictor
      object = x, smooth = smooth, rug = rug, train = train, bars = bars, ...
    )

  } else if (nx == 2L) {

    tinyplot_two_predictor_pdp(  # two predictors
      object = x, smooth = smooth, rug = rug, train = train, contour = contour,
      contour.color = contour.color, legend.title = legend.title, ...
    )

  } else {

    stop("`plot()` does not currently support PDPs with more than two ",
         "predictors. Try using `plotPartial()` instead.")

  }

  # Return object invisibly (the plot is drawn as a side effect)
  invisible(x)

}


#' @rdname plot.partial
#'
#' @export
plot.ice <- function(x, center = FALSE, plot.pdp = TRUE, pdp.col = "red2",
                     pdp.lwd = 2, pdp.lty = 1, rug = FALSE, train = NULL,
                     alpha = 1, color.by = NULL, ...) {
  tinyplot_ice_curves(
    object = x, center = center, plot.pdp = plot.pdp, pdp.col = pdp.col,
    pdp.lwd = pdp.lwd, pdp.lty = pdp.lty, rug = rug, train = train,
    alpha = alpha, color.by = color.by, ...
  )
  invisible(x)
}


#' @rdname plot.partial
#'
#' @export
plot.cice <- function(x, plot.pdp = TRUE, pdp.col = "red2", pdp.lwd = 2,
                      pdp.lty = 1, rug = FALSE, train = NULL, alpha = 1,
                      color.by = NULL, ...) {
  tinyplot_ice_curves(
    object = x, center = FALSE, plot.pdp = plot.pdp, pdp.col = pdp.col,
    pdp.lwd = pdp.lwd, pdp.lty = pdp.lty, rug = rug, train = train,
    alpha = alpha, color.by = color.by, ...
  )
  invisible(x)
}


# Add a rug display (min/max and deciles) for a predictor to the current plot
#' @keywords internal
rug_quantiles <- function(train, x.name, side = 1) {
  if (is.null(train)) {
    stop("The training data must be supplied for rug display.")
  }
  graphics::rug(
    stats::quantile(train[, x.name, drop = TRUE], probs = 0:10/10,
                    na.rm = TRUE),
    side = side, col = 1
  )
}


#' @keywords internal
tinyplot_ice_curves <- function(object, center, plot.pdp, pdp.col, pdp.lwd,
                                pdp.lty, rug, train, alpha, color.by = NULL,
                                ...) {

  # Each curve should vary over a single predictor; anything else cannot be
  # displayed sensibly and is better plotted manually
  if (ncol(object) - 2L > 1L) {
    stop("Cannot automatically plot individual curves for multiple ",
         "predictors; each curve would vary over a multi-dimensional grid. ",
         "Try plotting the returned data manually (e.g., by filtering or ",
         "faceting on the additional predictors).", call. = FALSE)
  }

  # Should the curves be centered to start at yhat = 0?
  if (center) {
    object <- center_ice_curves(object)  # converts ICE curves to c-ICE curves
  }

  # Color the individual curves (all black by default, or mapped to a column
  # of `train` whenever `color.by` is specified)
  if (is.null(color.by)) {
    curve.cols <- grDevices::adjustcolor("black", alpha.f = alpha)
    color.groups <- NULL
  } else {
    if (is.null(train)) {
      stop("The training data must be supplied for `color.by` display.")
    }
    ids <- sort(unique(object[["yhat.id"]]))  # one color per curve
    vals <- train[ids, color.by, drop = TRUE]  # assumes IDs index `train`
    color.groups <- if (is.numeric(vals)) {
      cut(vals, breaks = min(5L, length(unique(vals))))
    } else {
      as.factor(vals)
    }
    pal <- grDevices::hcl.colors(nlevels(color.groups), palette = "viridis")
    curve.cols <- grDevices::adjustcolor(pal[as.integer(color.groups)],
                                         alpha.f = alpha)
  }

  # Group curves by a *factor* so tinyplot treats the IDs as discrete (and so
  # per-group colors map predictably to sorted IDs)
  object[["yhat.id"]] <- factor(object[["yhat.id"]],
                                levels = sort(unique(object[["yhat.id"]])))

  # Draw one curve per observation (with points if the predictor is a factor);
  # use do.call() so the call that tinyplot records for tinyplot_add() holds
  # values rather than `...`, which cannot be re-evaluated in other contexts
  x.name <- names(object)[1L]
  plot.type <- if (is.factor(object[[1L]])) "b" else "l"
  do.call(tinyplot::tinyplot, args = c(
    list(
      stats::as.formula(paste("yhat ~", backtick(x.name), "| yhat.id")),
      data = object, type = plot.type, col = curve.cols, legend = FALSE
    ),
    list(...)
  ))
  if (!is.null(color.by)) {  # add a simple legend for the color groups
    graphics::legend(
      "topleft", legend = levels(color.groups), title = color.by,
      col = grDevices::hcl.colors(nlevels(color.groups), palette = "viridis"),
      lty = 1, bty = "n", cex = 0.8
    )
  }

  # Should the PDP (i.e., average curve) be displayed too?
  if (plot.pdp) {
    pd <- average_ice_curves(object)
    tinyplot::tinyplot_add(
      stats::as.formula(paste("yhat ~", backtick(x.name))), data = pd,
      type = "l", col = pdp.col, lwd = pdp.lwd, lty = pdp.lty
    )
  }

  # Add rug display to x-axis
  if (isTRUE(rug) && is.numeric(object[[1L]])) {
    rug_quantiles(train, x.name = x.name)
  }

}


#' @keywords internal
tinyplot_one_predictor_pdp <- function(object, smooth, rug, train,
                                       bars = FALSE, ...) {

  # Draw a line plot (or a scatterplot/bar plot whenever the predictor is a
  # factor); see tinyplot_ice_curves() for why do.call() is used here
  x.name <- names(object)[1L]
  plot.type <- if (is.factor(object[[1L]])) {
    if (isTRUE(bars)) "barplot" else "p"
  } else {
    "l"
  }
  do.call(tinyplot::tinyplot, args = c(
    list(
      stats::as.formula(paste("yhat ~", backtick(x.name))), data = object,
      type = plot.type
    ),
    list(...)
  ))
  if (plot.type == "l") {
    if (isTRUE(smooth)) {  # add a LOESS smooth
      tinyplot::tinyplot_add(type = "loess")
    }
    if (isTRUE(rug)) {  # add rug display to x-axis
      rug_quantiles(train, x.name = x.name)
    }
  }

}


#' @keywords internal
tinyplot_two_predictor_pdp <- function(object, smooth, rug, train, contour,
                                       contour.color, legend.title, ...) {

  # Use the first two columns to determine which type of plot to construct
  x.names <- names(object)[1L:2L]
  if (is.factor(object[[1L]]) || is.factor(object[[2L]])) {

    # Facet on the factor (the first column whenever both are factors)
    facet.pos <- if (is.factor(object[[1L]])) 1L else 2L
    axis.pos <- if (facet.pos == 1L) 2L else 1L
    plot.type <- if (is.factor(object[[axis.pos]])) "p" else "l"

    # Draw a faceted line plot (or scatterplot); see tinyplot_ice_curves() for
    # why do.call() is used here
    do.call(tinyplot::tinyplot, args = c(
      list(
        stats::as.formula(paste("yhat ~", backtick(x.names[axis.pos]))),
        facet = stats::as.formula(paste("~", backtick(x.names[facet.pos]))),
        data = object, type = plot.type
      ),
      list(...)
    ))
    if (plot.type == "l" && isTRUE(smooth)) {
      tinyplot::tinyplot_add(type = "loess")
    }
    if (isTRUE(rug)) {
      warning("rug display is not currently supported for faceted displays.",
              call. = FALSE)
    }

  } else {

    # Draw a false color level plot (i.e., heatmap); tinyplot does not (yet)
    # have a native heatmap type, so construct one from rectangles centered at
    # each grid point
    ux <- sort(unique(object[[1L]]))
    uy <- sort(unique(object[[2L]]))
    wx <- if (length(ux) > 1) min(diff(ux)) else 1
    wy <- if (length(uy) > 1) min(diff(uy)) else 1
    # Muffle tinyplot's warning about continuous legends not being supported
    # for rectangles (the discrete legend it falls back on is perfectly fine);
    # also use do.call() so lazily evaluated arguments (e.g., `legend`) receive
    # values rather than symbols that only exist in this frame
    withCallingHandlers(
      do.call(tinyplot::tinyplot, args = c(
        list(
          xmin = object[[1L]] - wx / 2, xmax = object[[1L]] + wx / 2,
          ymin = object[[2L]] - wy / 2, ymax = object[[2L]] + wy / 2,
          by = object$yhat, type = "rect", fill = "by", lty = 0,
          xlab = x.names[1L], ylab = x.names[2L],
          legend = list(title = legend.title)
        ),
        list(...)
      )),
      warning = function(w) {
        if (grepl("Continuous legends not supported", conditionMessage(w))) {
          invokeRestart("muffleWarning")
        }
      }
    )

    # Add contour lines (the grid may be incomplete when `chull = TRUE`, so
    # fill in a full z matrix and let contour() handle any missing cells)
    if (isTRUE(contour)) {
      z <- matrix(NA_real_, nrow = length(ux), ncol = length(uy))
      z[cbind(match(object[[1L]], ux), match(object[[2L]], uy))] <- object$yhat
      graphics::contour(ux, uy, z, add = TRUE, col = contour.color)
    }

    # Add rug displays to both axes
    if (isTRUE(rug)) {
      rug_quantiles(train, x.name = x.names[1L], side = 1)
      rug_quantiles(train, x.name = x.names[2L], side = 2)
    }

  }

}
