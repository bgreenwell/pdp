#' Plotting Partial Dependence Functions
#'
#' Plots partial dependence functions (i.e., marginal effects) using
#' \code{\link[lattice]{lattice}} graphics.
#'
#' @param object An object that inherits from the \code{"partial"} class.
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
#' @param chull Logical indicating whether or not to restrict the first two
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
#' @param col.regions Vector of colors to be passed on to
#' \code{\link[lattice]{levelplot}}'s \code{col.region} argument. Defaults to
#' \code{grDevices::hcl.colors(100)} (which is the same viridis color palette
#' used in the past).
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
#' library(gridExtra)  # for `grid.arrange()`
#' library(magrittr)  # for forward pipe operator `%>%`
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
#' p1 <- plotPartial(age.ice, alpha = 0.1)
#' p2 <- plotPartial(age.ice, center = TRUE, alpha = 0.1)
#' grid.arrange(p1, p2, ncol = 2)
#' }
plotPartial <- function(object, ...) {
  UseMethod("plotPartial")
}


#' @rdname plotPartial
#'
#' @export
plotPartial.ice <- function(
  object, center = FALSE, plot.pdp = TRUE, pdp.col = "red2", pdp.lwd = 2,
  pdp.lty = 1, rug = FALSE, train = NULL, ...
) {

  # Call workhorse function
  plot_ice_curves(
    object = object, center = center, plot.pdp = plot.pdp, pdp.col = pdp.col,
    pdp.lwd = pdp.lwd, pdp.lty = pdp.lty, rug = rug, train = train, ...
  )

}


#' @rdname plotPartial
#'
#' @export
plotPartial.cice <- function(
  object, plot.pdp = TRUE, pdp.col = "red2", pdp.lwd = 2, pdp.lty = 1,
  rug = FALSE, train = NULL, ...
) {

  # Call workhorse function
  plot_ice_curves(
    object = object, center = FALSE, plot.pdp = plot.pdp, pdp.col = pdp.col,
    pdp.lwd = pdp.lwd, pdp.lty = pdp.lty, rug = rug, train = train, ...
  )

}


#' @rdname plotPartial
#'
#' @export
plotPartial.partial <- function(
  object, center = FALSE, plot.pdp = TRUE, pdp.col = "red2", pdp.lwd = 2,
  pdp.lty = 1, smooth = FALSE, rug = FALSE, chull = FALSE, levelplot = TRUE,
  contour = FALSE, contour.color = "white", col.regions = NULL,
  number = 4, overlap = 0.1, train = NULL, ...
) {

  # Determine if object contains multiple curves
  multi <- "yhat.id" %in% names(object)

  # Determine number of predictors
  nx <- if (multi) {
    ncol(object) - 2  # don't count yhat or yhat.id
  } else {
    ncol(object) - 1  # don't count yhat
  }

  # Throw error if too difficult to plot
  if ((!multi && !(nx %in% 1:3)) || (multi && (nx > 1))) {
    stop("Too many variables to plot. Try using lattice or ggplot2 directly.")
  }

  # Determine which type of plot to draw based on the number of predictors
  if (multi) {

    # Call workhorse function
    plot_ice_curves(  # curves from user-specified prediction function
      object = object, center = center, plot.pdp = plot.pdp, pdp.col = pdp.col,
      pdp.lwd = pdp.lwd, pdp.lty = pdp.lty, rug = rug, train = train, ...
    )

  } else if (nx == 1L) {

    # Call workhorse function
    plot_one_predictor_pdp(  # single predictor
      object = object, smooth = smooth, rug = rug, train = train, ...
    )

  } else if (nx == 2) {

    # Call workhorse function
    plot_two_predictor_pdp(  # two predictors
      object = object, smooth = smooth, levelplot = levelplot, rug = rug,
      chull = chull, train = train, contour = contour,
      contour.color = contour.color, col.regions = col.regions, ...
    )

  } else {

    # Call workhorse function
    plot_three_predictor_pdp(  # three predictors (paneled)
      object = object, nx = nx, smooth = smooth, levelplot = levelplot,
      rug = rug, chull = chull, train = train, contour = contour,
      contour.color = contour.color, col.regions = col.regions,
      number = number, overlap = overlap, ...
    )

  }

}


