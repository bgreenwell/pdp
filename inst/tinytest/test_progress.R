# Load required packages
library(Matrix)

# Load Friedman benchmark data
friedman1 <- readRDS("friedman.rds")$friedman1
X1 <- data.matrix(friedman1[, paste0("x.", 1L:10L)])

# Tests progress bar with XGBoost models
if (require(xgboost, quietly = TRUE)) {

  # Regression model -----------------------------------------------------------

  # Fit regression model
  fit1 <- xgboost(
    data = X1,
    label = friedman1$y,
    params = list(
      max_depth = 2,
      eta = 0.1,
      objective = "reg:squarederror",  # formerly "reg:linear"
      eval_metric = "rmse"
    ),
    nrounds = 827,
    verbose = 0,
    save_period = NULL
  )

  # Compute partial dependence with progress bar
  grid_size <- 1000L
  pd <- partial(fit1, pred.var = "x.3", train = X1, progress = "progress",
                grid.resolution = grid_size)

  # Expectations
  expect_true(nrow(pd) == grid_size)
  expect_true(inherits(pd, what = "partial"))

}
