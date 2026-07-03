if (!at_home()) {
  exit_file("Skipping tests that run only at home.")
}

# Load Friedman benchmark data
friedman2 <- readRDS("friedman.rds")$friedman2

# Tests for package C50
if (require(C50, quietly = TRUE)) {

  # Fit model(s)
  fit1 <- C5.0(y ~ ., friedman2)
  fit2 <- C5.0(x = friedman2[, paste0("x.", 1L:10L)], y = friedman2$y)

  # Expectations: get_training_data()
  expect_identical(
    current = pdp:::get_training_data.C5.0(fit1),
    target = friedman2
  )
  expect_identical(
    current = pdp:::get_training_data.C5.0(fit2),
    target = friedman2[, paste0("x.", 1L:10L)]
  )

  # Expectations: get_task()
  expect_identical(
    current = pdp:::get_task.C5.0(fit1),
    target = "classification"
  )
  expect_identical(
    current = pdp:::get_task.C5.0(fit2),
    target = "classification"
  )

}
