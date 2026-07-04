# Exemplar observation

Construct a single "exemplar" record from a data frame. For now, all
numeric columns (including [Date](https://rdrr.io/r/base/Dates.html)
objects) are replaced with their corresponding median value and
non-numeric columns are replaced with their most frequent value.

## Usage

``` r
exemplar(object, ...)

# S3 method for class 'data.frame'
exemplar(object, ...)

# S3 method for class 'matrix'
exemplar(object, cats = NULL, ...)

# S3 method for class 'dgCMatrix'
exemplar(object, cats = NULL, ...)
```

## Arguments

- object:

  A data frame, matrix, or
  [`dgCMatrix`](https://rdrr.io/pkg/Matrix/man/dgCMatrix-class.html)
  (the latter two are supported by
  [`xgboost::xgboost()`](https://rdrr.io/pkg/xgboost/man/xgboost.html)).

- ...:

  Additional optional arguments (currently ignored).

- cats:

  Character string indicating which columns of `object` should be
  treated as categorical variables and summarized by their most frequent
  value (rather than a rounded median). Only used when `object` inherits
  from class `"matrix"` or `"dgCMatrix"`; data frames handle this
  automatically for factor and character columns. Default is `NULL`.

## Value

A data frame with the same number of columns as `object` and a single
row.

## Examples

``` r
set.seed(1554)  # for reproducibility
train <- data.frame(
  x = rnorm(100),
  y = sample(letters[1L:3L], size = 100, replace = TRUE,
             prob = c(0.1, 0.1, 0.8))
)
exemplar(train)
#>           x y
#> 1 0.1322968 c
```
