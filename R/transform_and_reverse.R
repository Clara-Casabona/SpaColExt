#' Transform and reverse sighting dates for colonisation models
#'
#' @param sightings Numeric vector of sighting years.
#' @param t_start First year of the study period.
#' @param t_end Last year of the study period.
#'
#' @return inverted sightings
#' @export
#'
#' @examples
#' transform_and_reverse(c(1901, 1902, 1903, 1905, 1908, 1910), 1900, 1920)

transform_and_reverse <- function(sightings, t_start, t_end) {
  inverted_years <- ((sightings - t_start) / (t_end - t_start)) * (t_start - t_end) + t_end
  return(rev(inverted_years))
}
