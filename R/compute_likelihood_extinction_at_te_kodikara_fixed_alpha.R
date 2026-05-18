#' Likelihood of Extinction at a Fixed Alpha Parameter (Kodikara Method)
#'
#' @param t Numeric vector of scaled sighting times.
#' @param te Scaled extinction time.
#' @param dprior_m Function for the prior distribution of observation rate.
#' @param alpha Fixed shape parameter for the non-homogeneous process.
#'
#' @return Likelihood of extinction at `te`.
#' @export
#'
compute_likelihood_extinction_at_te_kodikara_fixed_alpha <- function(t, te, dprior_m, alpha) {
  n = length(t)
  result <- exp(n * log(alpha) + (alpha - 1) * log(prod(t)) - log(alpha) - alpha * n * log(te) + log(gamma(n)))
  return(result)
}

#' @rdname compute_likelihood_extinction_at_te_kodikara_fixed_alpha
#' @export
compute_likelyhood_extinction_at_te_kodikara_fixed_alpha <- function(t, te, dprior_m, alpha) {
  .Deprecated("compute_likelihood_extinction_at_te_kodikara_fixed_alpha")
  compute_likelihood_extinction_at_te_kodikara_fixed_alpha(
    t = t,
    te = te,
    dprior_m = dprior_m,
    alpha = alpha
  )
}
