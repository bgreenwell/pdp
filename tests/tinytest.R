# Run tests in local environment
if (requireNamespace("tinytest", quietly = TRUE)) {
  home <- tinytest::at_home()
  tinytest::test_package("pdp", at_home = home)
}
