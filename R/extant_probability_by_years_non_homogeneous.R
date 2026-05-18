#' Extant posterior probability sequence by year following a non-homogeneous process
#'
#' @param start_year  Year at which we want to estimate the extant posterior probability
#' @param stop_year   Year at which we stop to estimate the extant  posterior probability
#' @param sightings   Vector with the years with  observations
#'
#' @return Vector with the extant probabilities
#' @export
#'
#'
posterior_probability_extinction_non_homogeneous_varying_end_year = function(sightings, start_year, stop_year) {

  if( any(is.na(sightings)) ) return(NA)

  analysis_interval = seq(start_year, stop_year)

   if( length(sightings) < 2) return(analysis_interval = NA)  # Not enough observations

   Vectorize(
    function(t) {
      if (t <= max(sightings)) return(1)
      compute_posterior_non_homogeneous(
        sightings = sightings,
        start_year = start_year,
        end_year = t,
        dprior_m = solowdprior_m,
        dprior_te = solowdprior_te,
        prior = 0.5
      )
    }
  )(analysis_interval)

}

#' @rdname posterior_probability_extinction_non_homogeneous_varying_end_year
#' @export
posterior_probability_extinction_non_homogeneos_varying_end_year = function(sightings, start_year, stop_year) {
  .Deprecated("posterior_probability_extinction_non_homogeneous_varying_end_year")
  posterior_probability_extinction_non_homogeneous_varying_end_year(
    sightings = sightings,
    start_year = start_year,
    stop_year = stop_year
  )
}
