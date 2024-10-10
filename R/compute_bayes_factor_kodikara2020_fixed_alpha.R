#' Compute bayes factor kodikara2020 fixed alpha
#'
#' @param sightings
#' @param start_year
#' @param end_year
#' @param alpha
#'
#' @return
#' @export
#'
#' @examples
compute_bayes_factor_kodikara2020_fixed_alpha <- function(sightings, start_year, end_year, dprior_m, dprior_te, alpha) {
  t <- (sightings - start_year) / (end_year - start_year)

  # Likelihood of data given no extinction

  likelyhood_h0 <- function(t) {
    compute_likelyhood_extinction_at_te_kodikara_fixed_alpha(
      t,
      te = 1,
      dprior_m,
      alpha = alpha
    )
  }

  # Likelihood of data given extinction


  likelyhood_h1 <- function(t) {
    integrate(
      Vectorize(
        function(te) {
          compute_likelyhood_extinction_at_te_kodikara_fixed_alpha(
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

  likelyhood_h0(t) / likelyhood_h1(t)


}
