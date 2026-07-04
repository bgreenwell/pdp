# pdp: A general framework for constructing partial dependence (i.e., marginal effect) plots from various types of machine learning models in R.

Partial dependence plots (PDPs) help visualize the relationship between
a subset of the features (typically 1-3) and the response while
accounting for the average effect of the other predictors in the model.
They are particularly effective with black box models like random
forests and support vector machines.

## Details

The development version can be found on GitHub:
<https://github.com/bgreenwell/pdp>. As of right now, pdp exports the
following functions:

- [`partial()`](https://bgreenwell.github.io/pdp/reference/partial.md) -
  construct partial dependence functions (i.e., objects of class
  `"partial"`) from various fitted model objects;

- [`plot()`](https://rdrr.io/r/graphics/plot.default.html) - plot
  partial dependence functions (i.e., objects of class `"partial"`)
  using lightweight base R graphics via
  [`tinyplot::tinyplot()`](https://grantmcdermott.com/tinyplot/man/tinyplot.html)
  (or **lattice** graphics whenever `lattice = TRUE`);

- [`exemplar()`](https://bgreenwell.github.io/pdp/reference/exemplar.md) -
  construct a single "exemplar" record from a data frame.

## See also

Useful links:

- <https://github.com/bgreenwell/pdp>

- <https://bgreenwell.github.io/pdp/>

- <https://bgreenwell.r-universe.dev/pdp>

- Report bugs at <https://github.com/bgreenwell/pdp/issues>

## Author

**Maintainer**: Brandon M. Greenwell <greenwell.brandon@gmail.com>
([ORCID](https://orcid.org/0000-0002-8120-0084))
