# Load required packages
library(ggplot2)
library(grid)
library(pdp)
library(png)
library(randomForest)

# Training data
# set.seed(949)
# trn <- as.data.frame(mlbench::mlbench.friedman1(n = 1000))
# trn <- as.data.frame(mlbench::mlbench.friedman2(n = 1000, sd = 125))
trn <- pdp::boston

# Fit a random forest
set.seed(101)  # for reproducibility
rfo <- randomForest(cmedv ~ ., data = trn)

# Used MARS algorithm to find potential interaction effects
# mars <- earth::earth(cmedv ~ ., data = trn, degree = 2,
#                      pmethod = "exhaustive", nfold = 5, ncross = 5)
# coef(mars)

# Rescale vector to line in the interval [a, b]
rescale <- function(x, a, b) {
  ((x - min(x)) / (max(x) - min(x))) * (b - a) + a
}

# Partial dependence of cmedv on lstat and rm
pd <- partial(rfo, pred.var = c("lstat", "rm"), chull = FALSE,
              progress = "text", grid.resolution = 100)

# Boundaries of the hexagon
hex <- data.frame(x = 1.35 * 1 * c(-sqrt(3) / 2, 0, rep(sqrt(3) / 2, 2), 0,
                                   rep(-sqrt(3) / 2, 2)),
                  y = 1.35 * 1 * c(0.5, 1, 0.5, -0.5, -1, -0.5, 0.5))

# Restrict PDP to the boundaries of the hexagon
pd_hex <- pd
pd_hex$lstat <- rescale(pd_hex$lstat, a = min(hex$x), b = max(hex$x))
pd_hex$rm <- rescale(pd_hex$rm, a = min(hex$y), b = max(hex$y))
pd_hex <- pd_hex[mgcv::in.out(as.matrix(hex), as.matrix(pd_hex[, 1L:2L])), ]

# Hexagon logo
make_pdp_sticker <- function(option, ...) {
  ggplot(pd_hex, aes(lstat, rm)) +
    geom_polygon(data = hex, aes(x, y), color = "black", fill = grey(0.25),
                 size = 3) +
    geom_tile(data = pd_hex, aes(x = lstat, y = rm, z = yhat, fill = yhat)) +
    # scale_fill_distiller(name = "yhat", palette = "Spectral") +
    viridis::scale_fill_viridis(option = option, ...) +
    geom_polygon(data = hex, aes(x, y), color = "black", fill = "transparent",
                 size = 3) +
    geom_contour(aes(z = yhat), color = "black") +
    annotate(geom = "text", x = 0, y = -0.15, color = "white", size = 18,
             label = "pdp") +
    coord_equal(xlim = range(hex$x), ylim = range(hex$y)) +
    scale_x_continuous(expand = c(0.04, 0)) +
    scale_y_reverse(expand = c(0.04, 0)) +
    theme(axis.line = element_blank(),
          axis.text.x = element_blank(),
          axis.text.y = element_blank(),
          axis.ticks = element_blank(),
          axis.title.x = element_blank(),
          axis.title.y = element_blank(),
          legend.position = "none",
          plot.background = element_blank(),
          panel.background = element_blank(),
          panel.border = element_blank(),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank())
}

# Plot range of different logos
logos <- lapply(LETTERS[1L:5L], FUN = make_pdp_sticker, begin = 0.2)
png("man/figures/pdp-logos.png", width = 900, height = 500, bg = "transparent",
    type = "cairo-png")
grid.arrange(grobs = logos, ncol = 3)
dev.off()

# Print hexagon logo
pdp_logo <- make_pdp_sticker(option = "C", begin = 0.2)
print(pdp_logo)

png("man/figures/pdp-logo.png", width = 181, height = 209, bg = "transparent", type = "cairo-png")
print(pdp_logo)
dev.off()

svg("man/figures/pdp-logo.svg", width = 181 / 72, height = 209 / 72, bg = "transparent")
print(pdp_logo)
dev.off()
