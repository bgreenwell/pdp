# Regression tests tied to specific GitHub issues
# (https://github.com/bgreenwell/pdp/issues)

# Simple regression fit used throughout
set.seed(101)
d <- data.frame(y = rnorm(50), x1 = rnorm(50), x2 = rnorm(50))
fit <- stats::lm(y ~ ., data = d)


# Issue #113: non-syntactic variable names (e.g., containing dashes) broke
# formula construction in the plotting code
d113 <- data.frame(check.names = FALSE, y = rnorm(50), `x-var` = rnorm(50),
                   `x 2` = rnorm(50))
fit113 <- stats::lm(y ~ ., data = d113)
pd113 <- partial(fit113, pred.var = "x-var", train = d113,
                 grid.resolution = 5)
expect_inherits(pd113, "partial")
pdf(NULL)
expect_inherits(plot(pd113, lattice = TRUE), "trellis")
expect_inherits(plot(pd113), "partial")  # tinyplot engine
pd113.2 <- partial(fit113, pred.var = c("x-var", "x 2"), train = d113,
                   grid.resolution = 5)
expect_inherits(plot(pd113.2, lattice = TRUE), "trellis")
expect_inherits(plot(pd113.2), "partial")
ice113 <- partial(fit113, pred.var = "x-var", train = d113, ice = TRUE,
                  grid.resolution = 5)
expect_inherits(plot(ice113, lattice = TRUE), "trellis")
expect_inherits(plot(ice113), "ice")
invisible(dev.off())


# Issue #77: `chull = TRUE` failed for sparse ("dgCMatrix") training data
if (requireNamespace("Matrix", quietly = TRUE)) {
  X <- data.matrix(d[, c("x1", "x2")])
  grid <- expand.grid(x1 = seq(-2, 2, length = 5),
                      x2 = seq(-2, 2, length = 5))
  hull.dense <- pdp:::train_chull(c("x1", "x2"), pred.grid = grid, train = X)
  Xs <- methods::as(X, "dgCMatrix")
  hull.sparse <- pdp:::train_chull(c("x1", "x2"), pred.grid = grid, train = Xs)
  expect_identical(hull.dense, hull.sparse)
  expect_true(nrow(hull.dense) < nrow(grid))  # some grid points dropped
}


# Issues #111/#112: plotting multi-predictor output from `pred.fun` (i.e., an
# object with a "yhat.id" column and more than one predictor) should throw an
# informative error rather than producing a nonsense display
pfun <- function(object, newdata) unname(predict(object, newdata = newdata))
pd.multi <- partial(fit, pred.var = c("x1", "x2"), pred.fun = pfun, train = d,
                    grid.resolution = 3)
expect_inherits(pd.multi, "ice")
pdf(NULL)
expect_error(plot(pd.multi, lattice = TRUE),
             pattern = "multiple\\s+.?predictors")
expect_error(plot(pd.multi), pattern = "multiple\\s+.?predictors")
invisible(dev.off())


# Issue #137 (and related): failing to recover the training data should always
# produce the informative "please supply train" error, even when the object
# stores something other than a proper call
junk <- structure(list(call = quote(1 + 1)), class = "junkmodel")
expect_error(pdp:::get_training_data.default(junk),
             pattern = "training data could not be extracted")


# Issue #122: `pred.var` can be omitted whenever `pred.grid` is supplied
pd122a <- partial(fit, pred.grid = data.frame(x1 = seq(-2, 2, length = 5)),
                  train = d)
pd122b <- partial(fit, pred.var = "x1",
                  pred.grid = data.frame(x1 = seq(-2, 2, length = 5)),
                  train = d)
expect_identical(pd122a, pd122b)


# Issue #115: `exemplar()` supports a `cats` argument for matrix-like objects
X115 <- cbind(num = c(1.1, 2.2, 3.3, 4.4), cat = c(1, 0, 1, 1))
ex115 <- exemplar(X115, cats = "cat")
expect_equal(ex115[, "cat"], c(cat = 1))  # most frequent value
expect_equal(ex115[, "num"], c(num = 3))  # ceiling(median)
if (requireNamespace("Matrix", quietly = TRUE)) {
  ex115s <- exemplar(methods::as(X115, "dgCMatrix"), cats = "cat")
  expect_equal(as.numeric(ex115s[1L, ]), as.numeric(ex115[1L, ]))
}


# Issue #74: `frac` randomly samples the training data before computing
# ICE curves
set.seed(102)
ice74 <- partial(fit, pred.var = "x1", ice = TRUE, frac = 0.5,
                 grid.resolution = 5, train = d)
expect_equal(length(unique(ice74$yhat.id)), 25L)  # floor(0.5 * 50)
expect_error(partial(fit, pred.var = "x1", frac = 0, train = d))
expect_error(partial(fit, pred.var = "x1", frac = 2, train = d))


# Issue #81: ICE curves can be colored by another feature via `color.by`
ice81 <- partial(fit, pred.var = "x1", ice = TRUE, grid.resolution = 5,
                 train = d)
pdf(NULL)
expect_inherits(plot(ice81, color.by = "x2", train = d), "ice")
expect_error(plot(ice81, color.by = "x2"))  # train required
invisible(dev.off())


# Issue #132: bar plots for factor predictors via `bars = TRUE`
pd132 <- data.frame(x = factor(c("a", "b", "c")), yhat = c(1, 3, 2))
class(pd132) <- c("partial", "data.frame")
pdf(NULL)
expect_inherits(plot(pd132, bars = TRUE), "partial")
invisible(dev.off())
