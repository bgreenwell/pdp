# Tests for the consolidated plot() interface (tinyplot by default, lattice
# via `lattice = TRUE`) and the deprecation of plotPartial()

# Simple regression fit (no external package dependencies)
set.seed(101)
d <- data.frame(y = rnorm(100), x1 = rnorm(100), x2 = rnorm(100),
                x3 = rnorm(100))
fit <- stats::lm(y ~ ., data = d)

pd1 <- partial(fit, pred.var = "x1", grid.resolution = 5, train = d)
pd2 <- partial(fit, pred.var = c("x1", "x2"), grid.resolution = 5, train = d)
pd3 <- partial(fit, pred.var = c("x1", "x2", "x3"), grid.resolution = 4,
               train = d, batch.size = 1e5)
ice1 <- partial(fit, pred.var = "x1", grid.resolution = 5, ice = TRUE,
                train = d)
cice1 <- partial(fit, pred.var = "x1", grid.resolution = 5, ice = TRUE,
                 center = TRUE, train = d)

pdf(NULL)

# `lattice = TRUE` draws with lattice and (invisibly) returns the "trellis"
# object; the tinyplot engine returns the input invisibly
expect_inherits(plot(pd1, lattice = TRUE), "trellis")
expect_inherits(plot(pd2, lattice = TRUE), "trellis")
expect_inherits(plot(pd3, lattice = TRUE), "trellis")  # tinyplot can't do 3
expect_inherits(plot(ice1, lattice = TRUE), "trellis")
expect_inherits(plot(cice1, lattice = TRUE), "trellis")
expect_inherits(plot(pd1), "partial")
expect_inherits(plot(ice1), "ice")
expect_false(withVisible(plot(pd1, lattice = TRUE))$visible)

# Lattice-only options pass through `...` (e.g., 3-D wireframe)
expect_inherits(
  plot(pd2, lattice = TRUE, levelplot = FALSE, drape = TRUE,
       screen = list(z = -20, x = -60)),
  "trellis"
)

# The tinyplot engine cannot display more than two predictors
expect_error(plot(pd3), pattern = "more than two")

# plotPartial() is soft-deprecated but still works
expect_warning(p <- plotPartial(pd1), pattern = "deprecated")
expect_inherits(p, "trellis")

# partial(plot = TRUE) must not trigger the deprecation warning with either
# engine
expect_silent(p1 <- partial(fit, pred.var = "x1", grid.resolution = 5,
                            train = d, plot = TRUE, plot.engine = "lattice"))
expect_inherits(p1, "trellis")
expect_silent(p2 <- partial(fit, pred.var = "x1", grid.resolution = 5,
                            train = d, plot = TRUE))
expect_inherits(p2, "partial")

invisible(dev.off())
