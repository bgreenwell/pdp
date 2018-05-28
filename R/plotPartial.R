#' Plotting Partial Dependence Functions
#'
#' Plots partial dependence functions (i.e., marginal effects) using
#' \code{\link[lattice]{lattice}} graphics.
#'
#' @param x An object that inherits from the \code{"partial"} class.
#'
#' @param center Logical indicating whether or not to produce centered ICE
#' curves (c-ICE curves). Only useful when \code{object} represents a set of ICE
#' curves; see \code{\link[pdp]{partial}} for details. Default is \code{FALSE}.
#'
#' @param plot.pdp Logical indicating whether or not to plot the partial
#' dependence function on top of the ICE curves. Default is \code{TRUE}.
#'
#' @param pdp.col Character string specifying the color to use for the partial
#' dependence function when \code{plot.pdp = TRUE}. Default is \code{"red"}.
#'
#' @param pdp.lwd Integer specifying the line width to use for the partial
#' dependence function when \code{plot.pdp = TRUE}. Default is \code{1}. See
#' \code{\link[graphics]{par}} for more details.
#'
#' @param pdp.lty Integer or character string specifying the line type to use
#' for the partial dependence function when  \code{plot.pdp = TRUE}. Default is
#' \code{1}. See \code{\link[graphics]{par}} for more details.
#'
#' @param smooth Logical indicating whether or not to overlay a LOESS smooth.
#' Default is \code{FALSE}.
#'
#' @param rug Logical indicating whether or not to include rug marks on the
#' predictor axes. Default is \code{FALSE}.
#'
#' @param chull Logical indicating wether or not to restrict the first two
#' variables in \code{pred.var} to lie within the convex hull of their training
#' values; this affects \code{pred.grid}. Default is \code{FALSE}.
#'
#' @param levelplot Logical indicating whether or not to use a false color level
#' plot (\code{TRUE}) or a 3-D surface (\code{FALSE}). Default is \code{TRUE}.
#'
#' @param contour Logical indicating whether or not to add contour lines to the
#' level plot. Only used when \code{levelplot = TRUE}. Default is \code{FALSE}.
#'
#' @param contour.color Character string specifying the color to use for the
#' contour lines when \code{contour = TRUE}. Default is \code{"white"}.
#'
#' @param palette Character string indicating the colormap option to use. Five
#' options are available: "viridis" (the default), "magma", "inferno", "plasma",
#' and "cividis".
#'
#' @param alpha Numeric value in \code{[0, 1]} specifying the opacity alpha (
#' most useful when plotting ICE/c-ICE curves). Default is 1 (i.e., no
#' transparency).
#'
#' @param number Integer specifying the number of conditional intervals to use
#' for the continuous panel variables. See \code{\link[graphics]{co.intervals}}
#' and \code{\link[lattice]{equal.count}} for further details.
#'
#' @param overlap The fraction of overlap of the conditioning variables. See
#' \code{\link[graphics]{co.intervals}} and \code{\link[lattice]{equal.count}}
#' for further details.
#'
#' @param train Data frame containing the original training data. Only required
#' if \code{rug = TRUE} or \code{chull = TRUE}.
#'
#' @param col.regions Color vector to be used for trivariate displays. If
#' \code{levelplot} is \code{TRUE}, defaults to the wonderful Matplotlib
#' 'viridis' color map provided by the \code{viridis} package. See
#' \code{\link[viridis]{viridis}} for details.
#'
#' @param ... Additional optional arguments to be passed onto \code{dotplot},
#' \code{levelplot}, \code{xyplot}, or \code{wireframe}.
#'
#' @importFrom lattice dotplot equal.count levelplot panel.dotplot
#'
#' @importFrom lattice panel.levelplot panel.lines panel.loess panel.xyplot
#'
#' @importFrom lattice panel.rug wireframe xyplot
#'
#' @rdname plotPartial
#'
#' @export
#'
#' @examples
#' \dontrun{
#' #
#' # Regression example (requires randomForest package to run)
#' #
#'
#' # Load required packages
#' library(ggplot2)  # required to use autoplot
#' library(randomForest)
#'
#' # Fit a random forest to the Boston housing data
#' data (boston)  # load the boston housing data
#' set.seed(101)  # for reproducibility
#' boston.rf <- randomForest(cmedv ~ ., data = boston)
#'
#' # Partial dependence of cmedv on lstat
#' boston.rf %>%
#'   partial(pred.var = "lstat") %>%
#'   plotPartial(rug = TRUE, train = boston)
#'
#' # Partial dependence of cmedv on lstat and rm
#' boston.rf %>%
#'   partial(pred.var = c("lstat", "rm"), chull = TRUE, progress = "text") %>%
#'   plotPartial(contour = TRUE, legend.title = "rm")
#'
#' # ICE curves and c-ICE curves
#' age.ice <- partial(boston.rf, pred.var = "lstat", ice = TRUE)
#' p1 <- plotPartial(age.ice, alpha = 0.5)
#' p2 <- plotPartial(age.ice, center = TRUE, alpha = 0.5)
#' grid.arrange(p1, p2, ncol = 2)
#' }
plotPartial <- function(x, ...) {
  UseMethod("plotPartial")
}


