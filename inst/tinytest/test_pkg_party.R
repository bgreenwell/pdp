if (!at_home()) {
  exit_file("Skipping tests that run only at home.")
}

# Tests for package party (S4 methods)
if (require(party, quietly = TRUE)) {

  # Load Friedman benchmark data
  friedman1 <- readRDS("friedman.rds")$friedman1  # regression
  friedman2 <- readRDS("friedman.rds")$friedman2  # classification (binary)

  # Conditional inference tree; party::ctree() ---------------------------------

  # Fit model(s)
  fit1 <- ctree(y ~ ., data = friedman1)
  fit2 <- ctree(y ~ ., data = friedman2)

  # Partial dependence for x.4
  pd1 <- partial(fit1, pred.var = "x.4")
  pd2 <- partial(fit2, pred.var = "x.4")  # default (class-centered) logit scale
  pd2_prob <- partial(fit2, pred.var = "x.4", prob = TRUE)  # probability scale

  # ICE curves for x.4
  ice1 <- partial(fit1, pred.var = "x.4", ice = TRUE, center = TRUE)
  ice2 <- partial(fit2, pred.var = "x.4",
                  ice = TRUE, center = TRUE)  # default (class-centered) logit scale
  ice2_prob <- partial(fit2, pred.var = "x.4", prob = TRUE,
                       ice = TRUE, center = TRUE)  # probability scale

  # Expectation(s)
  expect_true(inherits(pd1, what = "partial"))
  expect_true(inherits(pd2, what = "partial"))
  expect_true(inherits(pd2_prob, what = "partial"))
  expect_true(inherits(ice1, what = "cice"))
  expect_true(inherits(ice2, what = "cice"))
  expect_true(inherits(ice2_prob, what = "cice"))

  # Display plots in a grid
  grid.arrange(
    plot(pd1, lattice = TRUE),
    plot(pd2, lattice = TRUE),
    plot(pd2_prob, lattice = TRUE),
    plot(ice1, lattice = TRUE),
    plot(ice2, lattice = TRUE),
    plot(ice2_prob, lattice = TRUE),
    nrow = 2
  )

  # Conditional inference forest; party::cforest() -----------------------------

  fit3 <- cforest(y ~ ., data = friedman1)
  fit4 <- cforest(y ~ ., data = friedman2)

  # Partial dependence for x.4
  pd3 <- partial(fit3, pred.var = "x.4")
  pd4 <- partial(fit4, pred.var = "x.4")  # default (class-centered) logit scale
  pd4_prob <- partial(fit4, pred.var = "x.4", prob = TRUE)  # probability scale

  # ICE curves for x.4
  ice3 <- partial(fit3, pred.var = "x.4", ice = TRUE, center = TRUE)
  ice4 <- partial(fit4, pred.var = "x.4",
                  ice = TRUE, center = TRUE)  # default (class-centered) logit scale
  ice4_prob <- partial(fit4, pred.var = "x.4", prob = TRUE,
                       ice = TRUE, center = TRUE)  # probability scale

  # Expectation(s)
  expect_true(inherits(pd3, what = "partial"))
  expect_true(inherits(pd4, what = "partial"))
  expect_true(inherits(pd4_prob, what = "partial"))
  expect_true(inherits(ice3, what = "cice"))
  expect_true(inherits(ice4, what = "cice"))
  expect_true(inherits(ice4_prob, what = "cice"))

  # Display plots in a grid
  grid.arrange(
    plot(pd3, lattice = TRUE),
    plot(pd4, lattice = TRUE),
    plot(pd4_prob, lattice = TRUE),
    plot(ice3, lattice = TRUE),
    plot(ice4, lattice = TRUE),
    plot(ice4_prob, lattice = TRUE),
    nrow = 2
  )

}
