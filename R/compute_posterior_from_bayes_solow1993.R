#' Compute  Posterior  from bayes solow1993
#'
#' @param bayes_factor  Automatically calculated
#' @param prior         usually is 0.5
#'
#' @return   Posterior  from bayes solow1993
#' @export
#'
#' @examples
#'compute_posterior_from_bayes_solow1993(compute_bayes_factor_solow1993(sightings = c(1901,1902,1903,1905,1908,1910) , start_year = 1900, end_year = 1920, dprior_m = solowdprior_m, dprior_te = solowdprior_te),0.5)
#'
compute_posterior_from_bayes_solow1993 <- function(bayes_factor, prior) {
  1 / (1 + (1 - prior) / prior / bayes_factor)
}
