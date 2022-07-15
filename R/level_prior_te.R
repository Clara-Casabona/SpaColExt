level_prior_te = function(te) {
  interpolator = approxfun(t_start:t_stop, extinction_posteriorn1)
  1 - interpolator(te * (t_stop - t_start) + t_start)
}
