#' Plot temporal posterior extant probabilities
#'
#' @param extinction_posterior Output from one of the posterior probability
#'   functions. This can be a numeric vector, a list of numeric vectors, or a
#'   matrix/list returned by [spatial_posterior_probability_extinction_varying_end_year()].
#' @param start_year First year of the study period.
#' @param stop_year Last year of the study period.
#'
#' @return A `ggplot` object with posterior extant probabilities through time.
#' @export
#'
#' @examples
#' data <- list(c(1880, 1883, 1895, 1897, 1899), NA, NA, c(1882, 1884, 1896, 1898))
#' dim(data) <- c(2, 2)
#' posterior <- spatial_posterior_probability_extinction_varying_end_year(
#'   data,
#'   start_year = 1880,
#'   stop_year = 1920
#' )
#' plot_posterior_distribution(posterior, start_year = 1880, stop_year = 1920)
plot_posterior_distribution <- function(extinction_posterior, start_year, stop_year) {
  years <- seq(start_year, stop_year, by = 1)

  if (is.numeric(extinction_posterior) && is.null(dim(extinction_posterior))) {
    df <- data.frame(site = "site_1", year = years, value = extinction_posterior)
  } else {
    keep <- !is.na(extinction_posterior)
    values <- extinction_posterior[keep]

    if (length(values) == 0) {
      stop("`extinction_posterior` does not contain any posterior values.", call. = FALSE)
    }

    indices <- if (is.null(dim(extinction_posterior))) {
      cbind(seq_along(values), 1L)
    } else {
      which(keep, arr.ind = TRUE)
    }

    df <- do.call(
      rbind,
      lapply(seq_along(values), function(i) {
        posterior <- as.numeric(values[[i]])
        if (length(posterior) != length(years)) {
          stop("Each posterior vector must have one value per year.", call. = FALSE)
        }
        data.frame(
          site = paste0("site_", paste(indices[i, ], collapse = "_")),
          year = years,
          value = posterior
        )
      })
    )
  }

  ggplot2::ggplot(df, ggplot2::aes(x = year, y = value)) +
    ggplot2::geom_line() +
    ggplot2::theme_bw() +
    ggplot2::ylab("Extant probability") +
    ggplot2::facet_wrap(~site)
}
