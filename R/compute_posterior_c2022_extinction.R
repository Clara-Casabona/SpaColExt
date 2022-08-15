#' Compute  Posterior Extinction with informative priors
#'
#' @param sightings list of observations
#' @param start_year first year of study period
#' @param stop_year  last year of study period
#' @param prior_te   flexible function - add prior extinction rate distribution
#' @param prior_m    flexible function - add prior observation rate distribution
#'
#' @return
#' @export
#'
#' @examples

compute_posterior_c2022_extinction <- function(sightings, start_year, stop_year, prior_te = NULL, prior_m = NULL) {

  if( any(is.na(sightings)) ) return(NA)

  analysis_interval = seq(start_year, stop_year)

  if( length(sightings) < 2) return(analysis_interval*0)  # Not enough observations

  if(is.null(prior_te)) {
    prior_te = function(te) 1
  }

  if(is.null(prior_m)) {
    prior_m = function(m) 1/m
  }

  Vectorize(
    function(t) {
      if (t <= max(sightings)) return(1)
      compute_posterior_solow1993(
        sightings = sightings,
        start_year = start_year,
        end_year = t,
        dprior_m = prior_m,
        dprior_te =  function(te) prior_te(te*(t-start_year)+start_year),
        prior = 0.5
      )
    }
  )(analysis_interval)
}
