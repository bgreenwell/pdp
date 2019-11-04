# Load required packages
library(ggplot2)
library(pdp)

# Set up data set(s) for training
trn <- AmesHousing::make_ames()
X <- subset(ames, select = -Sale_Price)
y <- ames$Sale_Price

# Helper functions
par_dep <- function(object, ...) {
  partial(object, pred.var = "lstat", ...)
}
timeit <- function(expr, digits = 3) {
  secs <- system.time(expr)["elapsed"]
  paste(round(secs, digits = digits), "seconds")
}


# Cross join benchmarks --------------------------------------------------------

# Load required packages
library(microbenchmark)

# Run benchmark
x <- data.frame(x = 1:51)
y <- data.frame(y = rnorm(500), z = rnorm(500))
mb <- microbenchmark(
  merge(x, y, by = NULL),
  pdp:::crossJoin(x, y),
  times = 100L
)
autoplot(mb)


# Package: Cubist --------------------------------------------------------------
# library(Cubist)
# set.seed(1550)
# fit_Cubist <- cubist(X, y = y, committees = 10)
# t1 <- timeit(pd1 <- partial(fit_Cubist, pred.var = "Gr_Liv_Area", gr = 10))
# t2 <- timeit(pd2 <- partial(fit_Cubist, pred.var = "Gr_Liv_Area", gr = 51, in.memory = TRUE))
# grid.arrange(
#   autoplot(pd1) + ggtitle(t1),
#   autoplot(pd2) + ggtitle(t2),
#   nrow = 1
# )

# Package: earth ---------------------------------------------------------------
library(earth)
fit_earth <- earth(Sale_Price ~ ., data = trn, degree = 3)
t1 <- timeit(pd1 <- par_dep(fit_earth, gr = 1000))
t2 <- timeit(pd2 <- par_dep(fit_earth, in.memory = TRUE, gr = 1000))
grid.arrange(
  autoplot(pd1) + ggtitle(t1),
  autoplot(pd2) + ggtitle(t2),
  nrow = 1
)


# Package: randomForest --------------------------------------------------------
library(randomForest)
set.seed(1507)
fit_rfo <- randomForest(Sale_Price ~ ., data = trn)
t1 <- timeit(pd1 <- par_dep(fit_rfo, gr = 1000))
t2 <- timeit(pd2 <- par_dep(fit_rfo, in.memory = TRUE, gr = 1000))
grid.arrange(
  autoplot(pd1) + ggtitle(t1),
  autoplot(pd2) + ggtitle(t2),
  nrow = 1
)


# Package: ranger --------------------------------------------------------------
library(ranger)
set.seed(1403)
fit_ranger <- ranger(cmedv ~ ., data = pdp::boston)
t1 <- timeit(pd1 <- par_dep(fit_ranger, gr = 1000))
t2 <- timeit(pd2 <- par_dep(fit_ranger, in.memory = TRUE, gr = 1000))
grid.arrange(
  autoplot(pd1) + ggtitle(t1),
  autoplot(pd2) + ggtitle(t2),
  nrow = 1
)


# Package: xgboost -------------------------------------------------------------

# Load required packages
library(xgboost)

X.xgb <- model.matrix(Sale_Price ~ . - 1, data = trn)
set.seed(1340)
xgb <- xgboost(  # lazily tuned using autoxgb::autoxgb()
  data = X.xgb,
  label = trn$Sale_Price,
  params = list(
    eta = 0.1,
    max_depth = 6
  ),
  nrounds = 483,
  objective = "reg:squarederror"
)

t1 <- timeit(pd1 <- par_dep(xgb, gr = 1000, train = X.xgb))
t2 <- timeit(pd2 <- par_dep(xgb, in.memory = TRUE, gr = 1000, train = X.xgb))
