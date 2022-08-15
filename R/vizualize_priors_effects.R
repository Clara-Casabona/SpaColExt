#' Vizualize Priors Effects
#'
#' @param t_start Starting study period
#' @param t_stop  End of the study period
#' @param sightings Vector with the years of observation
#' @param prior_te Function with the prior extinction distribution
#' @param prior_m  Function with the prior observation rate distribution
#'
#' @return
#' @export
#'
#' @examples
vizualize_priors_effects = function(t_start, t_stop, sightings, prior_te, prior_m) {
  posterior_N2 = compute_posterior_c2022_extinction(sightings, t_start, t_stop)
  posterior_N2_prior_te_m = compute_posterior_c2022_extinction(sightings, t_start, t_stop, prior_te = prior_te, prior_m = prior_m  )
  posterior_N2_prior_te = compute_posterior_c2022_extinction(sightings, t_start, t_stop, prior_te = prior_te)
  posterior_N2_prior_m = compute_posterior_c2022_extinction(sightings, t_start, t_stop, prior_m = prior_m  )

  years = t_start:t_stop
  prior_te_eval = prior_te(years)
  df <- melt(prior_te_eval)
  df$year = years

  posterior_N2 = data.frame(posterior_N2)
  names(posterior_N2)[1] = paste("Only_sightings")
  posterior_N2$year = years

  posterior_N2_prior_te_m = data.frame(posterior_N2_prior_te_m)
  names(posterior_N2_prior_te_m)[1] = paste("Te_m_priors")
  posterior_N2_prior_te_m$year = seq(t_start, t_stop, by = 1)

  posterior_N2_prior_te = data.frame(posterior_N2_prior_te)
  names(posterior_N2_prior_te)[1] = paste("Te_prior")
  posterior_N2_prior_te$year = seq(t_start, t_stop, by = 1)

  posterior_N2_prior_m = data.frame(posterior_N2_prior_m)
  names(posterior_N2_prior_m)[1] = paste("m_priors")
  posterior_N2_prior_m$year = seq(t_start, t_stop, by = 1)

  New_df = full_join(posterior_N2,posterior_N2_prior_te_m)
  New_df = full_join(New_df,posterior_N2_prior_te)
  New_df = full_join(New_df,posterior_N2_prior_m)
  New_df = tidyr::gather(New_df, "posterior", "value", c("Only_sightings","Te_prior","m_priors","Te_m_priors"))
  New_df$posterior = as.factor(New_df$posterior)
  ggplot(data=New_df, aes(x=year, y=value, group=posterior)) +
    theme_bw() +
    geom_line(aes(color=posterior)) +
    scale_linetype_manual(values=c("dotted", "dotted","dotted","dotted")) +
    scale_color_manual(values=c("yellow", "gray", "green", "blue")) +
    ylab("Extant probability")
}
