#' Select the first n observations to retain
#'
#' @param vec
#' @param n
#'
#' @return
#' @export
#'
#' @examples
select_first_n_observations <- function(sightings, n) {
  return(sightings[1:n])

}
