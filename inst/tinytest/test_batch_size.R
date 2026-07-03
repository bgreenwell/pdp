# Load Friedman benchmark data
friedman1 <- readRDS("friedman.rds")$friedman1
friedman2 <- readRDS("friedman.rds")$friedman2

# Fit linear/logistic models (no external package dependencies)
fit1 <- stats::lm(y ~ ., data = friedman1)
fit2 <- stats::glm(y ~ ., data = friedman2, family = binomial)

# Regression: batched results should be identical to the classic approach for
# various batch sizes (batch.size = 1 forces one grid point per chunk;
# batch.size = Inf scores everything in a single call)
pd1 <- partial(fit1, pred.var = "x.3", grid.resolution = 10)
for (bs in c(1, 250, Inf)) {
  pd1.batched <- partial(fit1, pred.var = "x.3", grid.resolution = 10,
                         batch.size = bs)
  expect_equal(pd1, pd1.batched, info = paste("batch.size =", bs))
}

# Classification (probability and centered logit scales)
pd2 <- partial(fit2, pred.var = "x.3", grid.resolution = 10)
pd2.batched <- partial(fit2, pred.var = "x.3", grid.resolution = 10,
                       batch.size = 1e5)
expect_equal(pd2, pd2.batched)
pd3 <- partial(fit2, pred.var = "x.3", grid.resolution = 10, prob = TRUE)
pd3.batched <- partial(fit2, pred.var = "x.3", grid.resolution = 10,
                       prob = TRUE, batch.size = 1e5)
expect_equal(pd3, pd3.batched)

# ICE and c-ICE curves
ice1 <- partial(fit1, pred.var = "x.3", grid.resolution = 5, ice = TRUE)
ice1.batched <- partial(fit1, pred.var = "x.3", grid.resolution = 5,
                        ice = TRUE, batch.size = 1e5)
expect_equal(ice1, ice1.batched)
cice1 <- partial(fit1, pred.var = "x.3", grid.resolution = 5, ice = TRUE,
                 center = TRUE)
cice1.batched <- partial(fit1, pred.var = "x.3", grid.resolution = 5,
                         ice = TRUE, center = TRUE, batch.size = 1e5)
expect_equal(cice1, cice1.batched)

# Multiple predictors
pd4 <- partial(fit1, pred.var = c("x.1", "x.3"), grid.resolution = 5)
pd4.batched <- partial(fit1, pred.var = c("x.1", "x.3"), grid.resolution = 5,
                       batch.size = 1e5)
expect_equal(pd4, pd4.batched)

# User-supplied prediction wrappers work as long as they return one prediction
# per row of `newdata` (unnamed here since batching always uses integer IDs
# for `yhat.id`, whereas the classic path uses prediction names when available)
pred.rows <- function(object, newdata) {
  unname(predict(object, newdata = newdata))
}
ice2 <- partial(fit1, pred.var = "x.3", grid.resolution = 5,
                pred.fun = pred.rows)
ice2.batched <- partial(fit1, pred.var = "x.3", grid.resolution = 5,
                        pred.fun = pred.rows, batch.size = 1e5)
expect_equal(ice2, ice2.batched)

# But aggregating wrappers should throw an informative error when batched
pred.mean <- function(object, newdata) mean(predict(object, newdata = newdata))
expect_error(
  partial(fit1, pred.var = "x.3", grid.resolution = 5, pred.fun = pred.mean,
          batch.size = 1e5),
  pattern = "one prediction per row"
)

# Sanity checks on the `batch.size` argument itself
expect_error(partial(fit1, pred.var = "x.3", batch.size = -1))
expect_error(partial(fit1, pred.var = "x.3", batch.size = "big"))
expect_error(partial(fit1, pred.var = "x.3", batch.size = c(1, 2)))
