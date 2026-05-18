# Validation script for SpaColExt
# Run from the project root:
# source("scripts/validate_package.R")

cat("\n== SpaColExt validation ==\n")
cat("Working directory:", getwd(), "\n")
cat("R version:", R.version.string, "\n\n")

cat("== Loading development package ==\n")
if (!requireNamespace("pkgload", quietly = TRUE)) {
  install.packages("pkgload", repos = "https://cloud.r-project.org")
}
pkgload::load_all(".", quiet = TRUE)
cat("Package loaded.\n\n")

cat("== Smoke test: Solow 1993 posterior ==\n")
sightings <- c(1901, 1902, 1903, 1905, 1908, 1910)
posterior <- compute_posterior_solow1993(
  sightings = sightings,
  start_year = 1900,
  end_year = 1920,
  dprior_m = solowdprior_m,
  dprior_te = solowdprior_te,
  prior = 0.5
)
print(posterior)
stopifnot(isTRUE(all.equal(posterior, 0.1388889, tolerance = 1e-7)))
cat("Solow 1993 posterior OK.\n\n")

cat("== Smoke test: posterior by year ==\n")
posterior_by_year <- posterior_probability_extinction_varying_end_year(
  sightings = sightings,
  start_year = 1900,
  stop_year = 1920
)
print(data.frame(year = 1900:1920, extant_probability = posterior_by_year))
stopifnot(length(posterior_by_year) == 21)
stopifnot(all(posterior_by_year >= 0 & posterior_by_year <= 1))
cat("Posterior by year OK.\n\n")

cat("== Running testthat tests ==\n")
if (!requireNamespace("testthat", quietly = TRUE)) {
  install.packages("testthat", repos = "https://cloud.r-project.org")
}
testthat::test_local()
cat("testthat validation OK.\n\n")

cat("== Optional full package check ==\n")
cat("Run these lines manually if you want the full R CMD check from the console:\n")
cat("system('R CMD build .')\n")
cat("system('R CMD check --no-manual SpaColExt_0.1.0.tar.gz')\n")

cat("\nValidation script completed.\n")
