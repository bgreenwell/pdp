# Load Friedman benchmark data
friedman1 <- readRDS("friedman.rds")$friedman1

# Tests for topPredictors() using caret and randomForest
if (require(caret, quietly = TRUE) && require(randomForest, quietly = TRUE)) {

  # Regression model -----------------------------------------------------------

  # Fit a random forest
  fit <- train(y ~ ., data = friedman1, method = "rf", importance = TRUE,
               trControl = trainControl(method = "none"))

  # Extract "top" predictors
  vi1 <- topPredictors(fit, n = 100L)
  vi2 <- topPredictors(fit$finalModel, n = 100L)

  # Expectations
  expect_identical(vi1, vi2)
  expect_true(length(vi1) == ncol(friedman1) - 1)

}
