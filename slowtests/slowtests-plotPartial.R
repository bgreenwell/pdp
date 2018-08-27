# Load required packages
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
  plotPartial(smooth = TRUE, rug = TRUE, train = boston, main = "numeric")

# One predictor PDP (factor)
boston.rf %>%
  partial(pred.var = "chas") %>%
  plotPartial(smooth = TRUE, rug = TRUE, train = boston, main = "factor")

# Two predictor PDP (numeric/numeric)
boston.rf %>%
  partial(pred.var = c("lstat", "rm"), chull = TRUE) %>%
  plotPartial(contour = TRUE, main = "numeric/numeric")

# Two predictor PDP (numeric/factor)
boston.rf %>%
  partial(pred.var = c("lstat", "chas"), chull = TRUE) %>%
  plotPartial(contour = TRUE, main = "numeric/factor")

# Two predictor PDP (factor/numeric)
boston.rf %>%
  partial(pred.var = c("chas", "lstat"), chull = TRUE) %>%
  plotPartial(contour = TRUE, main = "factor/numeric")

# ICE curves (numeric)
boston.rf %>%
  partial(pred.var = "lstat", ice = TRUE) %>%
  plotPartial(alpha = 0.1, main = "ICE curves")

# c-ICE curves (numeric)
boston.rf %>%
  partial(pred.var = "lstat", ice = TRUE) %>%
  plotPartial(center = TRUE, alpha = 0.1, main = "c-ICE curves")

# c-ICE curves (numeric)
boston.rf %>%
  partial(pred.var = "lstat", ice = TRUE, center = TRUE) %>%
  plotPartial(alpha = 0.1, main = "c-ICE curves")

# ICE curves (factor)
boston.rf %>%
  partial(pred.var = "chas", ice = TRUE) %>%
  plotPartial(alpha = 0.1, main = "ICE curves")

# c-ICE curves (factor)
boston.rf %>%
  partial(pred.var = "chas", ice = TRUE, center = TRUE) %>%
  plotPartial(alpha = 0.1, main = "ICE curves")
