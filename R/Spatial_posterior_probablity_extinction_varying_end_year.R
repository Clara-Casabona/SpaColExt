#' Spatial Extant Posterior Probability  by years
#'
#' @param start_year  Year at which we want to estimate the extant posterior probability
#' @param stop_year   Year at which we stop to estimate the extant  posterior probability
#' @param sightings   Matrix with vectors that contain the years with  observations
#'
#' @return
#' @export
#'
#' @examples
#' data = list(c(1880, 1883, 1895, 1897, 1899), NA, NA, c(1882, 1884, 1896, 1898))
#' dim(data) <- c(2, 2)
#' Spatial_posterior_probability_extinction_varying_end_year(data, start_year=1880, stop_year=1920)
#'
#'
Spatial_posterior_probability_extinction_varying_end_year = function(sightings, start_year, stop_year) {
  apply(
    sightings,
    c(1, 2),
    function(s) Posterior_probability_extinction_varying_end_year(unlist(s), start_year=start_year, stop_year=stop_year)
  )
}
