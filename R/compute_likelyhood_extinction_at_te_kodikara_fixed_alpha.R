#' Likelihood of Extinction at a Fixed Alpha Parameter (Kodikara Method)
#'
#' @param t
#' @param te
#' @param dprior_m
#' @param alpha
#'
#' @return
#' @export
#'
#' @examples
compute_likelyhood_extinction_at_te_kodikara_fixed_alpha <- function(t, te, dprior_m, alpha) {
  n = length(t)
  result <- exp(n * log(alpha) + (alpha - 1) * log(prod(t)) - log(alpha) - alpha * n * log(te) + log(gamma(n)))
  return(result)
}
