if (!at_home()) {
  exit_file("Skipping tests that run only at home.")
}

if (!requireNamespace("gridExtra", quietly = TRUE)) {
  exit_file("Package gridExtra missing")
}

# Load required packages
suppressMessages({
  library(gridExtra)
})

# Tests for package MASS
if (require(MASS, quietly = TRUE)) {

  # Load Friedman benchmark data
  friedman2 <- readRDS("friedman.rds")$friedman2  # classification (binary)

  # Linear discriminant analysis; MASS::lda() ----------------------------------

  # Fit model(s)
  fit_lda <- lda(y ~ . ^ 2, data = friedman2)

  # Partial dependence for x.3
  pd_lda <- partial(fit_lda, pred.var = "x.3")
  pd_lda_prob <- partial(fit_lda, pred.var = "x.3", prob = TRUE)

  # ICE curves for x.3
  ice_lda <- partial(fit_lda, pred.var = "x.3", ice = TRUE, center = TRUE)
  ice_lda_prob <- partial(fit_lda, pred.var = "x.3", prob = TRUE,
                          ice = TRUE, center = TRUE)

  # Expectation(s)
  expect_true(inherits(pd_lda, what = "partial"))
  expect_true(inherits(pd_lda_prob, what = "partial"))
  expect_true(inherits(ice_lda, what = "cice"))
  expect_true(inherits(ice_lda_prob, what = "cice"))

  # Display plots in a grid
  grid.arrange(
    plot(pd_lda, lattice = TRUE),
    plot(pd_lda_prob, lattice = TRUE),
    plot(ice_lda, lattice = TRUE),
    plot(ice_lda_prob, lattice = TRUE),
    nrow = 2
  )

  # Quadratic discriminant analysis; MASS::qda() -------------------------------

  # Fit model(s)
  fit_qda <- qda(y ~ ., data = friedman2)

  # Partial dependence for x.3
  pd_qda <- partial(fit_qda, pred.var = "x.3")
  pd_qda_prob <- partial(fit_qda, pred.var = "x.3", prob = TRUE)

  # ICE curves for x.3
  ice_qda <- partial(fit_qda, pred.var = "x.3", ice = TRUE, center = TRUE)
  ice_qda_prob <- partial(fit_qda, pred.var = "x.3", prob = TRUE,
                          ice = TRUE, center = TRUE)

  # Expectation(s)
  expect_true(inherits(pd_qda, what = "partial"))
  expect_true(inherits(pd_qda_prob, what = "partial"))
  expect_true(inherits(ice_qda, what = "cice"))
  expect_true(inherits(ice_qda_prob, what = "cice"))

  # Display plots in a grid
  grid.arrange(
    plot(pd_qda, lattice = TRUE),
    plot(pd_qda_prob, lattice = TRUE),
    plot(ice_qda, lattice = TRUE),
    plot(ice_qda_prob, lattice = TRUE),
    nrow = 2
  )

}
