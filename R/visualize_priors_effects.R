#' Visualize the effect of prior distributions
#'
#' @param t_start First year of the study period.
#' @param t_stop Last year of the study period.
#' @param sightings Numeric vector of sighting years.
#' @param prior_te Function for the prior distribution of extinction time.
#' @param prior_m Function for the prior distribution of observation rate.
#'
#' @return A `ggplot` object comparing posterior curves under different priors.
#' @export
#'
#' @examples
#' sightings <- c(1901, 1902, 1903, 1905, 1908, 1910)
#' prior_te <- function(te) 1
#' prior_m <- function(m) 1 / pmax(m, .Machine$double.eps)
#' visualize_priors_effects(1900, 1920, sightings, prior_te, prior_m)
visualize_priors_effects <- function(t_start, t_stop, sightings, prior_te, prior_m) {
  years <- seq(t_start, t_stop, by = 1)
  posterior <- data.frame(
    year = rep(years, 4),
    posterior = rep(
      c(
        "Non-informative priors",
        "Informative extinction and observation priors",
        "Informative extinction prior",
        "Informative observation prior"
      ),
      each = length(years)
    ),
    value = c(
      compute_posterior_c2022_extinction(sightings, t_start, t_stop),
      compute_posterior_c2022_extinction(
        sightings,
        t_start,
        t_stop,
        prior_te = prior_te,
        prior_m = prior_m
      ),
      compute_posterior_c2022_extinction(sightings, t_start, t_stop, prior_te = prior_te),
      compute_posterior_c2022_extinction(sightings, t_start, t_stop, prior_m = prior_m)
    )
  )

  ggplot2::ggplot(posterior, ggplot2::aes(x = year, y = value, color = posterior)) +
    ggplot2::geom_line(ggplot2::aes(linetype = posterior), linewidth = 0.8) +
    ggplot2::theme_bw(base_size = 10) +
    ggplot2::scale_color_manual(values = c("#0072B2", "#009E73", "#D55E00", "#CC79A7")) +
    ggplot2::labs(
      x = "Year",
      y = "Extant probability",
      color = "Prior scenario",
      linetype = "Prior scenario"
    )
}

#' @rdname visualize_priors_effects
#' @export
vizualize_priors_effects <- function(t_start, t_stop, sightings, prior_te, prior_m) {
  .Deprecated("visualize_priors_effects")
  visualize_priors_effects(
    t_start = t_start,
    t_stop = t_stop,
    sightings = sightings,
    prior_te = prior_te,
    prior_m = prior_m
  )
}
