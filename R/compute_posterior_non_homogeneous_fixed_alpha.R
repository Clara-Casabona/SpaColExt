#' Compute Posterior non homogeneous fixed alpha
#'
#' @param sightings Numeric vector of sighting years.
#' @param start_year First year of the study period.
#' @param end_year Last year of the study period.
#' @param dprior_m Function for the prior distribution of observation rate.
#' @param dprior_te Function for the prior distribution of extinction time.
#' @param prior Prior probability that the species is extant.
#' @param alpha Fixed shape parameter for the non-homogeneous process.
#'
#' @return Posterior probability that the species is extant.
#' @export
#'
compute_posterior_non_homogeneous_fixed_alpha = function(sightings, start_year, end_year,dprior_m,  dprior_te, prior = 0.5,alpha) {
  bayes_factor = compute_bayes_factor_kodikara2020_fixed_alpha(
    sightings = sightings,
    start_year = start_year,
    end_year = end_year,
    dprior_m = dprior_m,
    dprior_te = dprior_te,
    alpha = alpha
  )

  compute_posterior_from_bayes_solow1993(bayes_factor, prior = prior)

}
