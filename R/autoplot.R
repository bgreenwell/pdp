#' Plotting Partial Dependence Functions
#'
#' Plots partial dependence functions (i.e., marginal effects) using
#' \code{\link[ggplot2]{ggplot2}} graphics.
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
#' @param pdp.color Character string specifying the color to use for the partial
#' dependence function when \code{plot.pdp = TRUE}. Default is \code{"red"}.
#'
#' @param pdp.size Positive number specifying the line width to use for the
#' partial dependence function when \code{plot.pdp = TRUE}. Default is \code{1}.
#'
#' @param pdp.linetype Positive number specifying the line type to use for the
#' partial dependence function when \code{plot.pdp = TRUE}. Default is \code{1}.
#'
#' @param rug Logical indicating whether or not to include rug marks on the
#' predictor axes. Default is \code{FALSE}.
#'
#' @param smooth Logical indicating whether or not to overlay a LOESS smooth.
#' Default is \code{FALSE}.
#'
#' @param smooth.method Character string specifying the smoothing method
#' (function) to use (e.g., \code{"auto"}, \code{"lm"}, \code{"glm"},
#' \code{"gam"}, \code{"loess"}, or \code{"rlm"}). Default is \code{"auto"}.
#' See \code{\link[ggplot2]{geom_smooth}} for details.
#'
#' @param smooth.formula Formula to use in smoothing function (e.g.,
#' \code{y ~ x}, \code{y ~ poly(x, 2)}, or \code{y ~ log(x)}).
#'
#' @param smooth.span Controls the amount of smoothing for the default loess
#' smoother. Smaller numbers produce wigglier lines, larger numbers produce
#' smoother lines. Default is \code{0.75}.
#'
#' @param smooth.method.args List containing additional arguments to be passed
#' on to the modeling function defined by \code{smooth.method}.
#'
#' @param contour Logical indicating whether or not to add contour lines to the
#' level plot.
#'
#' @param contour.color Character string specifying the color to use for the
#' contour lines when \code{contour = TRUE}. Default is \code{"white"}.
#'
#' @param train Data frame containing the original training data. Only required
#' if \code{rug = TRUE} or \code{chull = TRUE}.
#'
#' @param xlab Character string specifying the text for the x-axis label.
#'
#' @param ylab Character string specifying the text for the y-axis label.
#'
#' @param main Character string specifying the text for the main title of the
#' plot.
#'
#' @param legend.title Character string specifying the text for the legend title.
#' Default is \code{"yhat"}.
#'
#' @param ... Additional (optional) arguments to be passed onto
#' \code{\link[ggplot2]{geom_line}}, \code{\link[ggplot2]{geom_point}}, or
#' \code{\link[ggplot2]{scale_fill_viridis_c}}.
#'
#' @return A \code{"ggplot"} object.
#'
#' @importFrom ggplot2 aes autoplot facet_wrap geom_contour geom_line
#'
#' @importFrom ggplot2 geom_point geom_rug geom_smooth geom_tile ggplot ggtitle
#'
#' @importFrom ggplot2 scale_fill_viridis_c stat_summary
#'
#' @importFrom ggplot2 theme_bw xlab ylab
#'
#' @importFrom rlang .data
#'
#' @rdname autoplot.partial
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
#' library(ggplot2)  # for autoplot() generic
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
#'   autoplot(rug = TRUE, train = boston) + theme_bw()
#'
#' # Partial dependence of cmedv on lstat and rm
#' boston.rf %>%
#'   partial(pred.var = c("lstat", "rm"), chull = TRUE, progress = TRUE) %>%
#'   autoplot(contour = TRUE, legend.title = "cmedv",
#'            option = "B", direction = -1) + theme_bw()
#'
#' # ICE curves and c-ICE curves
#' age.ice <- partial(boston.rf, pred.var = "lstat", ice = TRUE)
#' grid.arrange(
#'   autoplot(age.ice, alpha = 0.1),                 # ICE curves
#'   autoplot(age.ice, center = TRUE, alpha = 0.1),  # c-ICE curves
#'   ncol = 2
#' )
#' }
autoplot.partial <- function(object, center = FALSE, plot.pdp = TRUE,
                             pdp.color = "red", pdp.size = 1, pdp.linetype = 1,
                             rug = FALSE, smooth = FALSE,
                             smooth.method = "auto", smooth.formula = y ~ x,
                             smooth.span = 0.75, smooth.method.args = list(),
                             contour = FALSE, contour.color = "white",
                             train = NULL, xlab = NULL, ylab = NULL,
                             main = NULL, legend.title = "yhat", ...) {

  # Determine if object contains an ID column (i.e., multiple curves)
  multi <- "yhat.id" %in% names(object)

  # Determine number of variables to plot
  nx <- if (multi) {
    ncol(object) - 2  # don't count yhat or yhat.id
  } else {
    ncol(object) - 1  # don't count yhat
  }

  # Generate plot
  if (multi) {  # user-supplied prediction function

    # Call workhorse function
    ggplot_ice_curves(  # ICE curves from user-specified prediction function
      object = object, center = center, plot.pdp = plot.pdp,
      pdp.color = pdp.color, pdp.size = pdp.size, pdp.linetype = 1, rug = rug,
      train = train, xlab = xlab, ylab = ylab, main = main, ...
    )

  } else if (nx == 1L) {  # one predictor

    # Call workhorse function
    ggplot_one_predictor_pdp(  # single predictor PDP
      object = object, rug = rug, smooth = smooth,
      smooth.method = smooth.method, smooth.formula = smooth.formula,
      smooth.span = smooth.span, smooth.method.args = smooth.method.args,
      train = train, xlab = xlab, ylab = ylab, main = main, ...
    )

  } else if (nx == 2L) {  # two predictors

    # Call workhorse function
    ggplot_two_predictor_pdp(  # two predictor PDP
      object = object, rug = rug, smooth = smooth,
      smooth.method = smooth.method, smooth.formula = smooth.formula,
      smooth.span = smooth.span, smooth.method.args = smooth.method.args,
      contour = contour, contour.color = contour.color,
      train = train, xlab = xlab, ylab = ylab, main = main,
      legend.title = legend.title, ...
    )

  } else {  # more than two predictors

    # Throw error
    stop("`autoplot()` does not currently support PDPs with more than two ",
         "predictors.")

  }

}


