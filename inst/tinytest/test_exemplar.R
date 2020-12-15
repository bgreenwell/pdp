# Generate some sample data
df1 <- data.frame(
  x = sample(1L:3L, size = 100, replace = TRUE, prob = c(0.1, 0.1, 0.8)),
  y = sample(letters[1L:3L], size = 100, replace = TRUE,
             prob = c(0.1, 0.1, 0.8)),
  z = sample(c(Sys.Date(), Sys.Date() + 1, Sys.Date() + 2), size = 100,
             replace = TRUE, prob = c(0.1, 0.1, 0.8))
)

# Data frame that pdp::exemplar() should return
df2 <- data.frame(x = 3L, y = "c", z = Sys.Date() + 2)

# Expectation(s)
df3 <- exemplar(df1)
expect_equal(exemplar(df1), target = df2)
