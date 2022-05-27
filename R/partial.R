# FIXME: partial() returns character columns for factors.

#' Partial Dependence Functions
#'
#' Compute partial dependence functions (i.e., marginal effects) for various
#' model fitting objects.
#'
#' @param object A fitted model object of appropriate class (e.g., \code{"gbm"},
#' \code{"lm"}, \code{"randomForest"}, \code{"train"}, etc.).
#'
#' @param pred.var Character string giving the names of the predictor variables
#' of interest. For reasons of computation/interpretation, this should include
#' no more than three variables.
#'
#' @param pred.grid Data frame containing the joint values of interest for the
#' variables listed in \code{pred.var}.
#'
#' @param pred.fun Optional prediction function that requires two arguments:
#' \code{object} and \code{newdata}. If specified, then the function must return
#' a single prediction or a vector of predictions (i.e., not a matrix or data
#' frame). Default is \code{NULL}.
#'
#' @param grid.resolution Integer giving the number of equally spaced points to
#' use for the continuous variables listed in \code{pred.var} when
#' \code{pred.grid} is not supplied. If left \code{NULL}, it will default to
#' the minimum between \code{51} and the number of unique data points for each
#' of the continuous independent variables listed in \code{pred.var}.
#'
#' @param ice Logical indicating whether or not to compute individual
#' conditional expectation (ICE) curves. Default is \code{FALSE}. See
#' Goldstein et al. (2014) for details.
#'
#' @param center Logical indicating whether or not to produce centered ICE
#' curves (c-ICE curves). Only used when \code{ice = TRUE}. Default is
#' \code{FALSE}. See Goldstein et al. (2014) for details.
#'
#' @param approx Logical indicating whether or not to compute a faster, but
#' approximate, marginal effect plot (similar in spirit to the
#' \strong{plotmo} package). If \code{TRUE}, then \code{partial()} will compute
#' predictions across the predictors specified in \code{pred.var} while holding
#' the other predictors constant (a "poor man's partial dependence" function as
#' Stephen Milborrow, the author of \strong{plotmo}, puts it).
#' Default is \code{FALSE}. Note this works with \code{ice = TRUE} as well.
#' WARNING: This option is currently experimental. Use at your own risk. It is
#' possible (and arguably safer) to do this manually by passing a specific
#' "exemplar" observation to the train argument and specifying \code{pred.grid}
#' manually.
#'
#' @param quantiles Logical indicating whether or not to use the sample
#' quantiles of the continuous predictors listed in \code{pred.var}. If
#' \code{quantiles = TRUE} and \code{grid.resolution = NULL} the sample
#' quantiles will be used to generate the grid of joint values for which the
#' partial dependence is computed.
#'
#' @param probs Numeric vector of probabilities with values in [0,1]. (Values up
#' to 2e-14 outside that range are accepted and moved to the nearby endpoint.)
#' Default is \code{1:9/10} which corresponds to the deciles of the predictor
#' variables. These specify which quantiles to use for the continuous predictors
#' listed in \code{pred.var} when \code{quantiles = TRUE}.
#'
#' @param trim.outliers Logical indicating whether or not to trim off outliers
#' from the continuous predictors listed in \code{pred.var} (using the simple
#' boxplot method) before generating the grid of joint values for which the
#' partial dependence is computed. Default is \code{FALSE}.
#'
#' @param type Character string specifying the type of supervised learning.
#' Current options are \code{"auto"}, \code{"regression"} or
#' \code{"classification"}. If \code{type = "auto"} then \code{partial} will try
#' to extract the necessary information from \code{object}.
#'
#' @param inv.link Function specifying the transformation to be applied to the
#' predictions before the partial dependence function is computed
#' (experimental). Default is \code{NULL} (i.e., no transformation). This option
#' is intended to be used for models that allow for non-Gaussian response
#' variables (e.g., counts). For these models, predictions are not typically
#' returned on the original response scale by default. For example, Poisson GBMs
#' typically return predictions on the log scale. In this case setting
#' \code{inv.link = exp} will return the partial dependence function on the
#' response (i.e., raw count) scale.
#'
#' @param which.class Integer specifying which column of the matrix of predicted
#' probabilities to use as the "focus" class. Default is to use the first class.
#' Only used for classification problems (i.e., when
#' \code{type = "classification"}).
#'
#' @param prob Logical indicating whether or not partial dependence for
#' classification problems should be returned on the probability scale, rather
#' than the centered logit. If \code{FALSE}, the partial dependence function is
#' on a scale similar to the logit. Default is \code{FALSE}.
#'
#' @param recursive Logical indicating whether or not to use the weighted tree
#' traversal method described in Friedman (2001). This only applies to objects
#' that inherit from class \code{"gbm"}. Default is \code{TRUE} which is much
#' faster than the exact brute force approach used for all other models. (Based
#' on the C++ code behind \code{\link[gbm]{plot.gbm}}.)
#'
#' @param plot Logical indicating whether to return a data frame containing the
#' partial dependence values (\code{FALSE}) or plot the partial dependence
#' function directly (\code{TRUE}). Default is \code{FALSE}. See
#' \code{\link{plotPartial}} for plotting details.
#'
#' @param plot.engine Character string specifying which plotting engine to use
#' whenever \code{plot = TRUE}. Options include \code{"lattice"} (default) or
#' \code{"ggplot2"}.
#'
#' @param smooth Logical indicating whether or not to overlay a LOESS smooth.
#' Default is \code{FALSE}.
#'
#' @param rug Logical indicating whether or not to include a rug display on the
#' predictor axes. The tick marks indicate the min/max and deciles of the
#' predictor distributions. This helps reduce the risk of interpreting the
#' partial dependence plot outside the region of the data (i.e., extrapolating).
#' Only used when \code{plot = TRUE}. Default is \code{FALSE}.
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
#' @param alpha Numeric value in \code{[0, 1]} specifying the opacity alpha (
#' most useful when plotting ICE/c-ICE curves). Default is 1 (i.e., no
#' transparency). In fact, this option only affects ICE/c-ICE curves and level
#' plots.
#'
#' @param chull Logical indicating whether or not to restrict the values of the
#' first two variables in \code{pred.var} to lie within the convex hull of their
#' training values; this affects \code{pred.grid}. This helps reduce the risk of
#' interpreting the partial dependence plot outside the region of the data
#' (i.e., extrapolating).Default is \code{FALSE}.
#'
#' @param train An optional data frame, matrix, or sparse matrix containing the
#' original training data. This may be required depending on the class of
#' \code{object}. For objects that do not store a copy of the original training
#' data, this argument is required. For reasons discussed below, it is good
#' practice to always specify this argument.
#'
#' @param cats Character string indicating which columns of \code{train} should
#' be treated as categorical variables. Only used when \code{train} inherits
#' from class \code{"matrix"} or \code{"dgCMatrix"}.
#'
#' @param check.class Logical indicating whether or not to make sure each column
#' in \code{pred.grid} has the correct class, levels, etc. Default is
#' \code{TRUE}.
#'
#' @param progress Logical indicating whether or not to display a text-based
#' progress bar. Default is \code{FALSE}.
#'
#' @param parallel Logical indicating whether or not to run \code{partial} in
#' parallel using a backend provided by the \code{foreach} package. Default is
#' \code{FALSE}.
#'
#' @param paropts List containing additional options to be passed onto
#' \code{\link[foreach]{foreach}} when \code{parallel = TRUE}.
#'
#' @param ... Additional optional arguments to be passed onto
#' \code{\link[stats]{predict}}.
#'
#' @return By default, \code{partial} returns an object of class
#' \code{c("data.frame", "partial")}. If \code{ice = TRUE} and
#' \code{center = FALSE} then an object of class \code{c("data.frame", "ice")}
#' is returned. If \code{ice = TRUE} and \code{center = TRUE} then an object of
#' class \code{c("data.frame", "cice")} is returned. These three classes
#' determine the behavior of the \code{plotPartial} function which is
#' automatically called whenever \code{plot = TRUE}. Specifically, when
#' \code{plot = TRUE}, a \code{"trellis"} object is returned (see
#' \code{\link[lattice]{lattice}} for details); the \code{"trellis"} object will
#' also include an additional attribute, \code{"partial.data"}, containing the
#' data displayed in the plot.
#'
#' @note
#' In some cases it is difficult for \code{partial} to extract the original
#' training data from \code{object}. In these cases an error message is
#' displayed requesting the user to supply the training data via the
#' \code{train} argument in the call to \code{partial}. In most cases where
#' \code{partial} can extract the required training data from \code{object},
#' it is taken from the same environment in which \code{partial} is called.
#' Therefore, it is important to not change the training data used to construct
#' \code{object} before calling \code{partial}. This problem is completely
#' avoided when the training data are passed to the \code{train} argument in the
#' call to \code{partial}.
#'
#' It is recommended to call \code{partial} with \code{plot = FALSE} and store
#' the results. This allows for more flexible plotting, and the user will not
#' have to waste time calling \code{partial} again if the default plot is not
#' sufficient.
#'
#' It is possible to retrieve the last printed \code{"trellis"} object, such as
#' those produced by \code{plotPartial}, using \code{trellis.last.object()}.
#'
#' If \code{ice = TRUE} or the prediction function given to \code{pred.fun}
#' returns a prediction for each observation in \code{newdata}, then the result
#' will be a curve for each observation. These are called individual conditional
#' expectation (ICE) curves; see Goldstein et al. (2015) and
#' \code{\link[ICEbox]{ice}} for details.
#'
#' @references
#' J. H. Friedman. Greedy function approximation: A gradient boosting machine.
#' \emph{Annals of Statistics}, \bold{29}: 1189-1232, 2001.
#'
#' Goldstein, A., Kapelner, A., Bleich, J., and Pitkin, E., Peeking Inside the
#' Black Box: Visualizing Statistical Learning With Plots of Individual
#' Conditional Expectation. (2014) \emph{Journal of Computational and Graphical
#' Statistics}, \bold{24}(1): 44-65, 2015.
#'
#' @rdname partial
#'
#' @export
#'
#' @examples
#' \dontrun{
#' #
#' # Regression example (requires randomForest package to run)
#' #
#'
#' # Fit a random forest to the boston housing data
#' library(randomForest)
#' data (boston)  # load the boston housing data
#' set.seed(101)  # for reproducibility
#' boston.rf <- randomForest(cmedv ~ ., data = boston)
#'
#' # Using randomForest's partialPlot function
#' partialPlot(boston.rf, pred.data = boston, x.var = "lstat")
#'
#' # Using pdp's partial function
#' head(partial(boston.rf, pred.var = "lstat"))  # returns a data frame
#' partial(boston.rf, pred.var = "lstat", plot = TRUE, rug = TRUE)
#'
#' # The partial function allows for multiple predictors
#' partial(boston.rf, pred.var = c("lstat", "rm"), grid.resolution = 40,
#'         plot = TRUE, chull = TRUE, progress = TRUE)
#'
#' # The plotPartial function offers more flexible plotting
#' pd <- partial(boston.rf, pred.var = c("lstat", "rm"), grid.resolution = 40)
#' plotPartial(pd, levelplot = FALSE, zlab = "cmedv", drape = TRUE,
#'             colorkey = FALSE, screen = list(z = -20, x = -60))
#'
#' # The autplot function can be used to produce graphics based on ggplot2
#' library(ggplot2)
#' autoplot(pd, contour = TRUE, legend.title = "Partial\ndependence")
#'
#' #
#' # Individual conditional expectation (ICE) curves
#' #
#'
#' # Use partial to obtain ICE/c-ICE curves
#' rm.ice <- partial(boston.rf, pred.var = "rm", ice = TRUE)
#' plotPartial(rm.ice, rug = TRUE, train = boston, alpha = 0.2)
#' autoplot(rm.ice, center = TRUE, alpha = 0.2, rug = TRUE, train = boston)
#'
#' #
#' # Classification example (requires randomForest package to run)
#' #
#'
#' # Fit a random forest to the Pima Indians diabetes data
#' data (pima)  # load the boston housing data
#' set.seed(102)  # for reproducibility
#' pima.rf <- randomForest(diabetes ~ ., data = pima, na.action = na.omit)
#'
#' # Partial dependence of positive test result on glucose (default logit scale)
#' partial(pima.rf, pred.var = "glucose", plot = TRUE, chull = TRUE,
#'         progress = TRUE)
#'
#' # Partial dependence of positive test result on glucose (probability scale)
#' partial(pima.rf, pred.var = "glucose", prob = TRUE, plot = TRUE,
#'         chull = TRUE, progress = TRUE)
#' }
partial <- function(object, ...) {
  UseMethod("partial")
}


