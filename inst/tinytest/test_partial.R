# Exits
if (!requireNamespace("AmesHousing", quietly = TRUE)) {
  exit_file("Package AmesHousing missing")
}
if (!requireNamespace("gbm", quietly = TRUE)) {
  exit_file("Package gbm missing")
}
if (!requireNamespace("ggplot2", quietly = TRUE)) {
  exit_file("Package ggplot2 missing")
}
if (!requireNamespace("gridExtra", quietly = TRUE)) {
  exit_file("Package gridExtra missing")
}

# Load required packages
suppressMessages({
#   library(AmesHousing)
#   library(gbm)
  library(ggplot2)
  library(gridExtra)
})

# Load the Ames housing data
ames <- as.data.frame(AmesHousing::make_ames())

# Fit a gbm model
set.seed(1918)  # for reproducibility
fit <- gbm::gbm(
  Sale_Price ~ .,
  data = ames,
  distribution = "gaussian",
  n.trees = 1500,
  interaction.depth = 6,
  shrinkage = 0.1,
  bag.fraction = 1,
  cv.folds = 5,  # implicitly uses more cores than R CMD Check will allow
  n.cores = 2  # set to CRAN max
)
best_iter <- gbm::gbm.perf(fit, method = "cv")

# Partial dependence w/wo setting approx = TRUE
pd1 <- partial(fit, pred.var = "Gr_Liv_Area", n.trees = best_iter,
               recursive = FALSE, progress = "progress")
pd2 <- partial(fit, pred.var = "Gr_Liv_Area", approx = TRUE,
               recursive = FALSE, progress = "progress",
               n.trees = best_iter)

# Basic expectation(s)
expect_true(inherits(pd1, what = "partial"))
expect_true(inherits(pd2, what = "partial"))
expect_identical(dim(pd1), target = c(51L, 2L))
expect_identical(dim(pd2), target = c(51L, 2L))

# Display plots side by side
grid.arrange(
  plotPartial(pd1),
  plotPartial(pd2),
  nrow = 1
)

# Users can call plotPartial() to construct lattice-based PDPs
pdp1_lattice <- plotPartial(pd1, smooth = TRUE, rug = TRUE, train = ames)

# Users can call autoplot() to construct ggplot2-based PDPs
pdp1_ggplot2 <- autoplot(pd1, smooth = TRUE, rug = TRUE, train = ames)

# Expectation(s)
expect_true(inherits(pdp1_lattice, what = "trellis"))
expect_true(inherits(pdp1_ggplot2, what = "ggplot"))

# Users should be able to supply the predictor name(s) or column position(s)
# in train
expect_identical(
  current = partial(fit, pred.var = "Gr_Liv_Area", n.trees = best_iter),
  target = partial(fit, pred.var = which(names(ames) == "Gr_Liv_Area"),
                   n.trees = best_iter)
)

# An error should be thrown whenever pred.var is not found in train
expect_error(partial(fit, pred.var = "ABC", n.trees = best_iter))
expect_error(partial(fit, pred.var = 100, n.trees = best_iter))

# Users can supply their own predictor grid
grid1 <- data.frame("Gr_Liv_Area" = range(ames$Gr_Liv_Area))
grid2 <- data.frame("x" = range(ames$Gr_Liv_Area))
pd_grid1 <- partial(fit, pred.var = "Gr_Liv_Area", pred.grid = grid1,
                    n.trees = best_iter)
expect_true(inherits(pd_grid1, what = "partial"))
expect_identical(dim(pd_grid1), target = c(2L, 2L))
expect_error(partial(fit, pred.var = "Gr_Liv_Area", pred.grid = grid2,
                     n.trees = best_iter))

# No progress bars or parallel processing for GBMs when `recursive = TRUE`
expect_message(partial(fit, pred.var = "Gr_Liv_Area", pred.grid = grid1,
                       n.trees = best_iter, progress = "text"))
expect_error(partial(fit, pred.var = "Gr_Liv_Area", pred.grid = grid1,
                     n.trees = best_iter, parallel = TRUE))

# `pred.grid` has to be a data frame
expect_error(partial(fit, pred.var = "Gr_Liv_Area",
                     pred.grid = data.matrix(grid1),
                     n.trees = best_iter))

# Some arguments will be ignored whenever `pred.grid` is specified
expect_warning(partial(fit, pred.var = "Gr_Liv_Area", pred.grid = grid1,
                       trim.outliers = TRUE, n.trees = best_iter))

# A warning should be thrown whenever users specify `inv.link` for GBMs when
# `recursive = TRUE`
expect_warning(partial(fit, pred.var = "Gr_Liv_Area", n.trees = best_iter,
                       inv.link = I))
