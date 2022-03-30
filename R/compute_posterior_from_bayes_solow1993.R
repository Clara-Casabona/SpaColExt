#' Compute  Posterior  from bayes solow1993
#'
#' @param bayes_factor  Automatically calculated
#' @param prior         usually is 0.5
#'
#' @return   Posterior  from bayes solow1993
#' @export
#'
#' @examples
#'
compute_posterior_from_bayes_solow1993 <- function(bayes_factor, prior) {
  1 / (1 + (1 - prior) / prior / bayes_factor)
}