#' @rdname partial
#'
#' @export
partial.default <- function(
  object, pred.var, pred.grid, pred.fun = NULL, grid.resolution = NULL,
  ice = FALSE, center = FALSE, approx = FALSE, quantiles = FALSE, probs = 1:9/10,
  trim.outliers = FALSE, type = c("auto", "regression", "classification"),
  inv.link = NULL, which.class = 1L, prob = FALSE, recursive = TRUE,
  plot = FALSE, plot.engine = c("lattice", "ggplot2"),
  smooth = FALSE, rug = FALSE, chull = FALSE, levelplot = TRUE,
  contour = FALSE, contour.color = "white",
  alpha = 1, train, cats = NULL, check.class = TRUE, progress = FALSE,
  parallel = FALSE, paropts = NULL, ...
) {

  # Check prediction function if given
  if (!is.null(pred.fun)) {
    pred.fun <- match.fun(pred.fun)
    if (!identical(names(formals(pred.fun)), c("object", "newdata"))) {
      stop(paste0("`pred.fun` requires a function with only two arguments: ",
                  "object, and newdata."))
    }
  }

  # Match inverse link function if given
  if (!is.null(inv.link)) {
    inv.link <- match.fun(inv.link)
  }

  # Try to extract training data (hard problem) if not provided
  if (missing(train)) {
    train <- get_training_data(object)
  }

  # Convert the training data to a matrix for XGBoost models
  if (inherits(object, "xgb.Booster") && inherits(train, "data.frame")) {
    train <- data.matrix(train)
  }

  # Convert to column names if column positions are given instead
  if (is.numeric(pred.var)) {
    pred.var <- colnames(train)[pred.var]
  }

  # Throw an informative error if any of the variables listed in pred.var do not
  # match one of the column names in train
  if (!all(pred.var %in% colnames(train))) {
    stop(paste(paste(pred.var[!(pred.var %in% colnames(train))],
                     collapse = ", "), "not found in the training data."))
  }

  # Throw an informative error if one of the predictor variables is call "yhat"
  if ("yhat" %in% pred.var) {
    stop("\"yhat\" cannot be a predictor name.")
  }

  # Throw an informative error if requesting ICE curves with more than one
  # predictor
  if (length(pred.var) != 1 && ice) {
    stop("ICE curves cannot be constructed for multiple predictors.")
  }

  # Generate grid of predictor values
  pred.grid <- if (missing(pred.grid)) {
    pred_grid(
      train = train, pred.var = pred.var, grid.resolution = grid.resolution,
      quantiles = quantiles, probs = probs, trim.outliers = trim.outliers,
      cats = cats
    )
  } else {
    if (!is.data.frame(pred.grid)) {
      stop("`pred.grid` shoud be a data frame.")
    } else {
      # Throw error if colnames(pred.grid) does not match pred.var
      if (!all(pred.var %in% colnames(pred.grid))) {
        stop(paste(paste(pred.var[!(pred.var %in% colnames(pred.grid))],
                         collapse = ", "), "not found in pred.grid."))
      } else {
        # Throw warning if quantiles or trim.outliers options used
        if (quantiles || trim.outliers) {
          warning(paste("Options `quantiles` and `trim.outliers`",
                        "ignored whenever `pred.grid` is specified."))
        }
        order_grid(pred.grid)
      }
    }
  }

  # Make sure each column has the correct class, levels, etc.
  if (inherits(train, "data.frame") && check.class) {
    pred.grid <- copy_classes(pred.grid, train)
  }

  # Convert pred.grid to the same class as train if train is not a data frame
  if (inherits(train, "matrix")) {
    pred.grid <- data.matrix(pred.grid)
  }
  if (inherits(train, "dgCMatrix")) {
    pred.grid <- methods::as(data.matrix(pred.grid), "dgCMatrix")
  }

  # Restrict grid to covext hull of first two columns
  if (chull) {
    pred.grid <- train_chull(pred.var, pred.grid = pred.grid, train = train)
  }

  # Determine the type of supervised learning used
  type <- match.arg(type)
  if (type == "auto" && is.null(pred.fun)) {
    type <- get_task(object)  # determine if regression or classification
  }

  # Display warning for GBM objects when recursive = TRUE and ice = TRUE
  if (inherits(object, "gbm") && recursive && ice) {
    warning("Recursive method not available for \"gbm\" objects when `ice = ",
            "TRUE`. Using brute force method instead.")
  }

  # Compute "poor man's partial dependence"
  if (isTRUE(approx)) {       # FIXME: What about when `rug/chull = TRUE`
    train <- exemplar(train)  # FIXME: Better handling for matrix-like objects
  }

  # Calculate partial dependence values
  if (inherits(object, "gbm") && recursive && !ice) {  # weighted tree traversal

    # Warn user if using inv.link when recursive = TRUE
    if (!is.null(inv.link)) {
      warning("`inv.link` option ignored whenever `recursive = TRUE`")
    }

    # Stop and notify user that pred.fun cannot be used when recursive = TRUE
    # with "gbm" objects
    if (!is.null(pred.fun)) {
      stop("Option `pred.fun` cannot currently be used when ",
           "`recursive = TRUE`.")
    }

    # Notify user that progress bars are not avaiable for "gbm" objects when
    # recursive = TRUE
    if (isTRUE(progress)) {
      message("progress bars are not availble when `recursive = TRUE`.",
              call. = FALSE)
    }

    # Stop and notify user that parallel functionality is currently not
    # available for "gbm" objects when recursive = TRUE
    if (parallel) {
      stop("parallel processing cannot be used when `recursive = TRUE`.",
           call. = FALSE)
    }

    # Use Friedman's weighted tree traversal approach
    pd.df <- pardep_gbm(object, pred.var = pred.var, pred.grid = pred.grid,
                        which.class = which.class, prob = prob, ...)
    class(pd.df) <- c("partial", "data.frame")  # assign class labels
    names(pd.df) <- c(pred.var, "yhat")  # rename columns
    rownames(pd.df) <- NULL  # remove row names

  } else {

    # Use brute force approach
    pd.df <- if (type %in% c("regression", "classification") ||
                 !is.null(pred.fun)) {
      pardep(object, pred.var = pred.var, pred.grid = pred.grid,
             pred.fun = pred.fun, inv.link = inv.link, ice = ice, task = type,
             which.class = which.class, logit = !prob, train = train,
             progress = progress, parallel = parallel, paropts = paropts, ...)
    } else {
      stop("partial dependence and ICE are currently only available for ",
           "classification and regression problems.", call. = FALSE)
    }

    # Coerce to a data frame, if needed, and apply finishing touches
    if (is.matrix(pd.df)) {
      pd.df <- as.data.frame(pd.df)
    }
    if (inherits(pd.df, what = "dgCMatrix")) {  # xgboost
      pd.df <- as.data.frame(as.matrix(pd.df))
    }
    if (isTRUE(ice) || ("yhat.id" %in% names(pd.df))) {  # multiple curves

      # Assign class labels
      class(pd.df) <- c("ice", "data.frame")

      # Make sure data are ordered by `yhat.id`
      pd.df <- pd.df[order(pd.df$yhat.id), ]

      # c-ICE curves
      if (isTRUE(center)) {
        pd.df <- center_ice_curves(pd.df)
        if (type == "classification" && prob) {
          warning("Centering may result in probabilities outside of [0, 1].")
          pd.df$yhat <- pd.df$yhat + 0.5
        }
      }

    } else {  # single curve
      class(pd.df) <- c("partial", "data.frame")  # assign class labels
    }
    rownames(pd.df) <- NULL  # remove row names

  }

  # Plot partial dependence function (if requested)
  if (plot) {  # return a graph (i.e., a "trellis" or "ggplot" object)
    plot.engine <- match.arg(plot.engine)
    res <- if (inherits(pd.df, what = c("ice", "cice"))) {
      if (plot.engine == "ggplot2") {
        autoplot(
          object = pd.df, plot.pdp = TRUE, rug = rug, train = train,
          alpha = alpha
        )
      } else {
        plotPartial(
          object = pd.df, plot.pdp = TRUE, rug = rug, train = train,
          alpha = alpha,
        )
      }
    } else {
      if (plot.engine == "ggplot2") {
        autoplot(pd.df, smooth = smooth, rug = rug, train = train,
                 contour = contour, contour.color = contour.color,
                 alpha = alpha)
      } else {
        plotPartial(pd.df, smooth = smooth, rug = rug, train = train,
                    levelplot = levelplot, contour = contour,
                    contour.color = contour.color,
                    screen = list(z = -30, x = -60))  # sensible default?
      }
    }
    attr(res, "partial.data") <- pd.df  # attach PDP data as an attribute
  } else {  # return a data frame (i.e., a "data.frame" and "partial" object)
    res <- pd.df
  }

  # Return results
  res

}


#' @rdname partial
#'
#' @export
partial.model_fit <- function(object, ...) {
  partial.default(object$fit, ...)
}
