# Partial Dependence Functions

Compute partial dependence functions (i.e., marginal effects) for
various model fitting objects.

## Usage

``` r
partial(object, ...)

# Default S3 method
partial(
  object,
  pred.var,
  pred.grid,
  pred.fun = NULL,
  grid.resolution = NULL,
  ice = FALSE,
  center = FALSE,
  approx = FALSE,
  quantiles = FALSE,
  probs = 1:9/10,
  trim.outliers = FALSE,
  type = c("auto", "regression", "classification"),
  inv.link = NULL,
  which.class = 1L,
  prob = FALSE,
  recursive = TRUE,
  plot = FALSE,
  plot.engine = c("tinyplot", "lattice"),
  smooth = FALSE,
  rug = FALSE,
  chull = FALSE,
  levelplot = TRUE,
  contour = FALSE,
  contour.color = "white",
  alpha = 1,
  train,
  cats = NULL,
  check.class = TRUE,
  batch.size = NULL,
  progress = FALSE,
  parallel = FALSE,
  paropts = NULL,
  frac = 1,
  ...
)

# S3 method for class 'model_fit'
partial(object, ...)
```

## Arguments

- object:

  A fitted model object of appropriate class (e.g., `"gbm"`, `"lm"`,
  `"randomForest"`, `"train"`, etc.).

