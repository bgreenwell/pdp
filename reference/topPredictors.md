# Extract Most "Important" Predictors (Experimental)

Extract the most "important" predictors for regression and
classification models.

## Usage

``` r
topPredictors(object, n = 1L, ...)

# Default S3 method
topPredictors(object, n = 1L, ...)

# S3 method for class 'train'
topPredictors(object, n = 1L, ...)
```

## Arguments

- object:

  A fitted model object of appropriate class (e.g., `"gbm"`, `"lm"`,
  `"randomForest"`, etc.).

- n:

  Integer specifying the number of predictors to return. Default is `1`
  meaning return the single most important predictor.

- ...:

  Additional optional arguments to be passed onto
  [`varImp`](https://rdrr.io/pkg/caret/man/varImp.html).

## Details

This function uses the generic function
[`varImp`](https://rdrr.io/pkg/caret/man/varImp.html) to calculate
variable importance scores for each predictor. After that, they are
sorted at the names of the `n` highest scoring predictors are returned.

## Examples

``` r
if (FALSE) { # \dontrun{
#
# Regression example (requires randomForest package to run)
#

# Load required packages
library(randomForest)

# Fit a random forest to the mtcars dataset
data(mtcars, package = "datasets")
set.seed(101)
mtcars.rf <- randomForest(mpg ~ ., data = mtcars, mtry = 5, importance = TRUE)

# Top four predictors
top4 <- topPredictors(mtcars.rf, n = 4)

# Construct partial dependence functions for top four predictors
pd <- NULL
for (i in top4) {
  tmp <- partial(mtcars.rf, pred.var = i)
  names(tmp) <- c("x", "y")
  pd <- rbind(pd,  cbind(tmp, predictor = i))
}

# Display partial dependence functions
tinyplot::tinyplot(y ~ x, facet = ~ predictor, data = pd, type = "l",
                   facet.args = list(free = TRUE), ylab = "mpg")

} # }
```