#' @rdname autoplot.partial
#'
#' @export
autoplot.ice <- function(
  object, center = FALSE, plot.pdp = TRUE, pdp.color = "red", pdp.size = 1,
  pdp.linetype = 1, rug = FALSE, train = NULL, xlab = NULL, ylab = NULL,
  main = NULL, ...
) {

  # Call workhorse function
  ggplot_ice_curves(  # ICE curves
    object = object, center = center, plot.pdp = plot.pdp,
    pdp.color = pdp.color, pdp.size = pdp.size, pdp.linetype = pdp.linetype,
    rug = rug, train = train, xlab = xlab, ylab = ylab, main = main, ...
  )

}


#' @rdname autoplot.partial
#'
#' @export
autoplot.cice <- function(
  object, plot.pdp = TRUE, pdp.color = "red", pdp.size = 1, pdp.linetype = 1,
  rug = FALSE, train = NULL, xlab = NULL, ylab = NULL, main = NULL, ...
) {

  # Call workhorse function
  ggplot_ice_curves(  # c-ICE curves
    object = object, center = FALSE, plot.pdp = plot.pdp, pdp.color = pdp.color,
    pdp.size = pdp.size, pdp.linetype = pdp.linetype, rug = rug, train = train,
    xlab = xlab, ylab = ylab, main = main, ...
  )

}


