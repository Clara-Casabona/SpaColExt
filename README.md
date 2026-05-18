<!-- README.md is generated from README.Rmd. Please edit that file. -->



# SpaColExt

<!-- badges: start -->
[![R-CMD-check](https://github.com/Clara-Casabona/SpaColExt/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/Clara-Casabona/SpaColExt/actions/workflows/R-CMD-check.yaml)
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE.md)
<!-- badges: end -->

SpaColExt is an R package for inferring extinction and colonization dates from species sighting records. It focuses on Bayesian extinction inference through time and across spatial units, with tools for:

- estimating posterior extant probabilities from sighting years;
- applying Solow-style Bayesian extinction estimators;
- evaluating posterior probabilities over a sequence of possible end years;
- applying the same workflow independently across spatial cells;
- exploring informative priors for extinction time and observation rate.

The package currently implements methods based on Solow (1993), with experimental non-homogeneous observation-rate functions inspired by Kodikara et al. (2020). Solow and Beet (2014)-style uncertain sighting support is planned but not yet part of the stable workflow.

## Model Interpretation

The core output of SpaColExt is a posterior probability, usually interpreted as the probability that a species is still extant at a given time conditional on the observed sighting record:

\[
P(H_0 \mid D) =
\left(1 + \frac{1 - \pi}{\pi B(D)}\right)^{-1}
\]

where \(H_0\) is the hypothesis that the species is extant, \(D\) is the sighting record, \(\pi\) is the prior probability of persistence, and \(B(D)\) is the Bayes factor comparing persistence to extinction.

For the non-homogeneous observation process, the package follows the idea that sighting intensity may vary through time:

\[
\lambda(t) = \alpha m^\alpha t^{\alpha - 1}
\]

Here, \(m\) controls the observation rate and \(\alpha\) controls the shape of the observation process through time. The value \(\alpha = 1\) corresponds to a homogeneous process, equivalent to assuming constant observation intensity. Values above or below 1 represent increasing or decreasing observation intensity through time.

In ecological applications, \(\alpha\) should not be interpreted as sampling effort itself. A safer interpretation is that \(\alpha\) is a shape parameter informed by sampling effort, used to represent temporal heterogeneity in detectability or observation intensity. For example, if eBird checklist effort increases strongly through time, using \(\alpha > 1\) can make the observation process more consistent with increasing search effort.

One possible empirical calibration is to fit a relationship between yearly effort \(E_t\) and scaled time:

\[
\log(E_t) = c + (\alpha - 1)\log(t)
\]

This treats \(\alpha\) as a compact summary of temporal change in effort. This approach is still experimental and should be reported as an effort-informed sensitivity analysis unless the calibration is explicitly validated.

## Installation

You can install the development version from GitHub:

``` r
# install.packages("remotes")
remotes::install_github("Clara-Casabona/SpaColExt")
```

Load the package with:

``` r
library(SpaColExt)
```

## Basic Workflow

The main input is a numeric vector of sighting years. In the simplest case, `compute_posterior_solow1993()` returns the posterior probability that the species is still extant at the end of the study interval.


``` r
sightings <- c(1901, 1902, 1903, 1905, 1908, 1910)
start_year <- 1900
end_year <- 1920

compute_posterior_solow1993(
  sightings = sightings,
  start_year = start_year,
  end_year = end_year,
  dprior_m = solowdprior_m,
  dprior_te = solowdprior_te,
  prior = 0.5
)
#> [1] 0.1388889
```

## Posterior Probability Through Time

Use `posterior_probability_extinction_varying_end_year()` to evaluate the posterior extant probability for every year in a study period.


``` r
posterior <- posterior_probability_extinction_varying_end_year(
  sightings = sightings,
  start_year = start_year,
  stop_year = end_year
)

posterior_df <- data.frame(
  year = seq(start_year, end_year),
  extant_probability = posterior
)

head(posterior_df)
#>   year extant_probability
#> 1 1900                  1
#> 2 1901                  1
#> 3 1902                  1
#> 4 1903                  1
#> 5 1904                  1
#> 6 1905                  1

ggplot2::ggplot(posterior_df, ggplot2::aes(year, extant_probability)) +
  ggplot2::geom_line(linewidth = 0.8, color = "#0072B2") +
  ggplot2::geom_point(size = 1.7, color = "#0072B2") +
  ggplot2::coord_cartesian(ylim = c(0, 1)) +
  ggplot2::theme_bw(base_size = 10) +
  ggplot2::labs(x = "Year", y = "Posterior extant probability")
```

<div class="figure">
<img src="man/figures/README-example-varying-end-year-1.png" alt="plot of chunk example-varying-end-year" width="70%" />
<p class="caption">plot of chunk example-varying-end-year</p>
</div>

## Spatial Workflow

Spatial analyses use a matrix-like object where each cell contains a vector of sighting years for one site. Cells with no observations can be set to `NA`.


``` r
sighting_grid <- list(
  c(1880, 1883, 1895, 1897, 1899), c(1881, 1884, 1892, 1901), NA, NA,
  c(1882, 1888, 1894, 1898), c(1885, 1892, 1902, 1910), c(1887, 1899, 1905), NA,
  NA, c(1890, 1895, 1901), c(1892, 1898, 1904, 1912), c(1894, 1902, 1914),
  NA, c(1898, 1904), c(1901, 1908, 1916), c(1902, 1910, 1920)
)
dim(sighting_grid) <- c(4, 4)

spatial_posterior <- spatial_posterior_probability_extinction_varying_end_year(
  sighting_grid,
  start_year = 1880,
  stop_year = 1930
)

final_probability <- matrix(
  vapply(
    as.vector(spatial_posterior),
    function(x) {
      if (length(x) == 1 && is.na(x)) return(NA_real_)
      tail(x, 1)
    },
    numeric(1)
  ),
  nrow = 4,
  ncol = 4
)

grid_df <- data.frame(
  row = rep(seq_len(nrow(final_probability)), times = ncol(final_probability)),
  col = rep(seq_len(ncol(final_probability)), each = nrow(final_probability)),
  extant_probability = as.vector(final_probability)
)

ggplot2::ggplot(grid_df, ggplot2::aes(col, row, fill = extant_probability)) +
  ggplot2::geom_tile(color = "white", linewidth = 0.8) +
  ggplot2::geom_text(
    ggplot2::aes(label = ifelse(is.na(extant_probability), "", sprintf("%.2f", extant_probability))),
    size = 3
  ) +
  ggplot2::scale_y_reverse(breaks = seq_len(4)) +
  ggplot2::scale_x_continuous(breaks = seq_len(4)) +
  ggplot2::scale_fill_viridis_c(
    option = "C",
    limits = c(0, 1),
    na.value = "grey92",
    name = "P(extant)"
  ) +
  ggplot2::coord_equal() +
  ggplot2::theme_bw(base_size = 10) +
  ggplot2::theme(panel.grid = ggplot2::element_blank()) +
  ggplot2::labs(x = "Column", y = "Row")
```

<div class="figure">
<img src="man/figures/README-example-spatial-1.png" alt="plot of chunk example-spatial" width="65%" />
<p class="caption">plot of chunk example-spatial</p>
</div>

This grid summarizes the posterior probability of persistence in the final year of the study period for each spatial cell. Empty cells represent sites without enough sightings.

## Colonization by Time Reversal

Colonization can be treated as the temporal mirror of extinction. If a species is absent before colonization and present after colonization, reversing the time axis turns the problem into an extinction-like problem. SpaColExt uses this idea in `posterior_probability_colonization_varying_year()`.


``` r
set.seed(42)

colonization_start_year <- 1980
colonization_stop_year <- 2020
true_colonization_year <- 1998

colonization_sightings <- sort(unique(
  true_colonization_year + floor(cumsum(stats::rexp(20, rate = 0.35)))
))
colonization_sightings <- colonization_sightings[colonization_sightings <= colonization_stop_year]

colonization_posterior <- posterior_probability_colonization_varying_year(
  sightings = colonization_sightings,
  start_year = colonization_start_year,
  stop_year = colonization_stop_year
)

colonization_df <- data.frame(
  year = seq(colonization_start_year, colonization_stop_year),
  colonization_probability = colonization_posterior
)

ggplot2::ggplot(colonization_df, ggplot2::aes(year, colonization_probability)) +
  ggplot2::geom_line(linewidth = 0.8, color = "#009E73") +
  ggplot2::geom_point(size = 1.6, color = "#009E73") +
  ggplot2::geom_vline(xintercept = true_colonization_year, linetype = "dashed", color = "grey40") +
  ggplot2::coord_cartesian(ylim = c(0, 1)) +
  ggplot2::theme_bw(base_size = 10) +
  ggplot2::labs(x = "Year", y = "Posterior colonization probability")
```

<div class="figure">
<img src="man/figures/README-example-colonization-1.png" alt="plot of chunk example-colonization" width="70%" />
<p class="caption">plot of chunk example-colonization</p>
</div>

The dashed line shows the simulated colonization year. In real applications this year is unknown; the curve should be interpreted as the posterior probability that colonization had already occurred by each year.

## Informative Priors

`compute_posterior_c2022_extinction()` allows custom priors for extinction time (`prior_te`) and observation rate (`prior_m`). This is useful when independent ecological or sampling information should influence the posterior.


``` r
prior_te <- function(te) 1
prior_m <- function(m) 1 / pmax(m, .Machine$double.eps)

compute_posterior_c2022_extinction(
  sightings = sightings,
  start_year = start_year,
  stop_year = end_year,
  prior_te = prior_te,
  prior_m = prior_m
)
#>  [1] 1.0000000 1.0000000 1.0000000 1.0000000 1.0000000 1.0000000 1.0000000
#>  [8] 1.0000000 1.0000000 1.0000000 1.0000000 0.8911846 0.7706155 0.6482621
#> [15] 0.5331491 0.4312668 0.3451666 0.2747469 0.2183818 0.1738466 0.1388889
```

You can also compare the effect of different prior combinations:


``` r
visualize_priors_effects(
  t_start = start_year,
  t_stop = end_year,
  sightings = sightings,
  prior_te = prior_te,
  prior_m = prior_m
)
```

<div class="figure">
<img src="man/figures/README-example-prior-plot-1.png" alt="plot of chunk example-prior-plot" width="70%" />
<p class="caption">plot of chunk example-prior-plot</p>
</div>

## Function Overview

- `compute_posterior_solow1993()`: posterior extant probability for one study interval.
- `posterior_probability_extinction_varying_end_year()`: posterior extant probabilities for a sequence of end years.
- `posterior_probability_colonization_varying_year()`: posterior colonization probabilities using time reversal.
- `spatial_posterior_probability_extinction_varying_end_year()`: applies the varying end-year workflow across spatial cells.
- `plot_posterior_distribution()`: plots posterior extant probabilities through time.
- `compute_posterior_c2022_extinction()`: posterior curve with optional informative priors.
- `transform_and_reverse()`: helper for reversing sighting dates for colonization-oriented workflows.

Experimental non-homogeneous functions are available, but their interface and numerical behavior may still change.

## Development Status

SpaColExt is under active development. The current maintenance priorities are:

- add stable support for colonization-date inference;
- formalize spatial dependence between neighbouring sites;
- add support for uncertain sightings;
- expand tests around the non-homogeneous observation-rate functions;
- improve method references and vignettes for applied ecological workflows.

## References

Solow, A. R. (1993). Inferring extinction from sighting data. *Ecology*, 74(3), 962-964.

Solow, A. R. and Beet, A. R. (2014). On uncertain sightings and inference about extinction. *Conservation Biology*, 28(4), 1119-1123.

Kodikara, S., et al. (2020). Non-homogeneous sighting processes for extinction inference. *Methods in Ecology and Evolution*.
