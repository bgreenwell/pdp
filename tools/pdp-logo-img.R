# Load required packages
library(ggimage)
library(ggplot2)
library(grid)
library(pdp)
library(png)
library(randomForest)

# Fit a random forest to the Boston housing data
data (boston)  # load the boston housing data
set.seed(101)  # for reproducibility
boston.rf <- randomForest(cmedv ~ ., data = boston)

# Partial dependence of cmedv on lstat and rm
pd <- partial(boston.rf, pred.var = c("lstat", "rm"), chull = TRUE,
              progress = "text")

# Create image for logo (i.e., remove axis labels, etc.)
p <- autoplot(pd, contour = TRUE, contour.color = "black") +
  # annotate("text", label = "pdp",
  #          x = mean(range(boston$lstat)),
  #          y = mean(range(boston$rm)),
  #          size = 15,
  #          color = "white") +
  theme(axis.line = element_blank(),
        axis.text.x = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks = element_blank(),
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        legend.position = "none",
        panel.background = element_blank(),
        panel.border = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        plot.background = element_blank())
print(p)  # text will look smaller

# # Save logo image
# ggsave("/home/w108bmg/Desktop/Dropbox/devel/pdp/tools/pdp-logo-img.png",
#        plot = pdp,
#        device = NULL,
#        path = NULL,
#        scale = 1,
#        width = 1.7321,
#        height = 2,
#        units = "in",
#        dpi = 300,
#        limitsize = TRUE)
#
# # Load vip image
# img <- rasterGrob(readPNG("tools/pdp-logo-img.png"),
#                   interpolate = TRUE, width = 1)

# Hexagon data
hex <- data.frame(x = 1.35 * 1 * c(-sqrt(3) / 2, 0, rep(sqrt(3) / 2, 2), 0,
                                   rep(-sqrt(3) / 2, 2)),
                  y = 1.35 * 1 * c(0.5, 1, 0.5, -0.5, -1, -0.5, 0.5))

# Color palettes
greens <- RColorBrewer::brewer.pal(9, "Greens")

# Hexagon logo
g <- ggplot() +
  geom_polygon(data = hex, aes(x, y), color = "black", fill = "white", size = 3) +
  geom_subview(subview = p, x = 0, y = 0, width = 2, height = 2) +
  annotate(geom = "text", x = 0, y = 0, color = "white", size = 8,
           label = "pdp", family = "Open Sans Light") +
  coord_equal(xlim = range(hex$x), ylim = range(hex$y)) +
  scale_x_continuous(expand = c(0.04, 0)) +
  scale_y_reverse(expand = c(0.04, 0)) +
  theme_void() +
  theme_transparent() +
  theme(axis.ticks.length = unit(0, "mm"))
print(g)

png("tools/pdp-logo.png", width = 181, height = 209, bg = "transparent", type = "cairo-png")
print(g)
dev.off()

svg("tools/pdp-logo.svg", width = 181 / 72, height = 209 / 72, bg = "transparent")
print(g)
dev.off()
