#' Plot temporal posterior distribution
#'
#' @param extinction_posterior  Output from the posterior probability extinction functions (vector or list of vectors)
#' @param start_year Year at which we want to estimate the extant posterior probability
#' @param stop_year  Year at which we stop to estimate the extant  posterior probability
#'
#' @return Plot with posterior extant probability
#' @export
#'
#' @examples
#' data = list(c(1880, 1883, 1895, 1897, 1899), NA, NA, c(1882, 1884, 1896, 1898))
#' dim(data) <- c(2, 2)
#' plot_posterior_distribution(spatial_posterior_probability_extinction_varying_end_year(data, start_year=1880, stop_year=1920), start_year=1880, stop_year=1920)

plot_posterior_distribution = function(extinction_posterior,start_year,stop_year) {
  df <- reshape2::melt(extinction_posterior[!is.na(extinction_posterior)])
  df$year = seq(start_year, stop_year, by = 1)
  ggplot2::ggplot(df,  ggplot2::aes(x = year, y = value)) +
    ggplot2::geom_line() +
    ggplot2::theme_bw() +
    ggplot2:: ylab("Extant probability") +
    ggplot2::facet_wrap(~ factor(L1))
}
