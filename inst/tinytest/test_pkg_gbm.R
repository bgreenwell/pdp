if (!at_home()) {
  exit_file("Skipping tests that run only at home.")
}

# Tests for package gbm (using ::)
if (require(gbm, quietly = TRUE)) {

  # Simulated regression data with a genuinely predictive factor; the factor
  # effect is large enough that a level shift (e.g., an off-by-one in the
  # categorical encoding passed to the C++ tree traversal routine) is
  # unmistakable
  set.seed(101)
  n <- 500
  d <- data.frame(
    x1 = rnorm(n),
    x2 = factor(sample(c("a", "b", "c"), size = n, replace = TRUE)),
    x3 = ordered(sample(c("lo", "med", "hi"), size = n, replace = TRUE),
                 levels = c("lo", "med", "hi"))
  )
  d$y <- d$x1 + ifelse(d$x2 == "a", -2, ifelse(d$x2 == "b", 0, 2)) +
    as.integer(d$x3) + rnorm(n, sd = 0.1)

  # Fit model(s)
  set.seed(102)
  fit1 <- gbm(y ~ ., data = d, distribution = "gaussian", n.trees = 100,
              interaction.depth = 2, shrinkage = 0.1, verbose = FALSE)
  set.seed(103)
  fit2 <- gbm(y ~ ., data = d, distribution = list(name = "quantile",
                                                   alpha = 0.5),
              n.trees = 25, verbose = FALSE)

  # Recursive (weighted tree traversal) vs brute force; the two methods handle
  # ties/weights slightly differently, so only require close agreement
  for (x in c("x1", "x2", "x3")) {
    pd.recursive <- partial(fit1, pred.var = x, n.trees = 100, train = d)
    pd.brute <- partial(fit1, pred.var = x, n.trees = 100, recursive = FALSE,
                        train = d)
    expect_true(inherits(pd.recursive, what = "partial"))
    expect_identical(pd.recursive[[x]], pd.brute[[x]])  # incl. factor levels
    expect_true(max(abs(pd.recursive$yhat - pd.brute$yhat)) < 0.25,
                info = paste("recursive vs brute force for", x))
  }

  # Recursive method should agree with gbm's own implementation exactly
  pd <- partial(fit1, pred.var = "x2", n.trees = 100, train = d)
  ref <- plot(fit1, i.var = "x2", n.trees = 100, return.grid = TRUE)
  expect_equal(pd$yhat, ref$y)

  # List-valued distributions (e.g., quantile regression) should work
  pd.quantile <- partial(fit2, pred.var = "x1", n.trees = 25, train = d,
                         grid.resolution = 5)
  expect_true(inherits(pd.quantile, what = "partial"))

  # `n.trees` is required for the recursive method
  expect_error(partial(fit1, pred.var = "x1", train = d))

}
