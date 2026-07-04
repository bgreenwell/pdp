# Plotting Partial Dependence Functions

Plot partial dependence functions (i.e., marginal effects) and
individual conditional expectation (ICE) curves using lightweight base R
graphics via the [tinyplot](https://grantmcdermott.com/tinyplot/)
package, or **lattice** graphics whenever `lattice = TRUE`.

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
  color.by = NULL,
  bars = FALSE,
  legend.title = "yhat",
  lattice = FALSE,
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
  color.by = NULL,
  lattice = FALSE,
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
  color.by = NULL,
  lattice = FALSE,
  ...
)
```

## Arguments

- x:

  An object that inherits from class `"partial"`, `"ice"`, or `"cice"`;
  typically the result of a call to
  [`partial()`](https://bgreenwell.github.io/pdp/reference/partial.md).

- center:

  Logical indicating whether or not to produce centered ICE curves
  (c-ICE curves). Only useful when `x` represents a set of ICE curves;
  see
  [`partial()`](https://bgreenwell.github.io/pdp/reference/partial.md)
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
  [`graphics::par()`](https://rdrr.io/r/graphics/par.html) for more
  details.

- pdp.lty:

  Integer or character string specifying the line type to use for the
  partial dependence function when `plot.pdp = TRUE`. Default is `1`.
  See [`graphics::par()`](https://rdrr.io/r/graphics/par.html) for more
  details.

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

- color.by:

  Optional character string specifying the name of a column in `train`
  used to color the individual ICE/c-ICE curves; continuous variables
  are binned into (at most) five groups. Requires `train` and assumes
  the curve IDs (i.e., the `yhat.id` column) correspond to the rows of
  `train` (which is the case whenever `ice = TRUE`). Default is `NULL`.

- bars:

  Logical indicating whether or not to use a bar plot (rather than
  points) whenever the predictor of interest is a factor. Default is
  `FALSE`.

- legend.title:

  Character string specifying the text for the legend title of the false
  color level plot used for two continuous predictors. Default is
  `"yhat"`.

- lattice:

  Logical indicating whether or not to draw the display using
  **lattice** graphics instead of tinyplot/base graphics. The lattice
  engine additionally supports three-predictor (paneled) displays and
  3-D surfaces; see Details. Default is `FALSE`.

- ...:

  Additional optional arguments to be passed on to
  [`tinyplot::tinyplot()`](https://grantmcdermott.com/tinyplot/man/tinyplot.html)
  (e.g., `palette`, `main`, or `theme`) or, whenever `lattice = TRUE`,
  to the underlying lattice display (see Details).

## Value

Draws a plot as a side effect. The tinyplot engine (invisibly) returns
`x`; the lattice engine (`lattice = TRUE`) (invisibly) returns the
`"trellis"` object, which can be captured for further manipulation
(e.g., arranging multiple displays with
[`gridExtra::grid.arrange()`](https://rdrr.io/pkg/gridExtra/man/arrangeGrob.html)).

## Details

When `lattice = TRUE`, the display is constructed with **lattice**
graphics (this subsumes the now-deprecated
[`plotPartial()`](https://bgreenwell.github.io/pdp/reference/plotPartial.md)
interface). In that case, additional lattice-specific options can be
supplied via `...`:

- `levelplot` - use a false color level plot (`TRUE`; default) or a 3-D
  [`lattice::wireframe()`](https://rdrr.io/pkg/lattice/man/cloud.html)
  surface (`FALSE`) for two continuous predictors;

- `chull` - overlay the convex hull of the first two predictors
  (requires `train`);

- `col.regions` - color palette for level/wireframe plots;

- `number`/`overlap` - number of conditioning intervals (and their
  fraction of overlap) used to panel a third (continuous) predictor;

- any other argument accepted by
  [`lattice::xyplot()`](https://rdrr.io/pkg/lattice/man/xyplot.html),
  [`lattice::levelplot()`](https://rdrr.io/pkg/lattice/man/levelplot.html),
  [`lattice::wireframe()`](https://rdrr.io/pkg/lattice/man/cloud.html),
  or [`lattice::dotplot()`](https://rdrr.io/pkg/lattice/man/xyplot.html)
  (e.g., `screen` or `drape`). The tinyplot-specific arguments
  `color.by`, `bars`, and `legend.title` are ignored when
  `lattice = TRUE`.

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
