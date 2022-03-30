
<!-- README.md is generated from README.Rmd. Please edit that file -->

# SpaColExt

<!-- badges: start -->
<!-- badges: end -->

The goal of SpaColExt R package is to infer spatial colonization and
extinction dates of species acounting for the spatial heterogeneity of
the data. It uses a bayesian approach to estimate the probability of
species still extant thourgh the time a different spatial levels.

## Installation

You can install the development version of SpaColExt from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("Clara-Casabona/SpaColExt")
```

## Example

This is a basic example which shows you how to estimate the posterior
distribution of the extant probability of a extinct species:

``` r
library(SpaColExt)

## basic example code
sightings = c(1901,1902,1903,1905,1908,1910)
start_year = 1900
end_year = 1920
dprior_m = function(m) 1 / m
dprior_te = function(te) 1
prior =0.5

compute_posterior_solow1993(sightings = sightings, start_year = start_year, end_year = end_year, dprior_m = dprior_m , dprior_te = dprior_te, prior = prior)
#> [1] 0.1388889
```
