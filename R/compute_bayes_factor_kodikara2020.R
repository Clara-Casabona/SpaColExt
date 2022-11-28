#' Title
#'
#' @param sightings
#' @param start_year
#' @param end_year
#' @param dprior_m
#' @param dprior_te
#'
#' @return
#' @export
#'
#' @examples compute_bayes_factor_kodikara2020(sightings = c(1901,1902,1903,1905,1908,1910), start_year = 1900, end_year = 1920, dprior_m =solowdprior_m, dprior_te = solowdprior_te)
compute_bayes_factor_kodikara2020 <- function(sightings, start_year, end_year, dprior_m, dprior_te) {
  t <- (sightings - start_year) / (end_year - start_year)
  #test
  # Likelihood of data given no extinction
  likelyhood_h0 <- function(t) {
    compute_likelyhood_extinction_at_te_kodikara(
      t,
      te = 1,
      dprior_m
    )
  }

  # Likelihood of data given extinction
  likelyhood_h1 <- function(t) {
    integrate(
      Vectorize(
        function(te) {
          compute_likelyhood_extinction_at_te_kodikara(
            t,
            te,
            dprior_m
          ) * dprior_te(te)
        }
      ),
      lower = max(t),
      upper = 1,
      abs.tol = 1e-8
    )$value
  }
  likelyhood_h0(t) / likelyhood_h1(t)
}