#' @rdname plotPartial
#' @export
plotPartial.ice <- function(
  x, center = FALSE, plot.pdp = TRUE, pdp.col = "red2", pdp.lwd = 2,
  pdp.lty = 1, rug = FALSE, train = NULL, alpha = 1, ...
) {
  plotIceCurves(x, center = center, plot.pdp = plot.pdp, pdp.col = pdp.col,
                pdp.lwd = pdp.lwd, pdp.lty = pdp.lty, rug = rug, train = train,
                alpha = alpha, ...)
}


#' @rdname plotPartial
#' @export
plotPartial.cice <- function(
  x, plot.pdp = TRUE, pdp.col = "red2", pdp.lwd = 2, pdp.lty = 1, rug = FALSE,
  train = NULL, alpha = 1, ...
) {
  plotIceCurves(x, center = FALSE, plot.pdp = plot.pdp, pdp.col = pdp.col,
                pdp.lwd = pdp.lwd, pdp.lty = pdp.lty, rug = rug, train = train,
                alpha = alpha, ...)
}


#' @rdname plotPartial
#' @export
plotPartial.partial <- function(
  x, center = FALSE, plot.pdp = TRUE, pdp.col = "red2", pdp.lwd = 2,
  pdp.lty = 1, smooth = FALSE, rug = FALSE, chull = FALSE, levelplot = TRUE,
  contour = FALSE, contour.color = "white",
  palette = c("viridis", "magma", "inferno", "plasma", "cividis"),
  alpha = 1, number = 4, overlap = 0.1, train = NULL, ...
) {

  # Determine of x contains multiple curves
  multi <- "yhat.id" %in% names(x)

  # Determine number of predictors
  nx <- if (multi) {
    ncol(x) - 2  # don't count yhat or yhat.id
  } else {
    ncol(x) - 1  # don't count yhat
  }

  # Throw error if too difficult to plot
  if ((!multi && !(nx %in% 1:3)) || (multi && (nx > 1))) {
    stop("Too many variables to plot. Try using lattice or ggplot2 directly.")
  }

  # Determine which type of plot to draw based on the number of predictors
  if (multi) {

    # Multiple curves from user-specified prediction function
    plotIceCurves(x, center = center, plot.pdp = plot.pdp, pdp.col = pdp.col,
                  pdp.lwd = pdp.lwd, pdp.lty = pdp.lty, rug = rug,
                  train = train, alpha = alpha, ...)

  } else if (nx == 1L) {

    # Single predictor
    plotOnePredictorPDP(x, smooth = smooth, rug = rug, train = train, ...)

  } else if (nx == 2) {

    # Two predictors
    palette <- match.arg(palette)
    plotTwoPredictorPDP(x, smooth = smooth, levelplot = levelplot, rug = rug,
                        chull = chull, train = train, contour = contour,
                        contour.color = contour.color, palette = palette,
                        alpha = alpha, ...)

  } else {

    # Three predictors (paneled version of plotTwoPredictorPDP)
    palette <- match.arg(palette)
    plotThreePredictorPDP(x, nx = nx, smooth = smooth, levelplot = levelplot,
                          rug = rug, chull = chull, train = train,
                          contour = contour, contour.color = contour.color,
                          palette = palette, alpha = alpha, number = number,
                          overlap = overlap, ...)

  }

}


