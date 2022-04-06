#' Compute likelihood of extinction at te
#'
#' @param t number of sightings
#' @param te extinction time
#' @param dprior_m  function of the prior observation rate m
#'
#' @return likelihood of extinction at extinction time (te)
#' @export
#'
#' @examples
#' compute_likelyhood_extinction_at_te(t = (c(1901,1902,1903,1905,1908,1910) - 1900) / (1920 - 1900), 1, dprior_m = solowdprior_m)

compute_likelyhood_extinction_at_te <- function(t, te, dprior_m) {
  integrate(
    function(m) {
      exp(length(t)*log(m) - m * te + log(dprior_m(m)))
    },
    lower = 0,
    upper = Inf,
    abs.tol = 1e-8
  )$value
}
