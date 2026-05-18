#' Select the first n observations to retain
#'
#' @param sightings Numeric vector of sighting years.
#' @param n Number of observations to keep.
#'
#' @return The first `n` observations from `sightings`.
#' @export
#'
select_first_n_observations <- function(sightings, n) {
  return(sightings[1:n])

}
