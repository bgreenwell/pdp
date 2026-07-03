if (!at_home()) {
  exit_file("Skipping tests that run only at home.")
}

# Exits
if (!requireNamespace("e1071", quietly = TRUE)) {
  exit_file("Package e1071 missing")
}

# # Load required packages
# suppressMessages({
#   library(e1071)
# })

# Load Friedman benchmark data
friedman1 <- readRDS("friedman.rds")$friedman1
friedman2 <- readRDS("friedman.rds")$friedman2
X <- friedman1[, paste0("x.", 1L:10L)]

# Tests for package e1071
if (require(e1071, quietly = TRUE)) {

  # Fit model(s)
  fit1 <- svm(y ~ ., data = friedman1)
  fit2 <- svm(x = X, y = friedman1$y)
  fit3 <- svm(y ~ ., data = friedman2, probability = TRUE)
  fit4 <- svm(y ~ ., data = friedman2)

  # Compute partial dependence for x.3
  pd1 <- partial(fit1, pred.var = "x.3")
  pd2 <- partial(fit2, pred.var = "x.3")
  pd3 <- partial(fit3, pred.var = "x.3")
  pd4 <- partial(fit3, pred.var = "x.3", prob = TRUE)
  ice1 <- partial(fit1, pred.var = "x.3", ice = TRUE)
  ice2 <- partial(fit3, pred.var = "x.3", ice = TRUE)
  ice3 <- partial(fit3, pred.var = "x.3", ice = TRUE, prob = TRUE)

  # Expectations: partial()
  expect_true(inherits(pd1, what = "partial"))
  expect_true(inherits(pd2, what = "partial"))
  expect_true(inherits(pd3, what = "partial"))
  expect_true(inherits(pd4, what = "partial"))
  expect_true(inherits(ice1, what = "ice"))
  expect_true(inherits(ice2, what = "ice"))
  expect_true(inherits(ice3, what = "ice"))
  expect_error(partial(fit4, pred.var = "x.3"))

}
