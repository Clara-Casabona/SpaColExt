#' Compute bayes factor kodikara2020 fixed alpha
#'
#' @param sightings Numeric vector of sighting years.
#' @param start_year First year of the study period.
#' @param end_year Last year of the study period.
#' @param dprior_m Function for the prior distribution of observation rate.
#' @param dprior_te Function for the prior distribution of extinction time.
#' @param alpha Fixed shape parameter for the non-homogeneous process.
#'
#' @return Bayes factor comparing persistence to extinction.
#' @export
#'
compute_bayes_factor_kodikara2020_fixed_alpha <- function(sightings, start_year, end_year, dprior_m, dprior_te, alpha) {
  t <- (sightings - start_year) / (end_year - start_year)

  # Likelihood of data given no extinction

  likelihood_h0 <- function(t) {
    compute_likelihood_extinction_at_te_kodikara_fixed_alpha(
      t,
      te = 1,
      dprior_m,
      alpha = alpha
    )
  }

  # Likelihood of data given extinction


  likelihood_h1 <- function(t) {
    integrate(
      Vectorize(
        function(te) {
          compute_likelihood_extinction_at_te_kodikara_fixed_alpha(
            t,
            te,
            dprior_m,
            alpha = alpha

          ) * dprior_te(te)
        }
      ),
      lower = max(t),
      upper = 1,
      abs.tol = 1e-8
    )$value
  }

  likelihood_h0(t) / likelihood_h1(t)


}
