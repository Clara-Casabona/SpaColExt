#' Compute Posterior using Non homogeneous observation rate
#'
#' @param sightings sequence of years with observations in a vector
#' @param start_year starting study period
#' @param end_year   ending study period
#' @param dprior_m  function to estimate the prior observation rate m
#' @param dprior_te function to estimate the prior extinction time
#' @param prior     extinction time probability, usually fix to 0.5 but can be between 0 and 1
#'
#' @return Posterior distribution of the extant probability of a species during the study period
#' @export
#'
#' @examples
#'compute_posterior_non_homogeneous(sightings = c(1901,1902,1903,1905,1908,1910), start_year = 1900, end_year = 1920, dprior_m = solowdprior_m,  dprior_te = solowdprior_te, prior = 0.5)

compute_posterior_non_homogeneous = function(sightings, start_year, end_year, dprior_m,  dprior_te, prior = 0.5) {
  bayes_factor = compute_bayes_factor_kodikara2020(
    sightings = sightings,
    start_year = start_year,
    end_year = end_year,
    dprior_m = dprior_m,
    dprior_te = dprior_te
  )
  compute_posterior_from_bayes_solow1993(bayes_factor, prior = prior)
}
