# FIXME: partial() returns character columns for factors.

#' Partial Dependence Functions
#'
#' Compute partial dependence functions (i.e., marginal effects) for various
#' model fitting objects.
#'
#' @param object A fitted model object of appropriate class (e.g., `"gbm"`,
#' `"lm"`, `"randomForest"`, `"train"`, etc.).
#'
#' @param pred.var Character string giving the names of the predictor variables
#' of interest. For reasons of computation/interpretation, this should include
#' no more than three variables. Can be omitted whenever `pred.grid` is
#' supplied, in which case it defaults to `colnames(pred.grid)`.
#'
#' @param pred.grid Data frame containing the joint values of interest for the
#' variables listed in `pred.var`.
#'
#' @param pred.fun Optional prediction function that requires two arguments:
#' `object` and `newdata`. If specified, then the function must return
#' a single prediction or a vector of predictions (i.e., not a matrix or data
#' frame). Default is `NULL`.
#'
#' @param grid.resolution Integer giving the number of equally spaced points to
#' use for the continuous variables listed in `pred.var` when
#' `pred.grid` is not supplied. If left `NULL`, it will default to
#' the minimum between `51` and the number of unique data points for each
#' of the continuous independent variables listed in `pred.var`.
#'
#' @param ice Logical indicating whether or not to compute individual
#' conditional expectation (ICE) curves. Default is `FALSE`. See
#' Goldstein et al. (2014) for details.
#'
#' @param center Logical indicating whether or not to produce centered ICE
#' curves (c-ICE curves). Only used when `ice = TRUE`. Default is
#' `FALSE`. See Goldstein et al. (2014) for details.
#'
#' @param approx Logical indicating whether or not to compute a faster, but
#' approximate, marginal effect plot (similar in spirit to the
#' **plotmo** package). If `TRUE`, then `partial()` will compute
#' predictions across the predictors specified in `pred.var` while holding
#' the other predictors constant (a "poor man's partial dependence" function as
#' Stephen Milborrow, the author of **plotmo**, puts it).
#' Default is `FALSE`. Note this works with `ice = TRUE` as well.
#' WARNING: This option is currently experimental. Use at your own risk. It is
#' possible (and arguably safer) to do this manually by passing a specific
#' "exemplar" observation to the train argument and specifying `pred.grid`
#' manually.
#'
#' @param quantiles Logical indicating whether or not to use the sample
#' quantiles of the continuous predictors listed in `pred.var`. If
#' `quantiles = TRUE` and `grid.resolution = NULL` the sample
#' quantiles will be used to generate the grid of joint values for which the
#' partial dependence is computed.
#'
#' @param probs Numeric vector of probabilities with values in `[0, 1]`. (Values up
#' to 2e-14 outside that range are accepted and moved to the nearby endpoint.)
#' Default is `1:9/10` which corresponds to the deciles of the predictor
#' variables. These specify which quantiles to use for the continuous predictors
#' listed in `pred.var` when `quantiles = TRUE`.
#'
#' @param trim.outliers Logical indicating whether or not to trim off outliers
#' from the continuous predictors listed in `pred.var` (using the simple
#' boxplot method) before generating the grid of joint values for which the
#' partial dependence is computed. Default is `FALSE`.
#'
#' @param type Character string specifying the type of supervised learning.
#' Current options are `"auto"`, `"regression"` or
#' `"classification"`. If `type = "auto"` then `partial` will try
#' to extract the necessary information from `object`.
#'
#' @param inv.link Function specifying the transformation to be applied to the
#' predictions before the partial dependence function is computed
#' (experimental). Default is `NULL` (i.e., no transformation). This option
#' is intended to be used for models that allow for non-Gaussian response
#' variables (e.g., counts). For these models, predictions are not typically
#' returned on the original response scale by default. For example, Poisson GBMs
#' typically return predictions on the log scale. In this case setting
#' `inv.link = exp` will return the partial dependence function on the
#' response (i.e., raw count) scale.
#'
#' @param which.class Integer specifying which column of the matrix of predicted
#' probabilities to use as the "focus" class. Default is to use the first class.
#' Only used for classification problems (i.e., when
#' `type = "classification"`).
#'
#' @param prob Logical indicating whether or not partial dependence for
#' classification problems should be returned on the probability scale, rather
#' than the centered logit. If `FALSE`, the partial dependence function is
#' on a scale similar to the logit. Default is `FALSE`.
#'
#' @param recursive Logical indicating whether or not to use the weighted tree
#' traversal method described in Friedman (2001). This only applies to objects
#' that inherit from class `"gbm"`. Default is `TRUE` which is much
#' faster than the exact brute force approach used for all other models. (Based
#' on the C++ code behind [gbm::plot.gbm()].)
#'
#' @param plot Logical indicating whether to return a data frame containing the
#' partial dependence values (`FALSE`) or plot the partial dependence
#' function directly (`TRUE`). Default is `FALSE`. See
#' [plotPartial()] for plotting details.
#'
#' @param plot.engine Character string specifying which plotting engine to use
#' whenever `plot = TRUE`. Options include `"tinyplot"` (default;
#' lightweight base R graphics via the
#' [tinyplot](https://grantmcdermott.com/tinyplot/) package) or
#' `"lattice"`.
#'
#' @param smooth Logical indicating whether or not to overlay a LOESS smooth.
#' Default is `FALSE`.
#'
#' @param rug Logical indicating whether or not to include a rug display on the
#' predictor axes. The tick marks indicate the min/max and deciles of the
#' predictor distributions. This helps reduce the risk of interpreting the
#' partial dependence plot outside the region of the data (i.e., extrapolating).
#' Only used when `plot = TRUE`. Default is `FALSE`.
#'
#' @param levelplot Logical indicating whether or not to use a false color level
#' plot (`TRUE`) or a 3-D surface (`FALSE`). Default is `TRUE`.
#'
#' @param contour Logical indicating whether or not to add contour lines to the
#' level plot. Only used when `levelplot = TRUE`. Default is `FALSE`.
#'
#' @param contour.color Character string specifying the color to use for the
#' contour lines when `contour = TRUE`. Default is `"white"`.
#'
#' @param alpha Numeric value in `[0, 1]` specifying the opacity alpha (
#' most useful when plotting ICE/c-ICE curves). Default is 1 (i.e., no
#' transparency). In fact, this option only affects ICE/c-ICE curves and level
#' plots.
#'
#' @param chull Logical indicating whether or not to restrict the values of the
#' first two variables in `pred.var` to lie within the convex hull of their
#' training values; this affects `pred.grid`. This helps reduce the risk of
#' interpreting the partial dependence plot outside the region of the data
#' (i.e., extrapolating).Default is `FALSE`.
#'
#' @param train An optional data frame, matrix, or sparse matrix containing the
#' original training data. This may be required depending on the class of
#' `object`. For objects that do not store a copy of the original training
#' data, this argument is required. For reasons discussed below, it is good
#' practice to always specify this argument.
#'
#' @param cats Character string indicating which columns of `train` should
#' be treated as categorical variables. Only used when `train` inherits
#' from class `"matrix"` or `"dgCMatrix"`.
#'
#' @param check.class Logical indicating whether or not to make sure each column
#' in `pred.grid` has the correct class, levels, etc. Default is
#' `TRUE`.
#'
#' @param batch.size Optional positive integer specifying the (approximate)
#' maximum number of rows to score per call to [stats::predict()]. By
#' default (`batch.size = NULL`), `partial()` calls
#' [stats::predict()] once per grid point (i.e., `nrow(train)`
#' rows at a time). Specifying a larger batch size (e.g.,
#' `batch.size = 1e6`) stacks multiple grid points into a single call to
#' [stats::predict()], which is often substantially faster since it
#' avoids the per-call overhead of most prediction methods, at the cost of
#' additional memory. Requires the prediction function to return one prediction
#' per row of `newdata`, so it cannot be used with a `pred.fun` that
#' aggregates its own predictions. Prediction names are also ignored when
#' batching (i.e., `yhat.id` will always contain integer IDs). Ignored
#' whenever the recursive method is used (i.e., for `"gbm"` objects with
#' `recursive = TRUE`).
#'
#' @param progress Logical indicating whether or not to display a text-based
#' progress bar. Default is `FALSE`.
#'
#' @param parallel Logical indicating whether or not to run `partial` in
#' parallel using a backend provided by the `foreach` package. Default is
#' `FALSE`.
#'
#' @param paropts List containing additional options to be passed onto
#' [foreach::foreach()] when `parallel = TRUE`.
#'
#' @param frac Numeric value in (0, 1] specifying the fraction of the training
#' data to randomly sample (without replacement) before computing the partial
#' dependence function. Default is `1` (i.e., use all of the training
#' data). Mostly useful for reducing the number of ICE curves and/or
#' computation time; use [base::set.seed()] for reproducibility.
#' Ignored whenever the recursive method is used (i.e., for `"gbm"`
#' objects with `recursive = TRUE`).
#'
#' @param ... Additional optional arguments to be passed onto
#' [stats::predict()].
#'
#' @return By default, `partial` returns an object of class
#' `c("data.frame", "partial")`. If `ice = TRUE` and
#' `center = FALSE` then an object of class `c("data.frame", "ice")`
#' is returned. If `ice = TRUE` and `center = TRUE` then an object of
#' class `c("data.frame", "cice")` is returned. These three classes
#' determine the behavior of the plotting functions that are automatically
#' called whenever `plot = TRUE`. Specifically, when `plot = TRUE`
#' and `plot.engine = "tinyplot"` (the default), the plot is drawn
#' directly (as a side effect) and the data frame of partial dependence values
#' is returned invisibly. When `plot = TRUE` and
#' `plot.engine = "lattice"`, a `"trellis"` object is returned (see
#' **lattice** for details); the `"trellis"` object
#' will also include an additional attribute, `"partial.data"`, containing
#' the data displayed in the plot.
#'
#' @note
#' In some cases it is difficult for `partial` to extract the original
#' training data from `object`. In these cases an error message is
#' displayed requesting the user to supply the training data via the
#' `train` argument in the call to `partial`. In most cases where
#' `partial` can extract the required training data from `object`,
#' it is taken from the same environment in which `partial` is called.
#' Therefore, it is important to not change the training data used to construct
#' `object` before calling `partial`. This problem is completely
#' avoided when the training data are passed to the `train` argument in the
#' call to `partial`.
#'
#' It is recommended to call `partial` with `plot = FALSE` and store
#' the results. This allows for more flexible plotting, and the user will not
#' have to waste time calling `partial` again if the default plot is not
#' sufficient.
#'
#' It is possible to retrieve the last printed `"trellis"` object, such as
#' those produced by `plotPartial`, using `trellis.last.object()`.
#'
#' If `ice = TRUE` or the prediction function given to `pred.fun`
#' returns a prediction for each observation in `newdata`, then the result
#' will be a curve for each observation. These are called individual conditional
#' expectation (ICE) curves; see Goldstein et al. (2015) and
#' [ICEbox::ice()] for details.
#'
#' @references
#' J. H. Friedman. Greedy function approximation: A gradient boosting machine.
#' *Annals of Statistics*, **29**: 1189-1232, 2001.
#'
#' Goldstein, A., Kapelner, A., Bleich, J., and Pitkin, E., Peeking Inside the
#' Black Box: Visualizing Statistical Learning With Plots of Individual
#' Conditional Expectation. (2014) *Journal of Computational and Graphical
#' Statistics*, **24**(1): 44-65, 2015.
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
#' # The plot method produces lightweight base R graphics via the tinyplot
#' # package by default; set `lattice = TRUE` for lattice graphics (e.g., for
#' # 3-D surfaces or paneled three-predictor displays)
#' pd <- partial(boston.rf, pred.var = c("lstat", "rm"), grid.resolution = 40)
#' plot(pd, contour = TRUE)
#' plot(pd, lattice = TRUE, levelplot = FALSE, zlab = "cmedv", drape = TRUE,
#'      colorkey = FALSE, screen = list(z = -20, x = -60))
#'
#' #
#' # Individual conditional expectation (ICE) curves
#' #
#'
#' # Use partial to obtain ICE/c-ICE curves
#' rm.ice <- partial(boston.rf, pred.var = "rm", ice = TRUE)
#' plot(rm.ice, rug = TRUE, train = boston, alpha = 0.2)
#' plot(rm.ice, center = TRUE, alpha = 0.2, rug = TRUE, train = boston)
#'
#' #
#' # Classification example (requires randomForest package to run)
#' #
#'
#' # Fit a random forest to the Pima Indians diabetes data
#' data (pima)  # load the Pima Indians diabetes data
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
  plot = FALSE, plot.engine = c("tinyplot", "lattice"),
  smooth = FALSE, rug = FALSE, chull = FALSE, levelplot = TRUE,
  contour = FALSE, contour.color = "white",
  alpha = 1, train, cats = NULL, check.class = TRUE, batch.size = NULL,
  progress = FALSE, parallel = FALSE, paropts = NULL, frac = 1, ...
) {

  # Check batch size if given
  if (!is.null(batch.size) &&
      (!is.numeric(batch.size) || length(batch.size) != 1 || batch.size < 1)) {
    stop("`batch.size` should be a single positive number.")
  }

  # Check training data fraction
  if (!is.numeric(frac) || length(frac) != 1 || frac <= 0 || frac > 1) {
    stop("`frac` should be a single number in (0, 1].")
  }

  # Infer the predictors of interest whenever only `pred.grid` is supplied
  if (missing(pred.var) && !missing(pred.grid)) {
    if (!is.data.frame(pred.grid)) {
      stop("`pred.grid` should be a data frame.")
    }
    pred.var <- colnames(pred.grid)
  }

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

  # Throw an informative error if one of the predictor variables is called
  # "yhat"
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
      stop("`pred.grid` should be a data frame.")
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

  # Restrict grid to convex hull of first two columns
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
  if (isTRUE(approx)) {  # FIXME: What about when `rug/chull = TRUE`
    train <- exemplar(train, cats = cats)
  }

  # Randomly sample a fraction of the training data (mostly useful for
  # reducing the number of ICE curves and/or computation time); done after the
  # grid is constructed so the grid still spans the full training data
  if (frac < 1 && !isTRUE(approx)) {  # nothing to sample from an exemplar
    train <- train[sample(nrow(train), size = max(1, floor(frac * nrow(train)))),
                   , drop = FALSE]
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

    # Notify user that progress bars are not available for "gbm" objects when
    # recursive = TRUE
    if (isTRUE(progress)) {
      message("progress bars are not available when `recursive = TRUE`.")
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
             progress = progress, parallel = parallel, paropts = paropts,
             batch.size = batch.size, ...)
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
  if (plot) {
    plot.engine <- match.arg(plot.engine)
    if (plot.engine == "tinyplot") {  # drawn as a side effect
      if (inherits(pd.df, what = c("ice", "cice"))) {
        plot(pd.df, plot.pdp = TRUE, rug = rug, train = train, alpha = alpha)
      } else {
        plot(pd.df, smooth = smooth, rug = rug, train = train,
             contour = contour, contour.color = contour.color)
      }
      return(invisible(pd.df))
    }
    # Return a graph (i.e., a "trellis" object); the methods are called
    # directly (rather than via the deprecated plotPartial() generic) so no
    # deprecation warning is signaled
    res <- if (inherits(pd.df, what = c("ice", "cice"))) {
      plotPartial.ice(
        object = pd.df, plot.pdp = TRUE, rug = rug, train = train,
        alpha = alpha
      )
    } else {
      plotPartial.partial(pd.df, smooth = smooth, rug = rug, train = train,
                          levelplot = levelplot, contour = contour,
                          contour.color = contour.color,
                          screen = list(z = -30, x = -60))  # sensible default?
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
