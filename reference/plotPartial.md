# Plotting Partial Dependence Functions (deprecated)

Plots partial dependence functions (i.e., marginal effects) using
**lattice** graphics.

## Usage

``` r
plotPartial(object, ...)

# S3 method for class 'ice'
plotPartial(
  object,
  center = FALSE,
  plot.pdp = TRUE,
  pdp.col = "red2",
  pdp.lwd = 2,
  pdp.lty = 1,
  rug = FALSE,
  train = NULL,
  ...
)

# S3 method for class 'cice'
plotPartial(
  object,
  plot.pdp = TRUE,
  pdp.col = "red2",
  pdp.lwd = 2,
  pdp.lty = 1,
  rug = FALSE,
  train = NULL,
  ...
)

# S3 method for class 'partial'
plotPartial(
  object,
  center = FALSE,
  plot.pdp = TRUE,
  pdp.col = "red2",
  pdp.lwd = 2,
  pdp.lty = 1,
  smooth = FALSE,
  rug = FALSE,
  chull = FALSE,
  levelplot = TRUE,
  contour = FALSE,
  contour.color = "white",
  col.regions = NULL,
  number = 4,
  overlap = 0.1,
  train = NULL,
  ...
)
```

## Arguments

- object:

  An object that inherits from the `"partial"` class.

- ...:

  Additional optional arguments to be passed onto `dotplot`,
  `levelplot`, `xyplot`, or `wireframe`.

- center:

  Logical indicating whether or not to produce centered ICE curves
  (c-ICE curves). Only useful when `object` represents a set of ICE
  curves; see
  [`partial()`](https://bgreenwell.github.io/pdp/reference/partial.md)
  for details. Default is `FALSE`.

- plot.pdp:

  Logical indicating whether or not to plot the partial dependence
  function on top of the ICE curves. Default is `TRUE`.

- pdp.col:

  Character string specifying the color to use for the partial
  dependence function when `plot.pdp = TRUE`. Default is `"red"`.

- pdp.lwd:

  Integer specifying the line width to use for the partial dependence
  function when `plot.pdp = TRUE`. Default is `1`. See
  [`graphics::par()`](https://rdrr.io/r/graphics/par.html) for more
  details.

- pdp.lty:

  Integer or character string specifying the line type to use for the
  partial dependence function when `plot.pdp = TRUE`. Default is `1`.
  See [`graphics::par()`](https://rdrr.io/r/graphics/par.html) for more
  details.

- rug:

  Logical indicating whether or not to include rug marks on the
  predictor axes. Default is `FALSE`.

- train:

  Data frame containing the original training data. Only required if
  `rug = TRUE` or `chull = TRUE`.

- smooth:

  Logical indicating whether or not to overlay a LOESS smooth. Default
  is `FALSE`.

- chull:

  Logical indicating whether or not to restrict the first two variables
  in `pred.var` to lie within the convex hull of their training values;
  this affects `pred.grid`. Default is `FALSE`.

- levelplot:

  Logical indicating whether or not to use a false color level plot
  (`TRUE`) or a 3-D surface (`FALSE`). Default is `TRUE`.

- contour:

  Logical indicating whether or not to add contour lines to the level
  plot. Only used when `levelplot = TRUE`. Default is `FALSE`.

- contour.color:

  Character string specifying the color to use for the contour lines
  when `contour = TRUE`. Default is `"white"`.

- col.regions:

  Vector of colors to be passed on to
  [`lattice::levelplot()`](https://rdrr.io/pkg/lattice/man/levelplot.html)'s
  `col.region` argument. Defaults to `grDevices::hcl.colors(100)` (which
  is the same viridis color palette used in the past).

- number:

  Integer specifying the number of conditional intervals to use for the
  continuous panel variables. See
  [`graphics::co.intervals()`](https://rdrr.io/r/graphics/coplot.html)
  and
  [`lattice::equal.count()`](https://rdrr.io/pkg/lattice/man/shingles.html)
  for further details.

- overlap:

  The fraction of overlap of the conditioning variables. See
  [`graphics::co.intervals()`](https://rdrr.io/r/graphics/coplot.html)
  and
  [`lattice::equal.count()`](https://rdrr.io/pkg/lattice/man/shingles.html)
  for further details.

## Details

**Deprecated:** `plotPartial()` is deprecated and will be removed in a
future release; please use `plot(..., lattice = TRUE)` instead, which
produces the same displays through a single interface (see
[`plot.partial()`](https://bgreenwell.github.io/pdp/reference/plot.partial.md)
for details).

## Examples

``` r
if (FALSE) { # \dontrun{
#
# Regression example (requires randomForest package to run)
#

# Load required packages
library(gridExtra)  # for `grid.arrange()`
library(magrittr)  # for forward pipe operator `%>%`
library(randomForest)

# Fit a random forest to the Boston housing data
data (boston)  # load the boston housing data
set.seed(101)  # for reproducibility
boston.rf <- randomForest(cmedv ~ ., data = boston)

# Partial dependence of cmedv on lstat
boston.rf %>%
  partial(pred.var = "lstat") %>%
  plotPartial(rug = TRUE, train = boston)

# Partial dependence of cmedv on lstat and rm
boston.rf %>%
  partial(pred.var = c("lstat", "rm"), chull = TRUE, progress = TRUE) %>%
  plotPartial(contour = TRUE, legend.title = "rm")

# ICE curves and c-ICE curves
age.ice <- partial(boston.rf, pred.var = "lstat", ice = TRUE)
p1 <- plotPartial(age.ice, alpha = 0.1)
p2 <- plotPartial(age.ice, center = TRUE, alpha = 0.1)
grid.arrange(p1, p2, ncol = 2)
} # }
```
