# Setup
data(mtcars)
library(gbm)
library(ggplot2)
library(pdp)
library(xgboost)
set.seed(101)
bst <- xgboost(data = as.matrix(mtcars[, -11]), label = mtcars[, 11],
               objective = "count:poisson", nrounds = 50)

# PDP prediction function for XGBoost with Poisson deviance
pfun <- function(object, newdata) {
  mean(exp(predict(object, newdata = as.matrix(newdata))))
}

# Passing user-specified prediction function
p1 <- bst %>%
  partial(pred.var = "mpg", pred.fun = pfun, train = mtcars[, -11]) %>%
  autoplot(main = "Count scale using pred.fun") +
  ylab("Number of carburetors") +
  theme_light()

# Passing a function to `inv.link`
p2 <- bst %>%
  partial(pred.var = "mpg", inv.link = exp, train = mtcars[, -11],
          recursive = FALSE) %>%
  autoplot(main = "Count scale using inv.link: function") +
  ylab("Number of carburetors") +
  theme_light()

# Passing a character string to `inv.link`
p3 <- bst %>%
  partial(pred.var = "mpg", inv.link = "exp", train = mtcars[, -11],
          recursive = FALSE) %>%
  autoplot(main = "Count scale using inv.link: character string") +
  ylab("Number of carburetors") +
  theme_light()

# Passing NULL
p4 <- bst %>%
  partial(pred.var = "mpg", train = mtcars[, -11]) %>%
  autoplot(main = "Default scale") +
  ylab("Number of carburetors") +
  theme_light()

# Compare plots
grid.arrange(p1, p2, p3, p4, ncol = 2)

# Fit a gbm model
set.seed(101)
mtcars.gbm <- gbm(carb ~ ., data = mtcars, distribution = "poisson",
                  n.trees = 2000, interaction.depth = 3, shrinkage = 0.01,
                  bag.fraction = 1.0, cv.folds = 5)
best.iter <- gbm.perf(mtcars.gbm, method = "cv")
summary(mtcars.gbm, n.trees = best.iter, las = 1)

# Log scale
plot(mtcars.gbm, i.var = "mpg", main = "Log scale")
partial(mtcars.gbm, pred.var = "mpg", n.trees = best.iter, plot = TRUE,
        plot.engine = "ggplot2") +
  ggtitle("Log scale")

# Response scale
par(mfrow = c(1, 2))
plot(mtcars.gbm, i.var = "mpg", type = "link", main = "link")
plot(mtcars.gbm, i.var = "mpg", type = "response", main = "response")
grid.arrange(
  partial(mtcars.gbm, pred.var = "mpg", recursive = FALSE,
          n.trees = best.iter, plot = TRUE, plot.engine = "ggplot2") +
    ggtitle("Link scale"),
  partial(mtcars.gbm, pred.var = "mpg", recursive = FALSE, inv.link = exp,
          n.trees = best.iter, plot = TRUE, plot.engine = "ggplot2") +
    ggtitle("Response scale"),
  ncol = 2
)
