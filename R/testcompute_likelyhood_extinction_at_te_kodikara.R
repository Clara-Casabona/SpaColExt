#' Compute extinction likelihood a extinction time using a doble integral from curbature package
#'
#' @param t number of sightings
#' @param te extinction time
#' @param dprior_m  function of the prior observation rate m
#'
#' @return extinction likelihood at a specific extinction time
#' @export
#'
#' @examples


testcompute_likelyhood_extinction_at_te_kodikara <- function(t, te, dprior_m) {
  library(cubature)

  f <- function(alpha, m) {
    if(m < 1e-9) {
      return(0)
    }
    val <- exp(length(t) * (alpha * log(m) + log(alpha)) + (alpha - 1) * sum(log(t)) - exp(alpha * log(m * te)) + log(dprior_m(m)))
    if(val > 1e100) {
      val <- 1e100
    }
    return(val)
  }

  out <- adaptIntegrate(
    function(x) {
      integrand <- function(y) {
        f(x[1], y)
      }
      integral <- hcubature(integrand, lower = 0.01, upper = 100)$integral
      return(integral)
    },
    lower = c(0),
    upper = c(Inf),
    epsabs = 1e-8,
    epsrel = 1e-8
  )

  return(out$value)
}