#' @keywords internal
plot_ice_curves <- function(object, plot.pdp, center, pdp.col, pdp.lwd, pdp.lty,
                            rug, train, ...) {

  # Determine if ICE curves should be centered
  if (center) {
    object <- center_ice_curves(object)  # converts ICE curves to c-ICE curves
  }

  # Determine plot type
  plot.type <- if (is.factor(object[[1L]])) {
    "b"  # draw lines and points
  } else {
    "l"  # draw lines
  }

  # Plot ICE curves
  xyplot(
    stats::as.formula(paste("yhat ~", names(object)[1L])), data = object,
    groups = object$yhat.id, type = plot.type, ...,
    panel = function(xx, yy, ...) {
      panel.xyplot(xx, yy, col = 1, ...)
      if (plot.pdp) {
        pd <- average_ice_curves(object)
        panel.xyplot(
          pd[[1L]], pd$yhat, type = "l", col = pdp.col, lwd = pdp.lwd,
          lty = pdp.lty
        )
      }
      if (rug && is.numeric(object[[1L]])) {
        if (is.null(train)) {
          stop("The training data must be supplied for rug display.")
        } else {
          panel.rug(stats::quantile(train[, names(object)[1L], drop = TRUE],
                                    probs = 0:10/10, na.rm = TRUE),
                    col = 1)
        }
      }
})

}


#' @keywords internal
plot_one_predictor_pdp <- function(object, smooth, rug, train = NULL, ...) {

  # Use the first column to determine which type of plot to construct
  if (is.numeric(object[[1L]])) {

    # Draw a line plot
    xyplot(
      stats::as.formula(paste("yhat ~", names(object)[1L])), data = object,
      type = "l", ..., panel = function(xx, yy, ...) {
        panel.xyplot(xx, yy, col = 1, ...)
        if (smooth) {
          panel.loess(xx, yy, ...)
        }
        if (isTRUE(rug)) {
          if (is.null(train)) {
            stop("The training data must be supplied for rug display.")
          } else {
            panel.rug(stats::quantile(train[, names(object)[1L], drop = TRUE],
                                      probs = 0:10/10, na.rm = TRUE),
                      col = 1)
          }
        }
    })

  } else {

    # Draw a Cleveland dot plot
    dotplot(
      stats::as.formula(paste("yhat ~", names(object)[1L])), data = object, ...
    )

  }
}


#' @keywords internal
plot_two_predictor_pdp <- function(
  object, smooth, levelplot, rug, chull, train, contour, contour.color,
  col.regions, ...
) {

  # Use the first two columns to determine which type of plot to construct
  if (is.factor(object[[1L]]) && is.factor(object[[2L]])) {

    # Draw a Cleveland dot plot
    dotplot(stats::as.formula(
      paste("yhat ~", paste(names(object)[1L:2L], collapse = "|"))
    ), data = object, ...)

  } else if (is.factor(object[[1L]]) || is.factor(object[[2L]])) {

    # Lattice plot formula
    form <- if (is.factor(object[[1L]])) {
      stats::as.formula(
        paste("yhat ~", paste(names(object)[2L:1L], collapse = "|"))
      )
    } else {
      stats::as.formula(
        paste("yhat ~", paste(names(object)[1L:2L], collapse = "|"))
      )
    }

    # Draw a paneled line plot
    xyplot(
      form, data = object, type = "l", ..., panel = function(xx, yy, ...) {
        panel.xyplot(xx, yy, col = 1, ...)
        if (smooth) {
          panel.loess(xx, yy, ...)
        }
        if (isTRUE(rug)) {
          if (is.null(train)) {
            stop("The training data must be supplied for rug display.")
           } else {
             panel.rug(stats::quantile(train[, names(object)[1L], drop = TRUE],
                                       probs = 0:10/10, na.rm = TRUE),
                       col = 1)
           }
        }
    })

    } else {

      # Lattice plot formula
      form <- stats::as.formula(
        paste("yhat ~", paste(names(object)[1L:2L], collapse = "*"))
      )

      # Define color regions
      if (is.null(col.regions)) {
        col.regions <- grDevices::hcl.colors(100)
      }

      # Draw a three-dimensional surface
      if (levelplot) {

        # Draw a false color level plot
        levelplot(
          form, data = object, col.regions = col.regions, contour = contour,
          col = contour.color, ...,
          panel = function(xx, yy, ...) {
            panel.levelplot(xx, yy, ...)
            if (rug || chull) {
              if (is.null(train)) {
                stop(
                  "The training data must be supplied for convex hull display."
                )
              }
            }
            # Add a rug display
            if (isTRUE(rug)) {
              panel.rug(
                x = stats::quantile(train[, names(object)[1L], drop = TRUE],
                                    probs = 0:10/10, na.rm = TRUE),
                y = stats::quantile(train[, names(object)[2L], drop = TRUE],
                                    probs = 0:10/10, na.rm = TRUE),
                col = 1
              )
            }
            # Plot the convex hull of the predictor space of interest
            if (chull) {
              if (is.null(train)) {
                stop(
                  "The training data must be supplied for convex hull display."
                )
              }
              hpts <- grDevices::chull(
                stats::na.omit(train[names(object)[1L:2L]])
              )
              hpts <- c(hpts, hpts[1])
              panel.lines(train[hpts, names(object)[1L:2L]], col = 1)
            }
        })

      } else {

        # Draw a wireframe plot
        wireframe(
          form, data = object, col.regions = col.regions, ...
        )

      }

  }

}

