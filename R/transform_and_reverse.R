#' Transform and reverse sighting dates for colonisation models
#'
#' @param sightings sightings
#'
#' @return inverted sightings
#' @export
#'
#' @examples
#' transform_and_reverse(1901,1902,1903,1905,1908,1910)

transform_and_reverse <- function(sightings) {
  inverted_years <- ((sightings - t_start) / (t_end - t_start)) * (t_start - t_end) + t_end
  return(rev(inverted_years))
}