#' @keywords internal
ggplot_ice_curves <- function(
  object, center, plot.pdp, pdp.color, pdp.size, pdp.linetype, rug, train,
  xlab, ylab, main, ...
) {

  # Should the curves be centered to start at yhat = 0?
  if (center) {
    object <- center_ice_curves(object)
  }

  # Use the first column to determine which type of plot to construct
  if (is.factor(object[[1L]])) {

    # Draw scatterplots
    p <- ggplot(object,
                aes(.data[[names(object)[1L]]], .data[["yhat"]], group = 1)) +
      geom_line(aes(group = .data[["yhat.id"]]), ...) +
      geom_point(aes(group = .data[["yhat.id"]]))

    # Should the PDP be displayed too?
    if (plot.pdp) {
      p <- p + stat_summary(
        fun = mean, geom = "line", col = pdp.color, size = pdp.size,
        linetype = pdp.linetype
      )
    }

  } else {

    # Draw lineplots
    p <- ggplot(object, aes(.data[[names(object)[1L]]], .data[["yhat"]])) +
      geom_line(aes(group = .data[["yhat.id"]]), ...)

    # Should the PDP be displayed too?
    if (plot.pdp) {
      p <- p + stat_summary(
        fun = mean, geom = "line", col = pdp.color, size = pdp.size,
        linetype = pdp.linetype
      )
    }

    # Add rug plot to x-axis
    if (isTRUE(rug)) {
      if (is.null(train)) {
        stop("The training data must be supplied for rug display.")
      } else {
        x.name <- which(colnames(train) == names(object)[[1L]])
        x.rug <- data.frame(as.numeric(
          stats::quantile(train[, x.name, drop = TRUE], probs = 0:10/10,
                          na.rm = TRUE)))
        p <- p + geom_rug(data = x.rug, aes(.data[[names(x.rug)[1L]]]),
                          sides = "b", inherit.aes = FALSE)
      }
    }

  }

  # Add axis labels and title
  if (is.null(xlab)) {
    p <- p + xlab(names(object)[1L])
  } else {
    p <- p + xlab(xlab)
  }
  if (is.null(ylab)) {
    p <- p + ylab("yhat")
  } else {
    p <- p + ylab(ylab)
  }
  if (!is.null(main)) {
    p <- p + ggtitle(main)
  }

  # Return "ggplot" object
  p

}


#' @keywords internal
ggplot_one_predictor_pdp <- function(
  object, rug, smooth, smooth.method, smooth.formula, smooth.span,
  smooth.method.args, train, xlab, ylab, main, ...
) {

  # Use the first column to determine which type of plot to construct
  if (is.factor(object[[1L]])) {

    # Draw a scatterplot
    p <- ggplot(object, aes(.data[[names(object)[1L]]], .data[["yhat"]])) +
      geom_point(...)

  } else {

    # Draw a lineplot
    p <- ggplot(object, aes(.data[[names(object)[1L]]], .data[["yhat"]])) +
      geom_line(...)

    # Add rug plot to x-axis
    if (isTRUE(rug)) {
      if (is.null(train)) {
        stop("The training data must be supplied for rug display.")
      } else {
        x.name <- which(colnames(train) == names(object)[[1L]])
        x.rug <- data.frame(as.numeric(
          stats::quantile(train[, x.name, drop = TRUE], probs = 0:10/10,
                          na.rm = TRUE)))
        p <- p + geom_rug(data = x.rug, aes(.data[[names(x.rug)[1L]]]),
                                            sides = "b", inherit.aes = FALSE)
      }
    }

    # Add smoother
    if (smooth) {
      p <- p + geom_smooth(
        method = smooth.method, formula = smooth.formula, span = smooth.span,
        se = FALSE, method.args = smooth.method.args
      )
    }

  }

  # Add axis labels and title
  if (is.null(xlab)) {
    p <- p + xlab(names(object)[1L])
  } else {
    p <- p + xlab(xlab)
  }
  if (is.null(ylab)) {
    p <- p + ylab("yhat")
  } else {
    p <- p + ylab(ylab)
  }
  if (!is.null(main)) {
    p <- p + ggtitle(main)
  }

  # Return "ggplot" object
  p

}


