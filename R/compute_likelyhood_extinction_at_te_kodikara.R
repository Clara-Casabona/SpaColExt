
#' Compute extinction likelihood a extinction time
#'
#' @param t number of sightings
#' @param te extinction time
#' @param dprior_m  function of the prior observation rate m
#'
#' @return
#' @export
#'
#' @examples
#'
compute_likelyhood_extinction_at_te_kodikara <- function(t, te, dprior_m) {
  integrate(
    Vectorize(
      function(alpha) {
       integrate(
          Vectorize(
            function(m){
              exp(length(t)*(alpha*log(m) + log(alpha)) + (alpha-1)*sum(log(t))- (m * te)^alpha + log(dprior_m(m)))
            }
         ),
         lower = 0,
         upper = 1000,
         abs.tol = 1e-8
      )$value
    }
  ),
  lower = 0,
  upper = Inf,
  abs.tol = 1e-8
  )$value
}
