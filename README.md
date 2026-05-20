

<!-- README.md is generated from README.Rmd. Please edit that file. -->

# SpaColExt

<!-- badges: start -->

[![R-CMD-check](https://github.com/Clara-Casabona/SpaColExt/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/Clara-Casabona/SpaColExt/actions/workflows/R-CMD-check.yaml)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![License:
MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE.md)
<!-- badges: end -->

SpaColExt is an R package for inferring extinction and colonization
dates from species sighting records. It provides Bayesian extinction
inference through time, spatial helper functions, colonization inference
by time reversal, and experimental effort-informed observation models.

The package currently implements methods based on Solow (1993), with
experimental non-homogeneous observation-rate functions inspired by
Kodikara et al. (2020).

## Manual

The detailed documentation now lives in the Quarto manual:
[`book/`](book/).

Render it from the package root with:

``` bash
quarto render book
```

After rendering, open:

``` text
book/_book/index.html
```

The manual includes:

- model interpretation;
- basic extinction and colonization workflows;
- spatial posterior smoothing;
- informative-prior examples;
- simulation diagnostics for constant, increasing, and decreasing
  observation effort;
- comparison of threshold-based extinction dates with posterior median
  estimates of extinction time.

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

## Quick Example

The main input is a numeric vector of sighting years.
`compute_posterior_solow1993()` returns the posterior probability that
the species is still extant at the end of the study interval.

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

To estimate an extinction year directly from the posterior distribution
of extinction time, use `posterior_extinction_year_quantile()`. The
default quantile is the posterior median.

``` r
posterior_extinction_year_quantile(
  sightings = sightings,
  start_year = start_year,
  stop_year = end_year,
  method = "solow",
  probability = 0.5
)
#> [1] 1911.417
```

## Simulation Diagnostics

Reproducible simulation scripts are stored in:

``` text
analysis/simulation_study/
```

The newest diagnostics compare:

- threshold estimator: first year where posterior persistence drops
  below 0.5;
- posterior-time estimator: posterior median of extinction time `te`;
- constant, increasing, and decreasing observation-effort scenarios;
- matched-sightings scenarios that separate effort shape from the number
  of observations.

The current comparison figure is:

``` text
analysis/simulation_study/results/figures/extinction_quantile_estimator_comparison.pdf
```

## Main Functions

- `compute_posterior_solow1993()`: posterior extant probability for one
  study interval.
- `posterior_probability_extinction_varying_end_year()`: posterior
  extant probabilities for a sequence of end years.
- `posterior_extinction_year_quantile()`: posterior quantile estimate of
  extinction year.
- `posterior_probability_colonization_varying_year()`: posterior
  colonization probabilities using time reversal.
- `spatial_posterior_probability_extinction_varying_end_year()`: applies
  the varying end-year workflow across spatial cells.
- `smooth_spatial_posterior()`: applies neighbour-informed smoothing to
  spatial posterior curves.
- `compute_posterior_c2022_extinction()`: posterior curve with optional
  informative priors.

Experimental non-homogeneous functions are available, but their
interface and numerical behavior may still change.

## References

Solow, A. R. (1993). Inferring extinction from sighting data. *Ecology*,
74(3), 962-964.

Solow, A. R. and Beet, A. R. (2014). On uncertain sightings and
inference about extinction. *Conservation Biology*, 28(4), 1119-1123.

Kodikara, S., et al. (2020). Non-homogeneous sighting processes for
extinction inference. *Methods in Ecology and Evolution*.
