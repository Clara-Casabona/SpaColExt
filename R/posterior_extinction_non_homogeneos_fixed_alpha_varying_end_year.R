#' Posterior extinction non homogeneos fixed alpha varying end year
#'
#' @param sightings
#' @param start_year
#' @param stop_year
#' @param alpha
#'
#' @return
#' @export
#'
#' @examples
posterior_extinction_non_homogeneos_fixed_alpha_varying_end_year = function(sightings, start_year, stop_year,alpha) {

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
