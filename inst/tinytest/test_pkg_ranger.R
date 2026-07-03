if (!at_home()) {
  exit_file("Skipping tests that run only at home.")
}

# Load Friedman benchmark data
friedman1 <- readRDS("friedman.rds")$friedman1
friedman2 <- readRDS("friedman.rds")$friedman2

# Tests for package ranger (using ::)
if (require(ranger, quietly = TRUE) && require(parsnip, quietly = TRUE)) {

  # Fit model(s)
  fit1 <- ranger(y ~ ., friedman1)  # NOTE: Data arg not named!
  fit2 <- ranger(y ~ ., data = friedman1)
  fit3 <- ranger(y ~ ., data = friedman2, probability = TRUE)
  fit4 <- ranger(y ~ ., data = friedman2, probability = FALSE)

  # Use parsnip interface
  fit5 <- rand_forest(mtry = 3, trees = 2000, mode = "regression") %>%
    set_engine("ranger", importance = 'impurity') %>%
    fit(y ~ ., data = friedman1)

  # Compute partial dependence for x.3
  pd1 <- partial(fit1, pred.var = "x.3")
  pd2 <- partial(fit2, pred.var = "x.3")
  pd3 <- partial(fit3, pred.var = "x.3")
  pd4 <- partial(fit3, pred.var = "x.3", prob = TRUE)
  pd5 <- partial(fit5, pred.var = "x.3", train = friedman1)
  ice1 <- partial(fit2, pred.var = "x.3", ice = TRUE)
  ice2 <- partial(fit3, pred.var = "x.3", ice = TRUE)
  ice3 <- partial(fit3, pred.var = "x.3", ice = TRUE, prob = TRUE)

  # Expectations: partial()
  expect_true(inherits(pd1, what = "partial"))
  expect_true(inherits(pd2, what = "partial"))
  expect_true(inherits(pd3, what = "partial"))
  expect_true(inherits(pd4, what = "partial"))
  expect_true(inherits(pd5, what = "partial"))
  expect_true(inherits(ice1, what = "ice"))
  expect_true(inherits(ice2, what = "ice"))
  expect_true(inherits(ice3, what = "ice"))
  expect_error(partial(fit4, pred.var = "x.3"))

}