- ...:

  Additional optional arguments to be passed onto
  [`stats::predict()`](https://rdrr.io/r/stats/predict.html).

- pred.var:

  Character string giving the names of the predictor variables of
  interest. For reasons of computation/interpretation, this should
  include no more than three variables. Can be omitted whenever
  `pred.grid` is supplied, in which case it defaults to
  `colnames(pred.grid)`.

- pred.grid:

  Data frame containing the joint values of interest for the variables
  listed in `pred.var`.

- pred.fun:

  Optional prediction function that requires two arguments: `object` and
  `newdata`. If specified, then the function must return a single
  prediction or a vector of predictions (i.e., not a matrix or data
  frame). Default is `NULL`.

- grid.resolution:

  Integer giving the number of equally spaced points to use for the
  continuous variables listed in `pred.var` when `pred.grid` is not
  supplied. If left `NULL`, it will default to the minimum between `51`
  and the number of unique data points for each of the continuous
  independent variables listed in `pred.var`.

- ice:

  Logical indicating whether or not to compute individual conditional
  expectation (ICE) curves. Default is `FALSE`. See Goldstein et
  al. (2014) for details.

- center:

  Logical indicating whether or not to produce centered ICE curves
  (c-ICE curves). Only used when `ice = TRUE`. Default is `FALSE`. See
  Goldstein et al. (2014) for details.

- approx:

  Logical indicating whether or not to compute a faster, but
  approximate, marginal effect plot (similar in spirit to the **plotmo**
  package). If `TRUE`, then `partial()` will compute predictions across
  the predictors specified in `pred.var` while holding the other
  predictors constant (a "poor man's partial dependence" function as
  Stephen Milborrow, the author of **plotmo**, puts it). Default is
  `FALSE`. Note this works with `ice = TRUE` as well. WARNING: This
  option is currently experimental. Use at your own risk. It is possible
  (and arguably safer) to do this manually by passing a specific
  "exemplar" observation to the train argument and specifying
  `pred.grid` manually.

- quantiles:

  Logical indicating whether or not to use the sample quantiles of the
  continuous predictors listed in `pred.var`. If `quantiles = TRUE` and
  `grid.resolution = NULL` the sample quantiles will be used to generate
  the grid of joint values for which the partial dependence is computed.

- probs:

  Numeric vector of probabilities with values in `[0, 1]`. (Values up to
  2e-14 outside that range are accepted and moved to the nearby
  endpoint.) Default is `1:9/10` which corresponds to the deciles of the
  predictor variables. These specify which quantiles to use for the
  continuous predictors listed in `pred.var` when `quantiles = TRUE`.

- trim.outliers:

  Logical indicating whether or not to trim off outliers from the
  continuous predictors listed in `pred.var` (using the simple boxplot
  method) before generating the grid of joint values for which the
  partial dependence is computed. Default is `FALSE`.

- type:

  Character string specifying the type of supervised learning. Current
  options are `"auto"`, `"regression"` or `"classification"`. If
  `type = "auto"` then `partial` will try to extract the necessary
  information from `object`.

- inv.link:

  Function specifying the transformation to be applied to the
  predictions before the partial dependence function is computed
  (experimental). Default is `NULL` (i.e., no transformation). This
  option is intended to be used for models that allow for non-Gaussian
  response variables (e.g., counts). For these models, predictions are
  not typically returned on the original response scale by default. For
  example, Poisson GBMs typically return predictions on the log scale.
  In this case setting `inv.link = exp` will return the partial
  dependence function on the response (i.e., raw count) scale.

- which.class:

  Integer specifying which column of the matrix of predicted
  probabilities to use as the "focus" class. Default is to use the first
  class. Only used for classification problems (i.e., when
  `type = "classification"`).

- prob:

  Logical indicating whether or not partial dependence for
  classification problems should be returned on the probability scale,
  rather than the centered logit. If `FALSE`, the partial dependence
  function is on a scale similar to the logit. Default is `FALSE`.

- recursive:

  Logical indicating whether or not to use the weighted tree traversal
  method described in Friedman (2001). This only applies to objects that
  inherit from class `"gbm"`. Default is `TRUE` which is much faster
  than the exact brute force approach used for all other models. (Based
  on the C++ code behind
  [`gbm::plot.gbm()`](https://rdrr.io/pkg/gbm/man/plot.gbm.html).)

- plot:

  Logical indicating whether to return a data frame containing the
  partial dependence values (`FALSE`) or plot the partial dependence
  function directly (`TRUE`). Default is `FALSE`. See
  [`plotPartial()`](https://bgreenwell.github.io/pdp/reference/plotPartial.md)
  for plotting details.

- plot.engine:

  Character string specifying which plotting engine to use whenever
  `plot = TRUE`. Options include `"tinyplot"` (default; lightweight base
  R graphics via the [tinyplot](https://grantmcdermott.com/tinyplot/)
  package) or `"lattice"`.

- smooth:

  Logical indicating whether or not to overlay a LOESS smooth. Default
  is `FALSE`.

- rug:

  Logical indicating whether or not to include a rug display on the
  predictor axes. The tick marks indicate the min/max and deciles of the
  predictor distributions. This helps reduce the risk of interpreting
  the partial dependence plot outside the region of the data (i.e.,
  extrapolating). Only used when `plot = TRUE`. Default is `FALSE`.

- chull:

  Logical indicating whether or not to restrict the values of the first
  two variables in `pred.var` to lie within the convex hull of their
  training values; this affects `pred.grid`. This helps reduce the risk
  of interpreting the partial dependence plot outside the region of the
  data (i.e., extrapolating).Default is `FALSE`.

- levelplot:

  Logical indicating whether or not to use a false color level plot
  (`TRUE`) or a 3-D surface (`FALSE`). Default is `TRUE`.

- contour:

  Logical indicating whether or not to add contour lines to the level
  plot. Only used when `levelplot = TRUE`. Default is `FALSE`.

- contour.color:

  Character string specifying the color to use for the contour lines
  when `contour = TRUE`. Default is `"white"`.

- alpha:

  Numeric value in `[0, 1]` specifying the opacity alpha ( most useful
  when plotting ICE/c-ICE curves). Default is 1 (i.e., no transparency).
  In fact, this option only affects ICE/c-ICE curves and level plots.

- train:

  An optional data frame, matrix, or sparse matrix containing the
  original training data. This may be required depending on the class of
  `object`. For objects that do not store a copy of the original
  training data, this argument is required. For reasons discussed below,
  it is good practice to always specify this argument.

- cats:

  Character string indicating which columns of `train` should be treated
  as categorical variables. Only used when `train` inherits from class
  `"matrix"` or `"dgCMatrix"`.

- check.class:

  Logical indicating whether or not to make sure each column in
  `pred.grid` has the correct class, levels, etc. Default is `TRUE`.

- batch.size:

  Optional positive integer specifying the (approximate) maximum number
  of rows to score per call to
  [`stats::predict()`](https://rdrr.io/r/stats/predict.html). By default
  (`batch.size = NULL`), `partial()` calls
  [`stats::predict()`](https://rdrr.io/r/stats/predict.html) once per
  grid point (i.e., `nrow(train)` rows at a time). Specifying a larger
  batch size (e.g., `batch.size = 1e6`) stacks multiple grid points into
  a single call to
  [`stats::predict()`](https://rdrr.io/r/stats/predict.html), which is
  often substantially faster since it avoids the per-call overhead of
  most prediction methods, at the cost of additional memory. Requires
  the prediction function to return one prediction per row of `newdata`,
  so it cannot be used with a `pred.fun` that aggregates its own
  predictions. Prediction names are also ignored when batching (i.e.,
  `yhat.id` will always contain integer IDs). Ignored whenever the
  recursive method is used (i.e., for `"gbm"` objects with
  `recursive = TRUE`).

- progress:

  Logical indicating whether or not to display a text-based progress
  bar. Default is `FALSE`.

- parallel:

  Logical indicating whether or not to run `partial` in parallel using a
  backend provided by the `foreach` package. Default is `FALSE`.

- paropts:

  List containing additional options to be passed onto
  [`foreach::foreach()`](https://rdrr.io/pkg/foreach/man/foreach.html)
  when `parallel = TRUE`.

- frac:

  Numeric value in (0, 1\] specifying the fraction of the training data
  to randomly sample (without replacement) before computing the partial
  dependence function. Default is `1` (i.e., use all of the training
  data). Mostly useful for reducing the number of ICE curves and/or
  computation time; use
  [`base::set.seed()`](https://rdrr.io/r/base/Random.html) for
  reproducibility. Ignored whenever the recursive method is used (i.e.,
  for `"gbm"` objects with `recursive = TRUE`).

## Value

By default, `partial` returns an object of class
`c("data.frame", "partial")`. If `ice = TRUE` and `center = FALSE` then
an object of class `c("data.frame", "ice")` is returned. If `ice = TRUE`
and `center = TRUE` then an object of class `c("data.frame", "cice")` is
returned. These three classes determine the behavior of the plotting
functions that are automatically called whenever `plot = TRUE`.
Specifically, when `plot = TRUE` and `plot.engine = "tinyplot"` (the
default), the plot is drawn directly (as a side effect) and the data
frame of partial dependence values is returned invisibly. When
`plot = TRUE` and `plot.engine = "lattice"`, a `"trellis"` object is
returned (see **lattice** for details); the `"trellis"` object will also
include an additional attribute, `"partial.data"`, containing the data
displayed in the plot.

## Note

In some cases it is difficult for `partial` to extract the original
training data from `object`. In these cases an error message is
displayed requesting the user to supply the training data via the
`train` argument in the call to `partial`. In most cases where `partial`
can extract the required training data from `object`, it is taken from
the same environment in which `partial` is called. Therefore, it is
important to not change the training data used to construct `object`
before calling `partial`. This problem is completely avoided when the
training data are passed to the `train` argument in the call to
`partial`.

It is recommended to call `partial` with `plot = FALSE` and store the
results. This allows for more flexible plotting, and the user will not
have to waste time calling `partial` again if the default plot is not
sufficient.

It is possible to retrieve the last printed `"trellis"` object, such as
those produced by `plotPartial`, using
[`trellis.last.object()`](https://bgreenwell.github.io/pdp/reference/trellis.last.object.md).

If `ice = TRUE` or the prediction function given to `pred.fun` returns a
prediction for each observation in `newdata`, then the result will be a
curve for each observation. These are called individual conditional
expectation (ICE) curves; see Goldstein et al. (2015) and
[`ICEbox::ice()`](https://rdrr.io/pkg/ICEbox/man/ice.html) for details.

## References

J. H. Friedman. Greedy function approximation: A gradient boosting
machine. *Annals of Statistics*, **29**: 1189-1232, 2001.

Goldstein, A., Kapelner, A., Bleich, J., and Pitkin, E., Peeking Inside
the Black Box: Visualizing Statistical Learning With Plots of Individual
Conditional Expectation. (2014) *Journal of Computational and Graphical
Statistics*, **24**(1): 44-65, 2015.

## Examples

``` r
if (FALSE) { # \dontrun{
#
# Regression example (requires randomForest package to run)
#

# Fit a random forest to the boston housing data
library(randomForest)
data (boston)  # load the boston housing data
set.seed(101)  # for reproducibility
boston.rf <- randomForest(cmedv ~ ., data = boston)

# Using randomForest's partialPlot function
partialPlot(boston.rf, pred.data = boston, x.var = "lstat")

# Using pdp's partial function
head(partial(boston.rf, pred.var = "lstat"))  # returns a data frame
partial(boston.rf, pred.var = "lstat", plot = TRUE, rug = TRUE)

# The partial function allows for multiple predictors
partial(boston.rf, pred.var = c("lstat", "rm"), grid.resolution = 40,
        plot = TRUE, chull = TRUE, progress = TRUE)

# The plot method produces lightweight base R graphics via the tinyplot
# package by default; set `lattice = TRUE` for lattice graphics (e.g., for
# 3-D surfaces or paneled three-predictor displays)
pd <- partial(boston.rf, pred.var = c("lstat", "rm"), grid.resolution = 40)
plot(pd, contour = TRUE)
plot(pd, lattice = TRUE, levelplot = FALSE, zlab = "cmedv", drape = TRUE,
     colorkey = FALSE, screen = list(z = -20, x = -60))

#
# Individual conditional expectation (ICE) curves
#

# Use partial to obtain ICE/c-ICE curves
rm.ice <- partial(boston.rf, pred.var = "rm", ice = TRUE)
plot(rm.ice, rug = TRUE, train = boston, alpha = 0.2)
plot(rm.ice, center = TRUE, alpha = 0.2, rug = TRUE, train = boston)

#
# Classification example (requires randomForest package to run)
#

# Fit a random forest to the Pima Indians diabetes data
data (pima)  # load the Pima Indians diabetes data
set.seed(102)  # for reproducibility
pima.rf <- randomForest(diabetes ~ ., data = pima, na.action = na.omit)

# Partial dependence of positive test result on glucose (default logit scale)
partial(pima.rf, pred.var = "glucose", plot = TRUE, chull = TRUE,
        progress = TRUE)

# Partial dependence of positive test result on glucose (probability scale)
partial(pima.rf, pred.var = "glucose", prob = TRUE, plot = TRUE,
        chull = TRUE, progress = TRUE)
} # }
```
