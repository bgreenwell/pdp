# Load required packages
library(ggplot2)
library(pdp)
library(randomForest)

# Load Boston housing data
data(boston)

# Fit a random forest model
set.seed(101)
boston.rf <- randomForest(cmedv ~ ., data = boston)

# One predictor PDP (numeric)
boston.rf %>%
  partial(pred.var = "lstat") %>%
  autoplot(smooth = TRUE, rug = TRUE, train = boston, main = "numeric")

# One predictor PDP (factor)
boston.rf %>%
  partial(pred.var = "chas") %>%
  autoplot(smooth = TRUE, rug = TRUE, train = boston, main = "factor")

# Two predictor PDP (numeric/numeric)
boston.rf %>%
  partial(pred.var = c("lstat", "rm"), chull = TRUE) %>%
  autoplot(contour = TRUE, main = "numeric/numeric", legend.title = "cmedv")

# Two predictor PDP (numeric/factor)
boston.rf %>%
  partial(pred.var = c("lstat", "chas"), chull = TRUE) %>%
  autoplot(contour = TRUE, main = "numeric/factor")

# Two predictor PDP (factor/numeric)
boston.rf %>%
  partial(pred.var = c("chas", "lstat"), chull = TRUE) %>%
  autoplot(contour = TRUE, main = "factor/numeric")

# ICE curves (numeric)
boston.rf %>%
  partial(pred.var = "lstat", ice = TRUE) %>%
  autoplot(alpha = 0.1, main = "ICE curves")

# c-ICE curves (numeric)
boston.rf %>%
  partial(pred.var = "lstat", ice = TRUE) %>%
  autoplot(center = TRUE, alpha = 0.1, main = "c-ICE curves")

# c-ICE curves (numeric)
boston.rf %>%
  partial(pred.var = "lstat", ice = TRUE, center = TRUE) %>%
  autoplot(alpha = 0.1, main = "c-ICE curves")

# ICE curves (factor)
boston.rf %>%
  partial(pred.var = "chas", ice = TRUE) %>%
  autoplot(alpha = 0.1, main = "ICE curves")

# c-ICE curves (factor)
boston.rf %>%
  partial(pred.var = "chas", ice = TRUE, center = TRUE) %>%
  autoplot(alpha = 0.1, main = "ICE curves")
