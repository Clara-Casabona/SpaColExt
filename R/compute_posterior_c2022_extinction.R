#' Compute Posterior extant probability with new TE prior
#'
#' @param sightings matrix array with years by cell
#' @param start_year  Start of the study period
#' @param stop_year   End of the study period
#' @param extinction_posteriorLevel Posterior extant probability of a higher spatial level analysis
#'
#' @return the posterior extrant probability of an species by location
#' @export
#'
#' @examples
#'
compute_posterior_c2022_extinction = function(sightings,start_year, stop_year, extinction_posteriorLevel) {
  apply(
    sightings,
    c(1, 2),
    function(s) {
      s = unlist(s)

      if( any(is.na(s)) ) return(NA)

      analysis_interval = seq(start_year, stop_year)

      if( length(s) < 2) return(analysis_interval*0)  # Not enough observations

      as.vector(Vectorize(
        function(t) {
          if (t <= max(s)) return(1)
          compute_posterior_solow1993(
            sightings = s,
            start_year = start_year,
            end_year = t,
            dprior_m = function(m) m ,
            dprior_te =  level_prior_te,
            prior = 0.5
          )
        }, SIMPLIFY = FALSE
      )(analysis_interval))
    }
  )
}
