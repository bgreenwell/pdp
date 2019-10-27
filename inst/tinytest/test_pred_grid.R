# Load Friedman benchmark data
friedman1 <- readRDS("friedman.rds")$friedman1

# Add an obvious outlier
friedman1$x.1[1L] <- -999

# Default grid (which includes min/max)
grid1 <- pdp:::pred_grid(
  train = friedman1,
  pred.var = "x.1"
)

# Trim outliers first
grid2 <- pdp:::pred_grid(
  train = friedman1,
  pred.var = "x.1",
  grid.resolution = 10,
  trim.outliers = TRUE
)

# Use quantiles instead
grid3 <- pdp:::pred_grid(
  train = friedman1,
  pred.var = "x.1",
  quantiles = TRUE,
  probs = 1:10/10
)

# Expectations
expect_true(
  min(grid1$x.1) == -999
)
expect_true(
  min(grid2$x.1) >= 0
)
expect_true(
  min(grid3$x.1) >= 0
)
expect_error(
  pdp:::pred_grid(list("x.1" = 1:10), pred.var = "x.1")
)
expect_error(
  pdp:::pred_grid(friedman1, pred.var = "x.1", grid.resolution = 10,
                  quantiles = TRUE)
)
expect_error(
  pdp:::pred_grid(friedman1, pred.var = "x.1", trim.outliers = TRUE,
                  quantiles = TRUE)
)
df1 <- data.frame(x = c(2, 1, 3, 3), y = c(1, 1, 2, 1))
df2 <- data.frame(x = c(1, 2, 3, 3), y = c(1, 1, 1, 2))
expect_equal(
  current = pdp:::order_grid.data.frame(df1),
  target = df2,
  check.attributes = FALSE
)
