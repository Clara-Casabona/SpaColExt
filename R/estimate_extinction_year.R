#' Estimate extinction year from the posterior distribution of extinction time
#'
#' @param sightings Numeric vector of sighting years.
#' @param start_year First year of the study period.
#' @param stop_year Last year of the study period.
#' @param method Likelihood model to use. Either `"solow"` or `"fixed_alpha"`.
#' @param dprior_te Function for the prior distribution of extinction time.
#' @param dprior_m Function for the prior distribution of observation rate.
#' @param alpha Fixed shape parameter for the non-homogeneous process.
#' @param probability Posterior quantile to return.
#'
#' @return Estimated calendar year for the requested posterior quantile.
#' @export
posterior_extinction_year_quantile <- function(sightings,
                                               start_year,
                                               stop_year,
                                               method = c("solow", "fixed_alpha"),
                                               dprior_te = solowdprior_te,
                                               dprior_m = solowdprior_m,
                                               alpha = 1,
                                               probability = 0.5) {
  method <- match.arg(method)

  if (length(sightings) < 2 || any(is.na(sightings))) {
    return(NA_real_)
  }
  if (probability <= 0 || probability >= 1) {
    stop("`probability` must be strictly between 0 and 1.")
  }
  if (start_year >= stop_year) {
    stop("`start_year` must be smaller than `stop_year`.")
  }

  t <- (sightings - start_year) / (stop_year - start_year)
  lower <- max(t)
  if (!is.finite(lower) || lower >= 1) {
    return(NA_real_)
  }

  likelihood <- switch(
    method,
    solow = function(te) {
      compute_likelihood_extinction_at_te(
        t = t,
        te = te,
        dprior_m = dprior_m
      )
    },
    fixed_alpha = function(te) {
      compute_likelihood_extinction_at_te_kodikara_fixed_alpha(
        t = t,
        te = te,
        dprior_m = dprior_m,
        alpha = alpha
      )
    }
  )

  density <- function(te) likelihood(te) * dprior_te(te)
  normalising_constant <- stats::integrate(
    Vectorize(density),
    lower = lower,
    upper = 1,
    abs.tol = 1e-8
  )$value

  if (!is.finite(normalising_constant) || normalising_constant <= 0) {
    return(NA_real_)
  }

  cdf <- function(te) {
    stats::integrate(
      Vectorize(density),
      lower = lower,
      upper = te,
      abs.tol = 1e-8
    )$value / normalising_constant
  }

  scaled_year <- stats::uniroot(
    function(te) cdf(te) - probability,
    interval = c(lower, 1)
  )$root

  start_year + scaled_year * (stop_year - start_year)
}
