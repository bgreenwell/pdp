# Load Friedman benchmark data
friedman1 <- readRDS("friedman.rds")$friedman1  # regression
friedman2 <- readRDS("friedman.rds")$friedman2  # classification (binary)


# Tests for package party (S4 methods)
if (require(party, quietly = TRUE)) {

  # ctree()

  # Fit model(s)
  fit1 <- ctree(y ~ ., data = friedman1)
  fit2 <- ctree(y ~ ., data = friedman2)
  fit3 <- cforest(y ~ ., data = friedman1)
  fit4 <- cforest(y ~ ., data = friedman2)

  # Expectations: get_training_data()
  expect_equal(
    current = pdp:::get_training_data.BinaryTree(fit1),
    target = friedman1[, paste0("x.", 1L:10L)],
    check.attributes = FALSE
  )
  expect_equal(
    current = pdp:::get_training_data.BinaryTree(fit2),
    target = friedman2[, paste0("x.", 1L:10L)],
    check.attributes = FALSE
  )
  expect_equal(
    current = pdp:::get_training_data.RandomForest(fit3),
    target = friedman1[, paste0("x.", 1L:10L)],
    check.attributes = FALSE
  )
  expect_equal(
    current = pdp:::get_training_data.RandomForest(fit4),
    target = friedman2[, paste0("x.", 1L:10L)],
    check.attributes = FALSE
  )
  expect_error(pdp:::get_training_data.default(fit1))

  # Expectations: get_task()
  expect_identical(
    current = pdp:::get_task.BinaryTree(fit1),
    target = "regression"
  )
  expect_identical(
    current = pdp:::get_task.BinaryTree(fit2),
    target = "classification"
  )
  expect_identical(
    current = pdp:::get_task.RandomForest(fit3),
    target = "regression"
  )
  expect_identical(
    current = pdp:::get_task.RandomForest(fit4),
    target = "classification"
  )

}
