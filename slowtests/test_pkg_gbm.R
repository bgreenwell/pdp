# Load required packages
library(ggplot2)

# Load Friedman benchmark data
friedman1 <- readRDS("friedman.rds")$friedman1
friedman2 <- readRDS("friedman.rds")$friedman2
friedman3 <- readRDS("friedman.rds")$friedman3
friedman3$x.5 <- cut(friedman3$x.5, breaks = 10)

# Tests for package gbm
if (require(gbm, quietly = TRUE)) {

  # Fit model(s)
  fit1 <- gbm(
    formula = y ~ .,
    data = friedman1,
    distribution = "gaussian",
    shrinkage = 0.01,
    n.trees = 500,
    interaction.depth = 2
  )
  fit2 <- gbm(
    formula = ifelse(y == "class1", 1, 0) ~ .,
    data = friedman2,
    distribution = "bernoulli",
    shrinkage = 0.01,
    n.trees = 500,
    interaction.depth = 2
  )
  fit3 <- gbm(
    formula = y ~ .,
    data = friedman3,
    distribution = "multinomial",
    shrinkage = 0.01,
    n.trees = 500,
    interaction.depth = 2
  )
  iter1 <- suppressMessages(gbm.perf(fit1, plot.it = FALSE, method = "OOB"))
  iter2 <- suppressMessages(gbm.perf(fit2, plot.it = FALSE, method = "OOB"))
  iter3 <- suppressMessages(gbm.perf(fit3, plot.it = FALSE, method = "OOB"))

  # Compute partial dependence, ICE, etc. for x.3
  pd1 <- partial(fit1, pred.var = "x.3", n.trees = iter1)
  pd1.brute <- partial(fit1, pred.var = "x.3", n.trees = iter1,
                       recursive = FALSE)
  pd2 <- partial(fit2, pred.var = "x.3", n.trees = iter2)
  pd2.prob <- partial(fit2, pred.var = "x.3", prob = TRUE, n.trees = iter1)
  ice1 <- partial(fit1, pred.var = "x.3", n.trees = iter1, ice = TRUE)
  ice1.brute <- partial(fit1, pred.var = "x.3", n.trees = iter1,
                        recursive = FALSE, ice = TRUE)
  ice2 <- partial(fit2, pred.var = "x.3", n.trees = iter2, ice = TRUE)
  ice2.prob <- partial(fit2, pred.var = "x.3", prob = TRUE, n.trees = iter1,
                       ice = TRUE)
  pdp3 <- lapply(1L:3L, FUN = function(x) {
    partial(fit3, pred.var = "x.5", n.trees = iter3, which.class = x,
            plot = TRUE)
  })
  grid.arrange(grobs = pdp3)

  # Display plots in a grid
  grid.arrange(
    plotPartial(pd1),
    plotPartial(pd1.brute),
    plotPartial(pd2),
    plotPartial(pd2.prob),
    plotPartial(ice1),
    plotPartial(ice1.brute),
    plotPartial(ice2),
    plotPartial(ice2.prob),
    nrow = 2
  )


  # Expectations: partial()
  expect_error(partial(fit4, pred.var = "x.3"))  # missing n.trees argument
  expect_true(inherits(pd1, what = "partial"))
  expect_true(inherits(pd1.brute, what = "partial"))
  expect_true(inherits(pd2, what = "partial"))
  expect_true(inherits(pd2.prob, what = "partial"))
  expect_true(inherits(ice1, what = "ice"))
  expect_true(inherits(ice1.brute, what = "ice"))
  expect_true(inherits(ice2, what = "ice"))
  expect_true(inherits(ice2.prob, what = "ice"))
  lapply(pdp3, FUN = function(x) expect_true(inherits(x, what = "trellis")))
}
