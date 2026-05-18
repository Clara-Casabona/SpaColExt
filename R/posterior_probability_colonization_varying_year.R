#' Colonization posterior probability sequence by year
#'
#' This helper estimates the probability that a species has colonized a site by
#' each year in the study period. It reverses the time axis and applies the
#' extinction estimator, so colonization in forward time is treated as extinction
#' in reversed time.
#'
#' @param sightings Numeric vector of sighting years.
#' @param start_year First year of the study period.
#' @param stop_year Last year of the study period.
#'
#' @return Numeric vector of posterior colonization probabilities by year.
#' @export
#'
#' @examples
#' posterior_probability_colonization_varying_year(
#'   sightings = c(2002, 2004, 2008, 2012),
#'   start_year = 1980,
#'   stop_year = 2020
#' )
posterior_probability_colonization_varying_year <- function(sightings, start_year, stop_year) {
  if (any(is.na(sightings))) return(NA)

  if (length(sightings) < 2) {
    return(rep(NA_real_, length(seq(start_year, stop_year))))
  }

  reversed_sightings <- transform_and_reverse(
    sightings = sightings,
    t_start = start_year,
    t_end = stop_year
  )

  reversed_posterior <- posterior_probability_extinction_varying_end_year(
    sightings = reversed_sightings,
    start_year = start_year,
    stop_year = stop_year
  )

  rev(reversed_posterior)
}
