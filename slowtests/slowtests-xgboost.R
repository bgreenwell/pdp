#-------------------------------------------------------------------------------
#
# Slow tests for the pdp package
#
# Description: Testing pdp with XGBoost using three different training data
# formats:
#
#   (1) "matrix" - base R;
#   (2) "dgCMatrix" - sparse matrix format from package Matrix;
#   (3) "xgb.DMatrix" - XGBoost matrix format.
#
# WARNING: This is simply a test file. These models are not trained to be
# "optimal" in any sense.
#
#-------------------------------------------------------------------------------

# Load required packages
library(ggplot2)
library(Matrix)
library(pdp)
library(xgboost)

# Load the data
data(pima)  # xgboost can handle missing values, so no need for na.omit()

# Set up training data
X <- subset(pima, select = -diabetes)
X.matrix <- data.matrix(X)
X.dgCMatrix <- as(data.matrix(X), "dgCMatrix")
y <- ifelse(pima$diabetes == "pos", 1, 0)

# List of parameters for XGBoost
plist <- list(
  max_depth = 3,
  eta = 0.01,
  objective = "binary:logistic",
  eval_metric = "auc"
)

# Fit an XGBoost model with trainind data stored as a "matrix"
set.seed(101)
bst.matrix <- xgboost(data = X.matrix, label = y, params = plist, nrounds = 100,
                      save_period = NULL)

# Fit an XGBoost model with trainind data stored as a "dgCMatrix"
set.seed(101)
bst.dgCMatrix <- xgboost(data = X.dgCMatrix, label = y, params = plist,
                         nrounds = 100, save_period = NULL)

# Fit an XGBoost model with trainind data stored as an "xgb.DMatrix"
set.seed(101)
bst.xgb.DMatrix <- xgboost(data = xgb.DMatrix(data.matrix(X), label = y),
                           params = plist, nrounds = 100, save_period = NULL)

# Function to construct a PDP for glucose on the probability scale
parDepPlot <- function(object, train, ...) {
  pd <- partial(object, pred.var = "glucose", prob = TRUE, train = train)
  label <- paste(deparse(substitute(object)), "with", deparse(substitute(train)))
  autoplot(pd, main = label) +
    theme_light()
}

# Try all nine combinations (should all look exactly the same!)
gridExtra::grid.arrange(
  parDepPlot(bst.matrix, train = X),
  parDepPlot(bst.matrix, train = X.matrix),
  parDepPlot(bst.matrix, train = X.dgCMatrix),
  parDepPlot(bst.dgCMatrix, train = X),
  parDepPlot(bst.dgCMatrix, train = X.matrix),
  parDepPlot(bst.dgCMatrix, train = X.dgCMatrix),
  parDepPlot(bst.xgb.DMatrix, train = X),
  parDepPlot(bst.xgb.DMatrix, train = X.matrix),
  parDepPlot(bst.xgb.DMatrix, train = X.dgCMatrix),
  ncol = 3
)
