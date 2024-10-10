#' Compute Posterior non homogeneous fixed alpha
#'
#' @param sightings
#' @param start_year
#' @param end_year
#' @param prior
#' @param alpha
#'
#' @return
#' @export
#'
#' @examples
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
