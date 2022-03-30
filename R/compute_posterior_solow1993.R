#' Title
#'
#' @param sightings sequence of years with observations in a vector
#' @param start_year starting study period
#' @param end_year   ending study period
#' @param dprior_m  function to estimate the prior observation rate m
#' @param dprior_te function to estimate the prior extinction time
#' @param prior     extinction time probability, usually fix to 0.5
#'
#' @return Posterior distribution of the extant probability of a species during the study period
#' @export
#'
#' @examples
#'
compute_posterior_solow1993 = function(sightings, start_year, end_year, dprior_m = function(m) 1 / m,  dprior_te = function(te) 1,
  prior = 0.5
) {
  bayes_factor = compute_bayes_factor_solow1993(
    sightings = sightings,
    start_year = start_year,
    end_year = end_year,
    dprior_m = dprior_m,
    dprior_te = dprior_te
  )
  compute_posterior_from_bayes_solow1993(bayes_factor, prior = prior)
}
