if (require(xgboost, quietly = TRUE) && require(ggplot2, quietly = TRUE) &&
    require(ggplot2, quietly = TRUE)) {

  # Load the data
  pima <- pdp::pima  # xgboost can handle missing values, so no need for na.omit()

  # Set up training data
  X <- subset(pima, select = -diabetes)
  X.matrix <- data.matrix(X)
  X.dgCMatrix <- as(data.matrix(X), "dgCMatrix")
  y <- ifelse(pima$diabetes == "pos", 1, 0)

  # List of parameters for XGBoost
  plist <- list(
    max_depth = 3,
    eta = 0.01,
    objective = "binary:logistic",
    eval_metric = "auc"
  )

  # Fit an XGBoost model with trainind data stored as a "matrix"
  set.seed(101)
  bst.matrix <- xgboost(data = X.matrix, label = y, params = plist,
                        nrounds = 100, save_period = NULL, verbose = 0)

  # Fit an XGBoost model with trainind data stored as a "dgCMatrix"
  set.seed(101)
  bst.dgCMatrix <- xgboost(data = X.dgCMatrix, label = y, params = plist,
                           nrounds = 100, save_period = NULL, verbose = 0)

  # Fit an XGBoost model with trainind data stored as an "xgb.DMatrix"
  set.seed(101)
  bst.xgb.DMatrix <- xgboost(data = xgb.DMatrix(data.matrix(X), label = y),
                             params = plist, nrounds = 100, save_period = NULL,
                             verbose = 0)
  # Matrix
  pds <- list(
    partial(bst.matrix, pred.var = "glucose", prob = TRUE, train = X),
    partial(bst.matrix, pred.var = "glucose", prob = TRUE, train = X.matrix),
    partial(bst.matrix, pred.var = "glucose", prob = TRUE, train = X.dgCMatrix),
    partial(bst.dgCMatrix, pred.var = "glucose", prob = TRUE, train = X),
    partial(bst.dgCMatrix, pred.var = "glucose", prob = TRUE, train = X.matrix),
    partial(bst.dgCMatrix, pred.var = "glucose", prob = TRUE, train = X.dgCMatrix),
    partial(bst.xgb.DMatrix, pred.var = "glucose", prob = TRUE, train = X),
    partial(bst.xgb.DMatrix, pred.var = "glucose", prob = TRUE, train = X.matrix),
    partial(bst.xgb.DMatrix, pred.var = "glucose", prob = TRUE, train = X.dgCMatrix)
  )

  # Basic expectation(s)
  expect_identical(dim(pds[[1L]]), c(51L, 2L))
  expect_identical(names(pds[[1L]]), c("glucose", "yhat"))
  expect_identical(pds[[1L]], target = pds[[2L]])
  expect_identical(pds[[1L]], target = pds[[3L]])
  expect_identical(pds[[1L]], target = pds[[4L]])
  expect_identical(pds[[1L]], target = pds[[5L]])
  expect_identical(pds[[1L]], target = pds[[6L]])
  expect_identical(pds[[1L]], target = pds[[7L]])
  expect_identical(pds[[1L]], target = pds[[8L]])
  expect_identical(pds[[1L]], target = pds[[9L]])

  # Approximate method should work with all types as well
  pd1 <- partial(bst.matrix, pred.var = "glucose", prob = TRUE,
                 train = X, approx = TRUE)
  pd2 <- partial(bst.matrix, pred.var = "glucose", prob = TRUE,
                 train = X.matrix, approx = TRUE)
  pd3 <- partial(bst.matrix, pred.var = "glucose", prob = TRUE,
                 train = X.dgCMatrix, approx = TRUE)
  expect_identical(pd1, target = pd2)
  expect_identical(pd1, target = pd3)

  # Display results side by side
  grid.arrange(plotPartial(pd1), plotPartial(pd2), plotPartial(pd3), nrow = 1)

  # Function to construct a PDP for glucose on the probability scale
  parDepPlot <- function(object, train, ...) {
    pd <- partial(object, pred.var = "glucose", prob = TRUE, train = train)
    label <- paste(deparse(substitute(object)), "with", deparse(substitute(train)))
    autoplot(pd, main = label) +
      theme_light()
  }

  # Try all nine combnations (should all look exactly the same!)
  grid.arrange(
    parDepPlot(bst.matrix, train = X),
    parDepPlot(bst.matrix, train = X.matrix),
    parDepPlot(bst.matrix, train = X.dgCMatrix),
    parDepPlot(bst.dgCMatrix, train = X),
    parDepPlot(bst.dgCMatrix, train = X.matrix),
    parDepPlot(bst.dgCMatrix, train = X.dgCMatrix),
    parDepPlot(bst.xgb.DMatrix, train = X),
    parDepPlot(bst.xgb.DMatrix, train = X.matrix),
    parDepPlot(bst.xgb.DMatrix, train = X.dgCMatrix),
    ncol = 3
  )

}
