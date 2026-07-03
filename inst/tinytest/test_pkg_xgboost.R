if (!at_home()) {
  exit_file("Skipping tests that run only at home.")
}

# Load required packages
library(Matrix)

# Load Friedman benchmark data
friedman1 <- readRDS("friedman.rds")$friedman1
friedman2 <- readRDS("friedman.rds")$friedman2
X1 <- data.matrix(friedman1[, paste0("x.", 1L:10L)])
X1.dgCMatrix <- as(X1, "dgCMatrix")
X2 <- data.matrix(friedman2[, paste0("x.", 1L:10L)])

# For tuning, I just used xgbshap::autoxgb()

# Tests for package e1071
if (require(xgboost, quietly = TRUE)) {

  # Regression model -----------------------------------------------------------

  # Fit regression model
  fit1 <- xgboost(
    x = X1,
    y = friedman1$y,
    max_depth = 2,
    learning_rate = 0.1,
    objective = "reg:squarederror",  # formerly "reg:linear"
    eval_metric = "rmse",
    nrounds = 827
  )

  # Compute partial dependence, ICE, etc. for x.3
  pd1 <- partial(fit1, pred.var = "x.3", train = X1)
  ice1 <- partial(fit1, pred.var = "x.3", ice = TRUE, train = X1)

  # Expectations
  pdp1 <- partial(fit1, pred.var = "x.3", train = X1, plot = TRUE)
  pdp2 <- partial(fit1, pred.var = "x.3", train = X1, plot = TRUE,
                  plot.engine = "tinyplot")  # draws plot; returns data invisibly
  expect_true(inherits(pdp1, what = "trellis"))
  expect_true(inherits(pdp2, what = "partial"))
  expect_error(partial(fit1, pred.var = "x.3"))
  expect_true(inherits(pd1, what = "partial"))
  expect_true(inherits(ice1, what = "ice"))


  # Poisson model w/ log link --------------------------------------------------

  # Fit Poisson regression model for number of carburetors in the mtcars data
  # set (here, the response is a count)
  fit2 <- xgboost(
    x = data.matrix(mtcars[, -11L]),
    y = mtcars[, 11],
    objective = "count:poisson",
    learning_rate = 0.1,
    nrounds = 273
  )

  # FIXME: `predict.xgb.Booster()` now returns predictions on the original
  # response scale. To get the link scale, set `outputmargin = TRUE` in the call
  # to `predict.xgb.Booster()`. This can be passed via the `...` argument in the
  # call to `partial()`.

  # Passing a function to `inv.link` vs. not
  pd2.1 <- partial(fit2, pred.var = "mpg", train = mtcars[, -11L],
                   outputmargin = TRUE)
  pd2.2 <- partial(fit2, pred.var = "mpg", train = mtcars[, -11L],
                   outputmargin = FALSE)
  pd2.3 <- partial(fit2, pred.var = "mpg", inv.link = exp,
                   train = mtcars[, -11L], outputmargin = TRUE)
  pd2.4 <- partial(fit2, pred.var = "mpg", inv.link = exp,
                   train = mtcars[, -11L], outputmargin = TRUE, ice = TRUE)
  plot(pd2.1)
  plot(pd2.2)
  plot(pd2.3)
  plot(pd2.4)

  # Expectations
  expect_true(inherits(pd2.1, what = "partial"))
  expect_true(inherits(pd2.2, what = "partial"))
  expect_true(inherits(pd2.3, what = "partial"))


  # Classification model -------------------------------------------------------

  # Fit classification model
  fit3 <- xgboost(
    x = X2,
    y = friedman2$y,
    max_depth = 25,
    learning_rate = 0.1,
    objective = "binary:logistic",
    eval_metric = "auc",
    nrounds = 200
  )

  # Compute partial dependence, ICE, etc. for x.3
  pd3 <- partial(fit3, pred.var = "x.3", train = X2)
  pd3.prob <- partial(fit3, pred.var = "x.3", prob = TRUE, train = X2)
  ice3 <- partial(fit3, pred.var = "x.3", ice = TRUE, train = X2)
  ice3.prob <- partial(fit3, pred.var = "x.3", ice = TRUE, prob = TRUE,
                       train = X2)

  # Expectations: partial()
  expect_true(inherits(pd3, what = "partial"))
  expect_true(inherits(pd3.prob, what = "partial"))
  expect_true(inherits(ice3, what = "ice"))
  expect_true(inherits(ice3.prob, what = "ice"))

}