#' @keywords internal
plotIceCurves <- function(x, plot.pdp, center, pdp.col, pdp.lwd, pdp.lty, rug,
                          train, alpha = 1, ...) {

  # Determine if ICE curves should be centered
  if (center) {
    x <- centerIceCurves(x)  # converts ICE curves to c-ICE curves
  }

  # Determine plot type
  plot.type <- if (is.factor(x[[1L]])) {
    "b"  # draw lines and points
  } else {
    "l"  # draw lines
  }

  # Draw ICE curves
  xyplot(stats::as.formula(paste("yhat ~", names(x)[1L])), data = x,
         groups = x$yhat.id, type = plot.type, alpha = alpha, ...,
         panel = function(xx, yy, ...) {
           panel.xyplot(xx, yy, col = "black", ...)
           if (plot.pdp) {
             pd <- averageIceCurves(x)
             panel.xyplot(pd[[1L]], pd$yhat, type = "l", col = pdp.col,
                          lwd = pdp.lwd, lty = pdp.lty)
           }
           if (rug && is.numeric(x[[1L]])) {
             if (is.null(train)) {
               stop("The training data must be supplied for rug display.")
             } else {
               panel.rug(stats::quantile(train[, names(x)[1L]],
                                         probs = 0:10/10, na.rm = TRUE))
             }
           }
         })

}


#' @keywords internal
plotOnePredictorPDP <- function(x, smooth, rug, train = NULL, ...) {

  # Use the first column to determine which type of plot to construct
  if (is.numeric(x[[1L]])) {

    # Draw a line plot
    xyplot(stats::as.formula(paste("yhat ~", names(x)[1L])), data = x,
           type = "l", ..., panel = function(xx, yy, ...) {
             panel.xyplot(xx, yy, col = "black", ...)
             if (smooth) {
               panel.loess(xx, yy, ...)
             }
             if (rug) {
               if (is.null(train)) {
                 stop("The training data must be supplied for rug display.")
               } else {
                 panel.rug(stats::quantile(train[, names(x)[1L]],
                                           probs = 0:10/10, na.rm = TRUE))
               }
             }
           })

  } else {

    # Draw a Cleveland dot plot
    dotplot(stats::as.formula(paste("yhat ~", names(x)[1L])), data = x, ...)

  }
}