#' @keywords internal
plot_three_predictor_pdp <- function(
  object, nx, smooth, levelplot, rug, chull, train, contour, contour.color,
  col.regions, number, overlap, ...
) {

  # Convert third predictor to a factor using the equal count algorithm
  if (is.numeric(object[[3L]])) {
    object[[3L]] <- equal.count(
      object[[3L]], number = number, overlap = overlap
    )
  }

  if (is.factor(object[[1L]]) && is.factor(object[[2L]])) {

    # Lattice plot formula
    form <- stats::as.formula(
      paste("yhat ~", names(object)[1L], "|",
            paste(names(object)[2L:nx], collapse = "*"))
    )

    # Produce a paneled dotplot
    dotplot(form, data = object, ...)

  } else if (is.factor(object[[1L]]) || is.factor(object[[2L]])) {

    # Lattice plot formula
    form <- if (is.factor(object[[1L]])) {
      stats::as.formula(
        paste("yhat ~", names(object)[2L], "|",
              paste(names(object)[c(1L, 3L:nx)], collapse = "*"))
      )
    } else {
      stats::as.formula(
        paste("yhat ~", names(object)[1L], "|",
              paste(names(object)[2L:nx], collapse = "*"))
      )
    }

    # Produce a paneled line plot
    xyplot(
      form, data = object, type = "p", ...,
      panel = function(xx, yy, ...) {
        panel.xyplot(xx, yy, col = 1, ...)
        if (smooth) {
          panel.loess(xx, yy, ...)
        }
        if (isTRUE(rug)) {
          if (is.null(train)) {
            stop("The training data must be supplied for rug display.")
          } else {
            panel.rug(stats::quantile(train[, names(object)[1L], drop = TRUE],
                                      probs = 0:10/10, na.rm = TRUE),
                      col = 1)
          }
        }
    })

  } else {

    # Lattice plot formula
    form <- stats::as.formula(
      paste("yhat ~", paste(names(object)[1L:2L], collapse = "*"), "|",
            paste(names(object)[3L:nx], collapse = "*"))
    )

    # Define color regions
    if (is.null(col.regions)) {
      col.regions <- grDevices::hcl.colors(100)
    }

    # Draw a three-dimensional surface
    if (levelplot) {

      # Draw a false color level plot
      levelplot(
        form, data = object, col.regions = col.regions, contour = contour,
        col = contour.color, ...
      )

    } else {

      # Draw a wireframe plot
      wireframe(
        form, data = object, col.regions = col.regions, ...
      )

    }

  }

}
