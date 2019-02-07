context("Partial dependence functions")

# Data frames used in the following tests
pima2 <- na.omit(pima)
set.seed(101)
df.reg <- boston[sample(nrow(boston), size = 50, replace = FALSE), ]
df.class <- pima2[sample(nrow(pima2), size = 50, replace = FALSE), ]

# Switch to generic response names
df.reg$y <- df.reg$cmedv
df.class$y <- df.class$diabetes
df.reg$cmedv <- NULL
df.class$diabetes <- NULL

# Boston housing
boston2 <- boston
boston2$chas <- ifelse(boston2$chas == "0", yes = "a", no = "b")

# Fit regression (lm) and classification (glm) models
df.reg.lm <- lm(y ~ ., data = df.reg)
df.class.glm <- glm(y ~ ., data = df.class, family = binomial)

test_that("partial works correctly for regression", {

  # Specifying resolution of automatic grid
  pd1 <- partial(df.reg.lm, pred.var = "rm", grid.resolution = 5,
                 train = df.reg)

  # Specifying a grid manually
  pd2 <- partial(df.reg.lm, pred.var = "rm", pred.grid = data.frame(rm = 1),
                 check.class = FALSE, train = df.reg)

  # Return a trellis object
  pd3 <- partial(df.reg.lm, pred.var = "rm", grid.resolution = 5, plot = TRUE,
                 train = df.reg)

  # Using specific quantiles
  pd4 <- partial(df.reg.lm, pred.var = "rm", quantiles = TRUE, probs = 1:9/10,
                 train = df.reg)

  # Expectations
  expect_is(pd1, "data.frame")
  expect_is(pd2, "data.frame")
  expect_is(pd3, "trellis")
  expect_is(pd4, "data.frame")
  expect_identical(pd4$rm, as.numeric(quantile(df.reg$rm, probs = 1:9/10)))

  # Trellis object should still contain partial dependence data
  expect_is(attr(pd3, "partial.data"), "data.frame")
  expect_identical(pd1, attr(pd3, "partial.data"))

  # Warnings
  expect_warning(partial(df.reg.lm, pred.var = "rm",
                         pred.grid = df.reg[,"rm", drop = FALSE],
                         trim.outliers = TRUE, check.class = FALSE,
                         train = df.reg))
  expect_warning(partial(df.reg.lm, pred.var = "rm",
                         pred.grid = df.reg[,"rm", drop = FALSE],
                         quantiles = TRUE, check.class = FALSE,
                         train = df.reg))

})


test_that("partial works correctly for classification", {

  # Specifying resolution of automatic grid
  pd1 <- partial(df.class.glm, pred.var = "glucose", grid.resolution = 5,
                 train = df.class)

  # Specifying a grid manually
  pd2 <- partial(df.class.glm, pred.var = "glucose",
                 pred.grid = data.frame(glucose = 100), train = df.class,
                 check.class = FALSE)

  # Return a trellis object
  pd3 <- partial(df.class.glm, pred.var = "glucose", grid.resolution = 5,
                 plot = TRUE, train = df.class)

  # Request probabilities instead
  pd4 <- partial(df.class.glm, pred.var = "glucose", grid.resolution = 5,
                 prob = TRUE, train = df.class)

  # Expectations
  expect_is(pd1, "data.frame")
  expect_is(pd2, "data.frame")
  expect_is(pd3, "trellis")
  expect_true(pd4$yhat >= 0 && pd4$yhat <= 1)

  # Trellis object should still contain partial dependence data
  expect_is(attr(pd3, "partial.data"), "data.frame")
  expect_identical(pd1, attr(pd3, "partial.data"))

})


test_that("order of pred.grid does not matter", {

  # Regression
  df.reg.lm <- lm(y ~ .,
                  data = df.reg)

  # PDPs
  pd1 <- partial(df.reg.lm,
                 pred.var = "rm",
                 pred.grid = data.frame(rm = 1:5),
                 check.class = FALSE,
                 train = df.reg)

  pd2 <- partial(df.reg.lm,
                 pred.var = "rm",
                 pred.grid = data.frame(rm = 5:1),
                 check.class = FALSE,
                 train = df.reg)

  # Expectations
  expect_identical(pd1, pd2)

})

test_that("cats argument works", {

  # Don't test on CRAN
  skip_on_cran()

  if (require(gbm, quietly = TRUE)) {

    # Trees
    tree1 <- rpart::rpart(cmedv ~ chas, data = boston, control = list(cp = 0))
    tree2 <- rpart::rpart(cmedv ~ chas, data = boston2, control = list(cp = 0))

    # Partial dependence
    pd1 <- partial(tree1, pred.var = "chas")
    pd2 <- partial(tree2, pred.var = "chas", cats = "chas", train = boston2)

    # Expectations
    expect_s3_class(pd1, class = "partial")
    expect_s3_class(pd2, class = "partial")
    expect_error(partial(tree2, pred.var = "chas"))
    expect_identical(pd1$yhat, pd2$yhat)

  }

})
