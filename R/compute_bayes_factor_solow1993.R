#' Computes the Bayes factor from Solow 1993
#'
#' @param sightings input vector with years
#' @param start_year numeric value that equals to 1 year before the first sighting
#' @param end_year   numeric value of the ending  study period
#' @param dprior_m   function of the prior observation rate m
#' @param dprior_te  function of the prior extinction time
#'
#' @return The Bayes factor between the species still extant / species going extinct
#' @export
#'
#' @examples
#' compute_bayes_factor_solow1993(sightings = c(1901,1902,1903,1905,1908,1910), start_year = 1900, end_year = 1920, dprior_m = function(m) 1 / m, dprior_te = function(te) 1)
#'
compute_bayes_factor_solow1993 <- function(sightings, start_year, end_year, dprior_m, dprior_te) {
  t <- (sightings - start_year) / (end_year - start_year)

  # Likelihood of data given no extinction
  likelyhood_h0 <- function(t) {
    compute_likelyhood_extinction_at_te(
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
          compute_likelyhood_extinction_at_te(
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
