
#' Compute extinction likelihood a extinction time
#'
#' @param t number of sightings
#' @param te extinction time
#' @param dprior_m  function of the prior observation rate m
#'
#' @return extinction likelihood at a specific extinction time
#' @export
#'
#' @examples
#'
compute_likelyhood_extinction_at_te_kodikara <- function(t, te, dprior_m) {
    n = length(t)
    integrate(
      Vectorize(function(alpha) {
        exp(n * log(alpha) + (alpha - 1) * log(prod(t)) - log(alpha) - alpha * n * log(te) + log(gamma(n)))
      }),
      lower = 0,
      upper = Inf,
      abs.tol = 1e-8
    )$value
  }
