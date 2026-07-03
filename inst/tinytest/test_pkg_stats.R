if (!at_home()) {
  exit_file("Skipping tests that run only at home.")
}

# Tests for package party (S4 methods)
if (require(party, quietly = TRUE)) {

  # Load Friedman benchmark data
  friedman1 <- readRDS("friedman.rds")$friedman1  # regression
  friedman2 <- readRDS("friedman.rds")$friedman2  # classification (binary)

  # Linear model; stats::lm() --------------------------------------------------

  # Fit model(s)
  fit1_lm <- lm(y ~ sin(pi * x.1 * x.2) + I((x.3 - 0.5)^2) + x.4 + x.5 + x.6 +
                  x.7 + x.8 + x.9 + x.10, data = friedman1)
  fit1_glm <- glm(y ~ sin(pi * x.1 * x.2) + I((x.3 - 0.5)^2) + x.4 + x.5 + x.6 +
                    x.7 + x.8 + x.9 + x.10, data = friedman1)

  # Partial dependence for x.3
  pd1_lm <- partial(fit1_lm, pred.var = "x.3")
  pd1_glm <- partial(fit1_glm, pred.var = "x.3")

  # ICE curves for x.3
  ice1_lm <- partial(fit1_lm, pred.var = "x.3", ice = TRUE, center = TRUE)
  ice1_glm <- partial(fit1_glm, pred.var = "x.3", ice = TRUE, center = TRUE)

  # Expectation(s)
  expect_true(inherits(pd1_lm, what = "partial"))
  expect_true(inherits(pd1_glm, what = "partial"))
  expect_equal(pd1_lm, target = pd1_glm)
  expect_true(inherits(ice1_lm, what = "cice"))
  expect_true(inherits(ice1_glm, what = "cice"))
  expect_equal(ice1_lm, target = ice1_glm)

  # Display plots in a grid
  grid.arrange(
    plotPartial(pd1_lm),
    plotPartial(pd1_glm),
    plotPartial(ice1_lm),
    plotPartial(ice1_glm),
    nrow = 2
  )

  # Generalized linear model; stats::glm() -------------------------------------

  # Fit model(s)
  fit2_glm <- glm(y ~ sin(pi * x.1 * x.2) + I((x.3 - 0.5)^2) + x.4 + x.5 + x.6 +
                    x.7 + x.8 + x.9 + x.10, data = friedman2, family = binomial)

  # Partial dependence for x.3
  pd2_glm <- partial(fit2_glm, pred.var = "x.3")
  pd2_glm_prob <- partial(fit2_glm, pred.var = "x.3", prob = TRUE)

  # ICE curves for x.3
  ice2_glm <- partial(fit2_glm, pred.var = "x.3", ice = TRUE, center = TRUE)
  ice2_glm_prob <- partial(fit2_glm, pred.var = "x.3", prob = TRUE,
                           ice = TRUE, center = TRUE)

  # Expectation(s)
  expect_true(inherits(pd2_glm, what = "partial"))
  expect_true(inherits(pd2_glm_prob, what = "partial"))
  expect_true(inherits(ice2_glm, what = "cice"))
  expect_true(inherits(ice2_glm_prob, what = "cice"))

  # Display plots in a grid
  grid.arrange(
    plotPartial(pd2_glm),
    plotPartial(pd2_glm_prob),
    plotPartial(ice2_glm),
    plotPartial(ice2_glm_prob),
    nrow = 2
  )

}
