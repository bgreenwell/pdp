# Plotting Partial Dependence Functions

Plot partial dependence functions (i.e., marginal effects) and
individual conditional expectation (ICE) curves using lightweight base R
graphics via the [tinyplot](https://grantmcdermott.com/tinyplot/)
package.

## Usage

``` r
# S3 method for class 'partial'
plot(
  x,
  center = FALSE,
  plot.pdp = TRUE,
  pdp.col = "red2",
  pdp.lwd = 2,
  pdp.lty = 1,
  smooth = FALSE,
  rug = FALSE,
  contour = FALSE,
  contour.color = "white",
  train = NULL,
  alpha = 1,
  legend.title = "yhat",
  ...
)

# S3 method for class 'ice'
plot(
  x,
  center = FALSE,
  plot.pdp = TRUE,
  pdp.col = "red2",
  pdp.lwd = 2,
  pdp.lty = 1,
  rug = FALSE,
  train = NULL,
  alpha = 1,
  ...
)

# S3 method for class 'cice'
plot(
  x,
  plot.pdp = TRUE,
  pdp.col = "red2",
  pdp.lwd = 2,
  pdp.lty = 1,
  rug = FALSE,
  train = NULL,
  alpha = 1,
  ...
)
```

## Arguments

- x:

  An object that inherits from class `"partial"`, `"ice"`, or `"cice"`;
  typically the result of a call to
  [`partial`](https://bgreenwell.github.io/pdp/reference/partial.md).

- center:

  Logical indicating whether or not to produce centered ICE curves
  (c-ICE curves). Only useful when `x` represents a set of ICE curves;
  see [`partial`](https://bgreenwell.github.io/pdp/reference/partial.md)
  for details. Default is `FALSE`.

- plot.pdp:

  Logical indicating whether or not to plot the partial dependence
  function on top of the ICE curves. Default is `TRUE`.

- pdp.col:

  Character string specifying the color to use for the partial
  dependence function when `plot.pdp = TRUE`. Default is `"red2"`.

- pdp.lwd:

  Integer specifying the line width to use for the partial dependence
  function when `plot.pdp = TRUE`. Default is `2`. See
  [`par`](https://rdrr.io/r/graphics/par.html) for more details.

- pdp.lty:

  Integer or character string specifying the line type to use for the
  partial dependence function when `plot.pdp = TRUE`. Default is `1`.
  See [`par`](https://rdrr.io/r/graphics/par.html) for more details.

- smooth:

  Logical indicating whether or not to overlay a LOESS smooth. Default
  is `FALSE`.

- rug:

  Logical indicating whether or not to include rug marks (i.e., the
  min/max and deciles of the predictor distribution) on the predictor
  axes. Not currently supported for faceted displays (i.e., partial
  dependence of two predictors where at least one is a factor). Default
  is `FALSE`.

- contour:

  Logical indicating whether or not to add contour lines to the false
  color level plot used for two continuous predictors. Default is
  `FALSE`.

- contour.color:

  Character string specifying the color to use for the contour lines
  when `contour = TRUE`. Default is `"white"`.

- train:

  Data frame containing the original training data. Only required if
  `rug = TRUE`.

- alpha:

  Numeric value in `[0, 1]` specifying the opacity alpha; most useful
  when plotting ICE/c-ICE curves. Default is `1` (i.e., no
  transparency).

- legend.title:

  Character string specifying the text for the legend title of the false
  color level plot used for two continuous predictors. Default is
  `"yhat"`.

- ...:

  Additional optional arguments to be passed on to
  [`tinyplot`](https://grantmcdermott.com/tinyplot/man/tinyplot.html)
  (e.g., `palette`, `main`, or `theme`).

## Value

Draws a plot as a side effect and (invisibly) returns `x`.

## Examples

``` r
if (FALSE) { # \dontrun{
#
# Regression example (requires randomForest package to run)
#

# Fit a random forest to the Boston housing data
library(randomForest)
data (boston)  # load the boston housing data
set.seed(101)  # for reproducibility
boston.rf <- randomForest(cmedv ~ ., data = boston)

# Partial dependence of cmedv on lstat
pd <- partial(boston.rf, pred.var = "lstat")
plot(pd, rug = TRUE, train = boston)

# Partial dependence of cmedv on lstat and rm
pd2 <- partial(boston.rf, pred.var = c("lstat", "rm"), chull = TRUE)
plot(pd2, contour = TRUE)

# ICE and c-ICE curves
rm.ice <- partial(boston.rf, pred.var = "rm", ice = TRUE)
plot(rm.ice, rug = TRUE, train = boston, alpha = 0.2)
plot(rm.ice, center = TRUE, alpha = 0.2)
} # }
```
