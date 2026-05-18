#' Posterior extinction under a non-homogeneous fixed-alpha model by end year
#'
#' @param sightings Numeric vector of sighting years.
#' @param start_year First year of the study period.
#' @param stop_year Last year of the study period.
#' @param alpha Fixed shape parameter for the non-homogeneous process.
#'
#' @return Numeric vector of posterior extant probabilities by year.
#' @export
#'
posterior_extinction_non_homogeneous_fixed_alpha_varying_end_year = function(sightings, start_year, stop_year, alpha) {

  if( any(is.na(sightings)) ) return(NA)

  analysis_interval = seq(start_year, stop_year)

  if( length(sightings) < 2) return(analysis_interval = NA)  # Not enough observations

  Vectorize(
    function(t) {
      if (t <= max(sightings)) return(1)
      compute_posterior_non_homogeneous_fixed_alpha(
        sightings = sightings,
        start_year = start_year,
        end_year = t,
        dprior_m = solowdprior_m,
        dprior_te = solowdprior_te,
        prior = 0.5,
        alpha =alpha
      )
    }
  )(analysis_interval)

}

#' @rdname posterior_extinction_non_homogeneous_fixed_alpha_varying_end_year
#' @export
posterior_extinction_non_homogeneos_fixed_alpha_varying_end_year = function(sightings, start_year, stop_year, alpha) {
  .Deprecated("posterior_extinction_non_homogeneous_fixed_alpha_varying_end_year")
  posterior_extinction_non_homogeneous_fixed_alpha_varying_end_year(
    sightings = sightings,
    start_year = start_year,
    stop_year = stop_year,
    alpha = alpha
  )
}