#' @keywords internal
ggplot_two_predictor_pdp <- function(
  object, rug, smooth, smooth.method, smooth.formula, smooth.span,
  smooth.method.args, contour, contour.color, train, xlab, ylab, main,
  legend.title, ...
) {

  # Use the first two columns to determine which type of plot to construct
  if (is.factor(object[[1L]]) && is.factor(object[[2L]])) {

    # Draw a faceted scatterplot
    p <- ggplot(object, aes(.data[[names(object)[1L]]], .data[["yhat"]])) +
      geom_point(...) +
      facet_wrap(~ .data[[names(object)[2L]]])

  } else if (is.factor(object[[1L]]) && !is.factor(object[[2L]])) {

    # Draw a faceted lineplot
    p <- ggplot(object, aes(.data[[names(object)[2L]]], .data[["yhat"]])) +
      geom_line(...) +
      facet_wrap(~ .data[[names(object)[1L]]])

    # Add rug plot to the x-axis
    if (isTRUE(rug)) {
      if (is.null(train)) {
        stop("The training data must be supplied for rug display.")
      } else {
        x.name <- which(colnames(train) == names(object)[[2L]])
        x.rug <- data.frame(as.numeric(
          stats::quantile(train[, x.name, drop = TRUE], probs = 0:10/10,
                          na.rm = TRUE)))
        p <- p + geom_rug(data = x.rug, aes(.data[[names(x.rug)[1L]]]),
                                            sides = "b", inherit.aes = FALSE)
      }
    }

    # Add smoother
    if (smooth) {
      p <- p + geom_smooth(
        method = smooth.method, formula = smooth.formula, span = smooth.span,
        se = FALSE, method.args = smooth.method.args
      )
    }

  } else if (!is.factor(object[[1L]]) && is.factor(object[[2L]])) {

    # Draw a faceted lineplot
    p <- ggplot(object, aes(.data[[names(object)[1L]]], .data[["yhat"]])) +
      geom_line(...) +
      facet_wrap(~ .data[[names(object)[2L]]])

    # Add rug plot to x-axis
    if (isTRUE(rug)) {
      if (is.null(train)) {
        stop("The training data must be supplied for rug display.")
      } else {
        x.name <- which(colnames(train) == names(object)[[1L]])
        x.rug <- data.frame(as.numeric(
          stats::quantile(train[, x.name, drop = TRUE], probs = 0:10/10,
                          na.rm = TRUE)))
        p <- p + geom_rug(data = x.rug, aes(.data[[names(x.rug)[1L]]]),
                                            sides = "b", inherit.aes = FALSE)
      }
    }

    # Add smoother
    if (smooth) {
      p <- p + geom_smooth(
        method = smooth.method, formula = smooth.formula, span = smooth.span,
        se = FALSE, method.args = smooth.method.args
      )
    }

  } else {

    # Draw a false color level plot
    p <- ggplot(object,
                aes(.data[[names(object)[1L]]], .data[[names(object)[2L]]],
                    z = .data[["yhat"]], fill = .data[["yhat"]])
    ) + geom_tile()

    # Add contour lines
    if (contour) {
      p <- p + geom_contour(color = contour.color)
    }

    # Add legend title and theme
    p <- p + scale_fill_viridis_c(name = legend.title, ...)

  }

  # Add axis labels and title
  if (is.null(xlab)) {
    p <- if (is.factor(object[[1L]]) && !is.factor(object[[2L]])) {
      p + xlab(names(object)[2L])
    } else {
      p + xlab(names(object)[1L])
    }
  } else {
    p <- p + xlab(xlab)
  }
  if (is.null(ylab)) {
    p <- if (!is.factor(object[[1L]]) && !is.factor(object[[2L]])) {
      p + ylab(names(object)[2L])
    } else {
      p + ylab("yhat")
    }
  } else {
    p <- p + ylab(ylab)
  }
  if (!is.null(main)) {
    p <- p + ggtitle(main)
  }

  # Return "ggplot" object
  p

}
