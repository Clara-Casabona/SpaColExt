#' Convert an extinction posterior curve into a prior function
#'
#' @param te Scaled extinction time, between 0 and 1.
#' @param t_start First year of the study period.
#' @param t_stop Last year of the study period.
#' @param extinction_posterior Numeric vector of posterior extant probabilities
#'   evaluated for each year from `t_start` to `t_stop`.
#'
#' @return Prior density evaluated at `te`.
#' @export
#'
level_prior_te = function(te, t_start, t_stop, extinction_posterior) {
  interpolator = stats::approxfun(t_start:t_stop, extinction_posterior)
  1 - interpolator(te * (t_stop - t_start) + t_start)
}
