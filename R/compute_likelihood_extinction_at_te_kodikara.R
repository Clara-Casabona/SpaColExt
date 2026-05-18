
#' Compute extinction likelihood at an extinction time
#'
#' @param t number of sightings
#' @param te extinction time
#' @param dprior_m  function of the prior observation rate m
#'
#' @return extinction likelihood at a specific extinction time
#' @export
#'
#'
compute_likelihood_extinction_at_te_kodikara <- function(t, te, dprior_m) {
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

#' @rdname compute_likelihood_extinction_at_te_kodikara
#' @export
compute_likelyhood_extinction_at_te_kodikara <- function(t, te, dprior_m) {
  .Deprecated("compute_likelihood_extinction_at_te_kodikara")
  compute_likelihood_extinction_at_te_kodikara(t = t, te = te, dprior_m = dprior_m)
}
