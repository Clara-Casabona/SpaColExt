if (requireNamespace("testthat", quietly = TRUE)) {
  library(testthat)
  library(SpaColExt)

  test_check("SpaColExt")
} else {
  message("Package `testthat` is not available; skipping tests.")
}