expect_identical(
  current = partial(fit, pred.var = "Gr_Liv_Area", n.trees = best_iter,
                    recursive = FALSE),
  target = partial(fit, pred.var = "Gr_Liv_Area", n.trees = best_iter,
                   recursive = FALSE, inv.link = I)
)

# Users can supply their own prediction wrapper
pfun1 <- function(object, newdata) {
  mean(predict(object, newdata = newdata, n.trees = best_iter))
}
pfun2 <- function(object, new_data) {  # wrong argument names
  mean(predict(object, newdata = newdata))
}
pfun3 <- function(object, newdata) {
  predict(object, newdata = newdata, n.trees = best_iter)
}
pfun4 <- function(object, newdata) {
  p <- predict(object, newdata = newdata, n.trees = best_iter)
  names(p) <- paste0("row_", seq_along(p))
  p
}
pd_pfun1 <- partial(fit, pred.var = "Gr_Liv_Area", pred.grid = grid1,
                    chull = TRUE,  # should simply be ignored
                    pred.fun = pfun1, recursive = FALSE)  # no need for n.trees
pd_pfun3 <- partial(fit, pred.var = "Gr_Liv_Area", pred.grid = grid1,
                    pred.fun = pfun3, recursive = FALSE)  # no need for n.trees
pd_pfun4 <- partial(fit, pred.var = "Gr_Liv_Area", pred.grid = grid1,
                    pred.fun = pfun4, recursive = FALSE)  # no need for n.trees
expect_true(inherits(pd_pfun1, what = "partial"))
expect_true(inherits(pd_pfun3, what = "ice"))
expect_true(inherits(pd_pfun4, what = "ice"))
expect_identical(dim(pd_pfun1), target = c(2L, 2L))
expect_identical(dim(pd_pfun3), target = c(as.integer(2 * nrow(ames)), 3L))
expect_identical(dim(pd_pfun4), target = c(as.integer(2 * nrow(ames)), 3L))
# expect_identical(pd_pfun4$yhat.id[1L], target = "row_1")

expect_identical(
  current = pd_pfun1,
  target = partial(fit, pred.var = "Gr_Liv_Area", pred.grid = grid1,
                   recursive = FALSE, n.trees = best_iter)
)
expect_error(  # cannot use `pred.fun` when `recursive = TRUE`
  partial(fit, pred.var = "Gr_Liv_Area", pred.grid = grid1, pred.fun = pfun1)
)
expect_error(  # the function supplied to `pred.fun` has requirements
  partial(fit, pred.var = "Gr_Liv_Area", pred.grid = grid1, pred.fun = pfun2)
)

# ICE curves constructed manually
pdp_pfun3_ggplot2 <- autoplot(pd_pfun3, center = TRUE, rug = TRUE,
                              train = ames, alpha = 0.1)
pdp_pfun3_lattice <- plotPartial(pd_pfun3, center = TRUE, rug = TRUE,
                                 train = ames, alpha = 0.1)

# Expectation(s)
expect_true(inherits(pdp_pfun3_ggplot2, what = "ggplot"))
expect_true(inherits(pdp_pfun3_lattice, what = "trellis"))

# Display plots side by side
grid.arrange(pdp_pfun3_ggplot2, pdp_pfun3_lattice, nrow = 1)

# c-ICE curves
ice <- partial(fit, pred.var = "Gr_Liv_Area", pred.grid = grid1, ice = TRUE,
               center = TRUE, n.trees = best_iter)
# expect_identical(dim(ice), target = c(6L, 3L))
expect_warning(
  partial(fit, pred.var = "Gr_Liv_Area", pred.grid = grid1, ice = TRUE,
          center = TRUE, n.trees = best_iter)
)

# Users can produce PDPs directly using both lattice (default) and ggplot2
pdp1 <- partial(fit, pred.var = "Gr_Liv_Area", pred.grid = grid1,
                n.trees = best_iter, plot = TRUE)
pdp2 <- partial(fit, pred.var = "Gr_Liv_Area", pred.grid = grid1,
                n.trees = best_iter, plot = TRUE, plot.engine = "ggplot2")
ice1 <- partial(fit, pred.var = "Gr_Liv_Area", pred.grid = grid1, ice = TRUE,
                center = TRUE, n.trees = best_iter, plot = TRUE, alpha = 0.1)
ice2 <- partial(fit, pred.var = "Gr_Liv_Area", pred.grid = grid1, ice = TRUE,
                center = TRUE, n.trees = best_iter, plot = TRUE, alpha = 0.1,
                plot.engine = "ggplot2")
expect_true(inherits(pdp1, what = "trellis"))
expect_true(inherits(pdp2, what = "ggplot"))
expect_true(inherits(ice1, what = "trellis"))
expect_true(inherits(ice2, what = "ggplot"))

