## ----setup, include=FALSE-----------------------------------------------------
# Set global knitr chunk options
knitr::opts_chunk$set(
  cache = TRUE,
  fig.width = 6,
  fig.asp = 0.618,
  out.width = "100%",
  fig.align = "center",
  fig.pos = "!htb",
  message = FALSE,
  warning = FALSE
)


## ----boston-vip, fig.cap="Dotchart of variable importance scores for the Boston housing data based on a random forest with 500 trees."----
library(randomForest)  # for randomForest, partialPlot, and varImpPlot functions

data(boston, package = "pdp")  # load the (corrected) Boston housing data

# Fit a default random forest to the Boston housing data
set.seed(101)  # for reproducibility
boston.rf <- randomForest(cmedv ~ ., data = boston, importance = TRUE)
varImpPlot(boston.rf)  # Figure 1

