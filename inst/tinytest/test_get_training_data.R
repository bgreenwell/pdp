if (!at_home()) {
  exit_file("Skipping tests that run only at home.")
}

# Load Friedman benchmark data
friedman1 <- readRDS("friedman.rds")$friedman1

# Tests for package caret
if (require(caret, quietly = TRUE)) {

  # Fit model(s)
  fit1 <- train(y ~ ., data = friedman1, method = "lm")
  fit2 <- train(y ~ ., data = friedman1, method = "lm",
                trControl = trainControl(returnData = FALSE))

  # Expectations
  expect_identical(
    current = pdp:::get_training_data.train(fit1),
    target = friedman1[, paste0("x.", 1L:10L)]
  )
  expect_error(pdp:::get_training_data.train(fit2))

}


# Tests for package earth
if (require(earth, quietly = TRUE)) {

  # Fit model(s)
  fit1 <- earth(y ~ ., data = friedman1)
  fit2 <- earth(x = friedman1[, paste0("x.", 1L:10L)], y = friedman1$y)
  fit3 <- earth(data.matrix(friedman1[, paste0("x.", 1L:10L)]),
                y = friedman1$y)

  # Expectations
  expect_identical(
    current = pdp:::get_training_data.earth(fit1),
    target = friedman1
  )
  expect_identical(
    current = pdp:::get_training_data.earth(fit2),
    target = friedman1[, paste0("x.", 1L:10L)]
  )
  expect_identical(
    current = pdp:::get_training_data.earth(fit3),
    target = friedman1[, paste0("x.", 1L:10L)]
  )

}


# Tests for package randomForest
if (require(randomForest, quietly = TRUE)) {

  # Fit model(s)
  fit1 <- randomForest(y ~ ., friedman1)  # NOTE: Data arg not named!
  fit2 <- randomForest(y ~ ., data = friedman1)
  fit3 <- randomForest(x = friedman1[, paste0("x.", 1L:10L)],
                       y = friedman1$y)

  # Expectations
  expect_identical(
    current = pdp:::get_training_data.randomForest(fit1),
    target = friedman1
  )
  expect_identical(
    current = pdp:::get_training_data.randomForest(fit2),
    target = friedman1
  )
  expect_identical(
    current = pdp:::get_training_data.randomForest(fit3),
    target = friedman1[, paste0("x.", 1L:10L)]
  )

}


# Tests for package ranger (using ::)
if (require(ranger, quietly = TRUE)) {

  # Fit model(s)
  fit1 <- ranger(y ~ ., friedman1)  # NOTE: Data arg not named!
  fit2 <- ranger(y ~ ., data = friedman1)

  # Expectations
  expect_identical(
    current = pdp:::get_training_data.default(fit1),
    target = friedman1
  )
  expect_identical(
    current = pdp:::get_training_data.default(fit2),
    target = friedman1
  )

}