# Display plots side by side
grid.arrange(pdp1, pdp2, ice1, ice2, nrow = 2)

# plotPartial() and autoplot() also work with "ice" and "cice" objects
ice <- partial(fit, pred.var = "Gr_Liv_Area", pred.grid = grid1, ice = TRUE,
               n.trees = best_iter)
cice <- partial(fit, pred.var = "Gr_Liv_Area", pred.grid = grid1, ice = TRUE,
                center = TRUE, n.trees = best_iter)
ice_lattice <- plotPartial(ice, alpha = 0.1, center = TRUE)
cice_lattice <- plotPartial(cice, alpha = 0.1)
ice_ggplot2 <- autoplot(ice, alpha = 0.1, center = TRUE)
cice_ggplot2 <- autoplot(cice, alpha = 0.1)
expect_true(inherits(ice_lattice, what = "trellis"))
expect_true(inherits(cice_lattice, what = "trellis"))
expect_true(inherits(ice_ggplot2, what = "ggplot"))
expect_true(inherits(cice_ggplot2, what = "ggplot"))

# Display plots in a grid (all plots should look the same)
grid.arrange(ice_lattice, cice_lattice, ice_ggplot2, cice_ggplot2, nrow = 2)

# Two-predictor partial dependence
pd3 <- partial(fit, pred.var = c("Gr_Liv_Area", "Total_Bsmt_SF"),
               chull = TRUE, n.trees = best_iter)

# Basic expectation(s)
expect_true(inherits(pd3, what = "partial"))
expect_true(ncol(pd3) == 3L)

# Users cannot specify more than one predictor when `ice = TRUE`
expect_error(
  partial(fit, pred.var = c("Gr_Liv_Area", "Total_Bsmt_SF"),
          chull = TRUE, ice = TRUE, n.trees = best_iter)
)

# Plot results
pdp3_lattice <- plotPartial(pd3, rug = TRUE, chull = TRUE, train = ames,
                            contour = TRUE)
pdp3_lattice_3d <- plotPartial(pd3, levelplot = FALSE, shade = TRUE)
pdp3_ggplot2 <- autoplot(pd3, rug = TRUE, train = ames, contour = TRUE)

# Display plots side by side
grid.arrange(pdp3_lattice, pdp3_lattice_3d, pdp3_ggplot2)

# Basic expectation(s)
expect_true(inherits(pdp3_lattice, what = "trellis"))
expect_true(inherits(pdp3_lattice_3d, what = "trellis"))
expect_true(inherits(pdp3_ggplot2, what = "ggplot"))

# Try `plot.engine = "ggplot2"` with different feature type combinations
pdp_ggplot2_cat_cat <- partial(
  object = fit, n.trees = best_iter,
  pred.var = c("Overall_Qual", "Neighborhood"),
  plot = TRUE,
  plot.engine = "ggplot2"
)
pdp_ggplot2_cat_num <- partial(
  object = fit, n.trees = best_iter,
  pred.var = c("Overall_Qual", "Gr_Liv_Area"),
  plot = TRUE,
  plot.engine = "ggplot2"
)
pdp_ggplot2_num_cat <- partial(
  object = fit, n.trees = best_iter,
  pred.var = c("Gr_Liv_Area", "Overall_Qual"),
  plot = TRUE,
  plot.engine = "ggplot2"
)

# Expectation(s)
expect_true(inherits(pdp_ggplot2_cat_cat, what = "ggplot"))
expect_true(inherits(pdp_ggplot2_cat_num, what = "ggplot"))
expect_true(inherits(pdp_ggplot2_num_cat, what = "ggplot"))

# Try `plot.engine = "lattice"` with different feature type combinations
pdp_lattice_cat_cat <- partial(
  object = fit, n.trees = best_iter,
  pred.var = c("Overall_Qual", "Neighborhood"),
  plot = TRUE
)
pdp_lattice_cat_num <- partial(
  object = fit, n.trees = best_iter,
  pred.var = c("Overall_Qual", "Gr_Liv_Area"),
  plot = TRUE
)
pdp_lattice_num_cat <- partial(
  object = fit, n.trees = best_iter,
  pred.var = c("Gr_Liv_Area", "Overall_Qual"),
  plot = TRUE
)

# Expectation(s)
expect_true(inherits(pdp_lattice_cat_cat, what = "trellis"))
expect_true(inherits(pdp_lattice_cat_num, what = "trellis"))
expect_true(inherits(pdp_lattice_num_cat, what = "trellis"))

# Display plots
grid.arrange(pdp_ggplot2_cat_cat, pdp_ggplot2_cat_num, pdp_ggplot2_num_cat,
             pdp_lattice_cat_cat, pdp_lattice_cat_num, pdp_lattice_num_cat,
             nrow = 2)
