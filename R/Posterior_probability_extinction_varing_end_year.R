#' Extant Posterior Probability sequence by years
#'
#' @param start_year  Year at which we want to estimate the extant posterior probability
#' @param stop_year   Year at which we stop to estimate the extant  posterior probability
#' @param sightings   Vector with the years with  observations
#'
#' @return Vector with the extant probabilities
#' @export
#'
#' @examples
#' Posterior_probability_extinction_varying_end_year(sightings = c(1898, 1899, 1900, 1901, 1902, 1904, 1905, 1906, 1907, 1908, 1909, 1910, 1913),1898, 1930)
Posterior_probability_extinction_varying_end_year = function(sightings, start_year, stop_year) {

   if( any(is.na(sightings)) ) return(NA)

   analysis_interval = seq(start_year, stop_year)

   if( length(sightings) < 2) return(analysis_interval = NA)  # Not enough observations

      Vectorize(
        function(t) {
          if (t <= max(sightings)) return(1)
          compute_posterior_solow1993(
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
