context("Utility functions")

# Data frames used in the following tests
pima2 <- na.omit(pima)
set.seed(101)
df.reg <- boston[sample(nrow(boston), size = 40, replace = FALSE), ]
df.class <- pima2[sample(nrow(pima2), size = 40, replace = FALSE), ]

# Switch to generic response names
df.reg$y <- df.reg$cmedv
df.class$y <- df.class$diabetes
df.reg$cmedv <- NULL
df.class$diabetes <- NULL

test_that("copy_classes() works correctly", {

  # Data frame with incorrect classes
  set.seed(101)
  d1 <- data.frame(
    x1 = 1:3 * 1.0,
    x2 = rnorm(3),
    x3 = letters[1:3],
    x4 = as.factor(1:3),
    x5 = as.factor(1:3),
    x6 = c(1, 0, 1),
    stringsAsFactors = TRUE
  )

  # Data frame with correct classes
  set.seed(101)
  d2 <- data.frame(
    x1 = 1:3,
    x2 = rnorm(3),
    x3 = letters[1:3],
    x4 = as.factor(1:3),
    x5 = as.ordered(1:3),
    x6 = c(TRUE, FALSE, TRUE),
    stringsAsFactors = FALSE
  )

  # Copy classes from d2 to d1
  d3 <- copy_classes(d1, d2)
  d4 <- copy_classes(d1[1:2, ], d2)

  # Expectations
  expect_identical(d2, d3)
  expect_identical(sapply(d2, levels), sapply(d4, levels))
  expect_error(copy_classes(data.frame(x0 = 1), d1))

})

test_that("multiclass_logit() works correctly", {

  # Probabilitymatrix/data frame
  pm <- matrix(c(0.1, 0.3, 0.6), nrow = 1, ncol = 3, byrow = TRUE)
  pm.df <- as.data.frame(pm)

  # Expectations
  expect_identical(multiclass_logit(pm), as.numeric(multiclass_logit(pm.df)))
  expect_identical(multiclass_logit(pm, which.class = 1L),
                   log(0.1) - (log(0.1) + log(0.3) + log(0.6)) / 3)
  expect_identical(multiclass_logit(pm, which.class = 2L),
                   log(0.3) - (log(0.1) + log(0.3) + log(0.6)) / 3)
  expect_identical(multiclass_logit(pm, which.class = 3L),
                   log(0.6) - (log(0.1) + log(0.3) + log(0.6)) / 3)

})

test_that("train_chull() works correctly", {

  # Sample data frames
  d1 <- train_chull(pred.var = c("x1", "x2"),
                    pred.grid = expand.grid(x1 = 1:10, x2 = 1:10),
                    train = expand.grid(x1 = 1:5, x2 = 1:5))
  d2 <- train_chull(pred.var = c("x1", "x2"),
                    pred.grid = expand.grid(x1 = factor(1:10), x2 = 1:10),
                    train = expand.grid(x1 = factor(1:5), x2 = 1:5))

  # Expectations
  expect_is(d1, "data.frame")
  expect_identical(d2, expand.grid(x1 = factor(1:10), x2 = 1:10))

})


test_that("trim_outliers() works correctly", {
  expect_equal(pdp:::trim_outliers(c(1:10, 1000)), 1:10)
})


test_that("pred_grid() works correctly", {

  # Create some toy data
  d1 <- data.frame(x1 = c(1, 5, 3), x2 = c(1, 1, 7))
  d2 <- data.frame(x1 = c(1, 5, 3), x2 = as.factor(c(1, 1, 7)))
  d3 <- data.matrix(d1)
  d4 <- data.frame(x1 = c(1, 3, 5, 1, 3, 5), x2 = c(1, 1, 1, 7, 7, 7))
  d5 <- data.frame(x1 = c(1, 3, 5, 1, 3, 5), x2 = as.factor(c(1, 1, 1, 7, 7, 7)))

  # Create grids
  d1.grid <- pred_grid(d1, pred.var = c("x1", "x2"), gr = 3, cats = "x2")
  d2.grid <- pred_grid(d2, pred.var = c("x1", "x2"), gr = 3)
  d3.grid <- pred_grid(d3, pred.var = c("x1", "x2"), gr = 3, cats = "x2")
  d1.grid2 <- pred_grid(d1, pred.var = c("x1", "x2"), cats = "x2",
                        q = TRUE, p = 0.5)
  # Expectations
  expect_identical(d1.grid, d4)
  expect_identical(d3.grid, d4)
  expect_identical(d2.grid, d5)
  expect_identical(d1.grid, d3.grid)
  expect_identical(pred_grid(d1, pred.var = c("x1", "x2"), gr = 3),
                   pred_grid(d3, pred.var = c("x1", "x2"), gr = 3))
  expect_identical(d1.grid2, data.frame(x1 = c(3, 3), x2 = c(1, 7)))

})


