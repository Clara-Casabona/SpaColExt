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
  df <- data.frame(prior_te_eval)
  df$year = years

  seq_m = seq(0,10,by=0.01)
  prior_m_eval = prior_m(seq_m)
  dfm <- data.frame(prior_m_eval)
  dfm$x = seq_m

  posterior_N2 = data.frame(posterior_N2)
  names(posterior_N2)[1] = paste("Exant_posterior_NonInformativePriors")
  posterior_N2$year = years

  posterior_N2_prior_te_m = data.frame(posterior_N2_prior_te_m)
  names(posterior_N2_prior_te_m)[1] = paste("Exant_posterior_Informative_m_te")
  posterior_N2_prior_te_m$year = seq(t_start, t_stop, by = 1)

  posterior_N2_prior_te = data.frame(posterior_N2_prior_te)
  names(posterior_N2_prior_te)[1] = paste("Exant_posterior_Informative_te")
  posterior_N2_prior_te$year = seq(t_start, t_stop, by = 1)

  posterior_N2_prior_m = data.frame(posterior_N2_prior_m)
  names(posterior_N2_prior_m)[1] = paste("Exant_posterior_Informative_m")
  posterior_N2_prior_m$year = seq(t_start, t_stop, by = 1)

  New_df = full_join(posterior_N2,posterior_N2_prior_te_m)
  New_df = full_join(New_df,posterior_N2_prior_te)
  New_df = full_join(New_df,posterior_N2_prior_m)
  New_df = tidyr::gather(New_df, "posterior", "value", c("Exant_posterior_NonInformativePriors","Exant_posterior_Informative_te","Exant_posterior_Informative_m","Exant_posterior_Informative_m_te"))
  New_df$posterior = as.factor(New_df$posterior)

  a=  ggplot(data=New_df, aes(x=year, y=value, group=posterior)) +
    theme_bw() +
    geom_line(aes(color=posterior)) +
    # scale_linetype_manual(values=c("twodash","solid" ,"solid","twodash")) +
    scale_color_manual(values=c("#00bbd6", "#237194","#faa32b", "gray")) +
    ylab("Extant probability")

  b =ggplot(dfm, aes(x=x, y=prior_m_eval)) +
    theme_bw() +
    theme(axis.title.x=element_text(size=8))+
    geom_line() +
    labs(x = "Observation rate before extinction (Prior m)", y = "Probability")

c =  ggplot(df, aes(x=years, y=prior_te_eval)) +
    theme_bw() +
    theme(axis.title.x=element_text(size=8))+
    geom_line() +
    labs(x = "Posterior date of extinction probability  (Prior te)", y = "Probability")
library(ggpubr)

 ggarrange(a,                                                 # First row with scatter plot
          ggarrange(c, b, ncol = 2, labels = c("B", "C"), widths = c(1,0.83)), # Second row with box and dot plots
          nrow = 2,
          labels = "A"                                        # Labels of the scatter plot
)
  }
