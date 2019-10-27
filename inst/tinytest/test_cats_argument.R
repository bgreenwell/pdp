# Setup ------------------------------------------------------------------------

# Load Friedman 1 benchmark data
friedman1 <- readRDS("friedman.rds")$friedman1

# Convert x.4 to categorical
friedman1$x.4 <- cut(friedman1$x.4, breaks = 2, labels = letters[1L:2L])

# Create a copy of friedman1 and coerce x.4 to character
friedman2 <- friedman1
friedman2$x.4 <- as.character(friedman2$x.4)

# Create a copy of friedman1 and coerce it to a matrix
friedman3 <- data.matrix(friedman1)
friedman3[, "x.4"] <- friedman3[, "x.4"] - 1

# Feature matrix and response vector
X <- friedman3[, paste0("x.", 1L:10L)]
y <- friedman3[, "y"]

# Test that character columns are properly handled for data frames -------------

if (require(rpart, quietly = TRUE)) {

  # Fit decision trees
  tree1 <- rpart::rpart(y ~ ., data = friedman1, control = list(cp = 0))
  tree2 <- rpart::rpart(y ~ ., data = friedman2, control = list(cp = 0))
  expect_identical(tree1$variable.importance, tree2$variable.importance)

  # Compute partial dependence
  pd_tree1 <- partial(tree1, pred.var = "x.4")
  pd_tree2 <- partial(tree2, pred.var = "x.4")

  # Expectations
  expect_true(inherits(friedman1$x.4, what = "factor"))
  expect_true(inherits(friedman2$x.4, what = "character"))
  expect_identical(pd_tree1$yhat, pd_tree2$yhat)

}


# Test that cats argument works properly for matrices --------------------------

# FIXME: When is the cats argument actually necessary?

if (require(randomForest, quietly = TRUE)) {

  # Fit default random forests
  set.seed(0825)
  rfo1 <- randomForest::randomForest(y ~ ., data = friedman1)
  rfo2 <- randomForest::randomForest(x = X, y = y)

  # Compute partial dependence
  pd_rfo1 <- partial(rfo1, pred.var = "x.4")
  pd_rfo2 <- partial(rfo2, pred.var = "x.4", train = X, cats = "x.4")

  # Expectations
  expect_identical(pd_tree1$yhat, pd_tree2$yhat)

}