test_that("super_type() works correctly", {

  ##############################################################################
  # Warnings and errors
  ##############################################################################
  expect_warning(super_type(1))


  ##############################################################################
  # Linear models
  ##############################################################################

  # Regression
  df.reg.lm <- lm(y ~ ., data = df.reg)

  # Expectations
  expect_identical(super_type(df.reg.lm), "regression")


  ##############################################################################
  # Discriminant analysis
  ##############################################################################

  # Package: MASS --------------------------------------------------------------
  if (require(MASS, quietly = TRUE)) {

    # Classification
    lda.class <- lda(y ~ ., data = df.class)
    qda.class <- qda(y ~ ., data = df.class)

    # Expectations
    expect_identical(super_type(lda.class), "classification")
    expect_identical(super_type(qda.class), "classification")

  }


  ##############################################################################
  # Decision trees
  ##############################################################################

  # Package: rpart -------------------------------------------------------------
  if (require(rpart, quietly = TRUE)) {

    # Classification
    rpart.reg <- rpart(y ~ ., data = df.reg)
    rpart.class <- rpart(y ~ ., data = df.class)

    # Expectations
    expect_identical(super_type(rpart.reg), "regression")
    expect_identical(super_type(rpart.class), "classification")

  }

  # Package: party -------------------------------------------------------------
  if (require(party, quietly = TRUE)) {

    # Classification
    ctree.reg <- ctree(y ~ ., data = df.reg)
    ctree.class <- ctree(y ~ ., data = df.class)

    # Expectations
    expect_identical(super_type(ctree.reg), "regression")
    expect_identical(super_type(ctree.class), "classification")

  }

  # Package: C50 ---------------------------------------------------------------
  if (require(C50, quietly = TRUE)) {

    # Classification
    C5.0.class <- C5.0(y ~ ., data = df.class)

    # Expectations
    expect_identical(super_type(C5.0.class), "classification")

  }


  ##############################################################################
  # Bagging and boosting
  ##############################################################################

  # Package: adabag ------------------------------------------------------------
  if (require(adabag, quietly = TRUE)) {

    # Classification
    df.class.bagging <- bagging(y ~ ., data = df.class, mfinal = 1)
    df.class.boosting <- boosting(y ~ ., data = df.class, mfinal = 1)

    # Expectations
    expect_identical(super_type(df.class.bagging), "classification")
    expect_identical(super_type(df.class.boosting), "classification")

  }

  # Package: ipredbag ----------------------------------------------------------
  if (require(ipred, quietly = TRUE)) {

    # Regression
    df.reg.ipred <- ipred::bagging(y ~ ., data = df.reg, nbagg = 1)

    # Classification
    df.class.ipred <- ipred::bagging(y ~ ., data = df.class, nbagg = 1)

    # Expectations
    expect_identical(super_type(df.reg.ipred), "regression")
    expect_identical(super_type(df.class.ipred), "classification")

  }

  # Package: gbm ---------------------------------------------------------------
  if (require(gbm, quietly = TRUE)) {

    # Regression
    df.reg.gbm <- gbm(y ~ .,
                      data = df.reg,
                      n.trees = 1,
                      distribution = "gaussian",
                      n.minobsinnode = 1)

    # Classification
    df.class.gbm <- gbm(unclass(y) - 1 ~ .,
                        data = df.class,
                        n.trees = 1,
                        distribution = "bernoulli",
                        n.minobsinnode = 1)

    # Expectations
    expect_identical(super_type(df.reg.gbm), "regression")
    expect_identical(super_type(df.class.gbm), "classification")

  }


  ##############################################################################
  # Random forests
  ##############################################################################

  # Package: randomForest ------------------------------------------------------
  if (require(randomForest, quietly = TRUE)) {

    # Regression
    rf.reg <- randomForest(y ~ ., data = df.reg, ntree = 1)

    # Classification
    rf.class <- randomForest(y ~ ., data = df.class, ntree = 1)


    # Expectations
    expect_identical(super_type(rf.reg), "regression")
    expect_identical(super_type(rf.class), "classification")

  }

  # Package: ranger ------------------------------------------------------------
  if (require(ranger, quietly = TRUE)) {

    # Regression
    ranger.reg <- ranger(y ~ ., data = df.reg, num.trees = 1)

    # Classification
    ranger.class <- ranger(y ~ ., data = df.class, num.trees = 1)


    # Expectations
    expect_identical(super_type(ranger.reg), "regression")
    expect_identical(super_type(ranger.class), "classification")

  }

  # Package: party -------------------------------------------------------------
  if (require(party, quietly = TRUE)) {

    # Regression
    crf.reg <- cforest(y ~ ., data = df.reg,
                       controls = cforest_unbiased(ntree = 1))

    # Classification
    crf.class <- cforest(y ~ ., data = df.class,
                         controls = cforest_unbiased(ntree = 1))

    # Expectations
    expect_identical(super_type(crf.reg), "regression")
    expect_identical(super_type(crf.class), "classification")

  }


  ##############################################################################
  # Multivariate adaptive regression splines
  ##############################################################################

  # Package: earth -------------------------------------------------------------
  if (require(earth, quietly = TRUE)) {

    # Regression
    df.reg.earth <- earth(y ~ .,
                          data = df.reg,
                          degree = 1,
                          linpreds =  TRUE)

    # Classification
    df.class.earth <- earth(y ~ .,
                            data = df.class,
                            degree = 1,
                            linpreds = TRUE,
                            glm = list(family = binomial))

    # Expectations
    expect_identical(super_type(df.reg.earth), "regression")
    expect_identical(super_type(df.class.earth), "classification")

  }


  ##############################################################################
  # Generalized linear models
  ##############################################################################

  # Package: stats -------------------------------------------------------------

  # Regression
  df.reg.glm <- glm(y ~ .,
                    data = df.reg,
                    family = gaussian)

  # Classification
  df.class.glm <- glm(y ~ .,
                      data = df.class,
                      family = binomial)

  # Package: glmnet ------------------------------------------------------------


  ##############################################################################
  # Random forests
  ##############################################################################

  # Package: randomForest ------------------------------------------------------
  if (require(randomForest, quietly = TRUE)) {

    # Regression
    set.seed(101)
    rf.reg <- randomForest(y ~ .,
                           data = df.reg,
                           ntrees = 1)

    # Classification
    set.seed(101)
    rf.class <- randomForest(y ~ .,
                             data = df.class,
                             ntrees = 1)

    # Unsupervised mode
    set.seed(101)
    rf.other <- randomForest( ~ .,
                              data = df.class)

    # Expectations
    expect_identical(super_type(rf.reg), "regression")
    expect_identical(super_type(rf.class), "classification")
    expect_identical(super_type(rf.other), "unsupervised")

  }


  ##############################################################################
  # Support vector machines
  ##############################################################################

  # Package: e1071 -------------------------------------------------------------
  #if (require(e1071, quietly = TRUE)) {
  #
  #  # Regression
  #  svm.reg <- svm(y ~ ., data = df.reg)
  #
  #  # Classification
  #  svm.class <- svm(y ~ ., data = df.class)
  #
  #  # Expectations
  #  expect_identical(super_type(svm.reg), "regression")
  #  expect_identical(super_type(svm.class), "classification")
  #
  #}

  # Package: kernlab -----------------------------------------------------------
  if (require(kernlab, quietly = TRUE)) {

    # Regression
    ksvm.reg <- ksvm(y ~ ., data = df.reg)

    # Classification
    ksvm.class <- ksvm(y ~ ., data = df.class)

    # Expectations
    expect_identical(super_type(ksvm.reg), "regression")
    expect_identical(super_type(ksvm.class), "classification")

  }

})