#' @keywords internal
plotTwoPredictorPDP <- function(
  x, smooth, levelplot, rug, chull, train, contour, contour.color, palette,
  alpha, ...
) {

  # Use the first two columns to determine which type of plot to construct
  if (is.factor(x[[1L]]) && is.factor(x[[2L]])) {

    # Draw a Cleveland dot plot
    dotplot(stats::as.formula(
      paste("yhat ~", paste(names(x)[1L:2L], collapse = "|"))
    ), data = x, ...)

  } else if (is.factor(x[[1L]]) || is.factor(x[[2L]])) {

    # Lattice plot formula
    form <- if (is.factor(x[[1L]])) {
      stats::as.formula(paste("yhat ~", paste(names(x)[2L:1L], collapse = "|")))
    } else {
      stats::as.formula(paste("yhat ~", paste(names(x)[1L:2L], collapse = "|")))
    }

    # Draw a paneled line plot
    xyplot(form, data = x, type = "l", ...,
           panel = function(xx, yy, ...) {
             panel.xyplot(xx, yy, col = "black", ...)
             if (smooth) {
               panel.loess(xx, yy, ...)
             }
             if (rug) {
               if (is.null(train)) {
                 stop("The training data must be supplied for rug display.")
               } else {
                 panel.rug(stats::quantile(train[, names(x)[1L]],
                                           probs = 0:10/10, na.rm = TRUE))
               }
             }
           })

    } else {

      # Lattice plot formula
      form <- stats::as.formula(
        paste("yhat ~", paste(names(x)[1L:2L], collapse = "*"))
      )

      # Define color regions
      col.regions <- viridis::viridis_pal(option = palette, alpha = alpha)(100)

      # Draw a three-dimensional surface
      if (levelplot) {

        # Draw a false color level plot
        levelplot(
          form, data = x, col.regions = col.regions, contour = contour,
          col = contour.color, ...,
          panel = function(x1, y1, ...) {
            panel.levelplot(x1, y1, ...)
            if (rug || chull) {
              if (is.null(train)) {
                stop("The training data must be supplied for convex hull display.")
              }
            }
            # Add a rug display
            if (rug) {
              panel.rug(
                x = stats::quantile(train[, names(x)[1L]], probs = 0:10/10, na.rm = TRUE),
                y = stats::quantile(train[, names(x)[2L]], probs = 0:10/10, na.rm = TRUE),
                col = "black"
              )
            }
            # Plot the convex hull of the predictor space of interest
            if (chull) {
              if (is.null(train)) {
                stop("The training data must be supplied for convex hull display.")
              }
              hpts <- grDevices::chull(stats::na.omit(train[names(x)[1L:2L]]))
              hpts <- c(hpts, hpts[1])
              panel.lines(train[hpts, names(x)[1L:2L]], col = "black")
            }
        })

      } else {

        # Draw a wireframe plot
        wireframe(form, data = x, col.regions = col.regions, drape = TRUE, ...)

      }

  }
}


#' @keywords internal
plotThreePredictorPDP <- function(
  x, nx, smooth, levelplot, rug, chull, train, contour, contour.color,
  palette, alpha, number, overlap, ...
) {

  # Convert third predictor to a factor using the equal count algorithm
  if (is.numeric(x[[3L]])) {
    x[[3L]] <- equal.count(x[[3L]], number = number, overlap = overlap)
  }

  if (is.factor(x[[1L]]) && is.factor(x[[2L]])) {

    # Lattice plot formula
    form <- stats::as.formula(
      paste("yhat ~", names(x)[1L], "|", paste(names(x)[2L:nx], collapse = "*"))
    )

    # Produce a paneled dotplot
    dotplot(form, data = x, ...)

  } else if (is.factor(x[[1L]]) || is.factor(x[[2L]])) {

    # Lattice plot formula
    form <- if (is.factor(x[[1L]])) {
      stats::as.formula(
        paste("yhat ~", names(x)[2L], "|",
              paste(names(x)[c(1L, 3L:nx)], collapse = "*"))
      )
    } else {
      stats::as.formula(
        paste("yhat ~", names(x)[1L], "|",
              paste(names(x)[2L:nx], collapse = "*"))
      )
    }

    # Produce a paneled lineplot
    xyplot(
      form, data = x, type = "p", ...,
      panel = function(xx, yy, ...) {
        panel.xyplot(xx, yy, col = "black", ...)
        if (smooth) {
          panel.loess(xx, yy, ...)
        }
        if (rug) {
          if (is.null(train)) {
            stop("The training data must be supplied for rug display.")
          } else {
            panel.rug(
              stats::quantile(train[, names(x)[1L]], probs = 0:10/10,
                              na.rm = TRUE)
            )
          }
        }
    })

  } else {

    # Lattice plot formula
    form <- stats::as.formula(
      paste("yhat ~", paste(names(x)[1L:2L], collapse = "*"), "|",
            paste(names(x)[3L:nx], collapse = "*"))
    )

    # Define color regions
    col.regions <- viridis::viridis_pal(option = palette, alpha = alpha)(100)

    # Draw a three-dimensional surface
    if (levelplot) {

      # Draw a false color level plot
      levelplot(form, data = x, col.regions = col.regions, contour = contour,
                col = contour.color, ...)

    } else {

      # Draw a wireframe plot
      wireframe(form, data = x, col.regions = col.regions, drape = TRUE, ...)

    }

  }

}
