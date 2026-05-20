# Simulation study for SpaColExt

This folder contains a reproducible simulation workflow used to validate the
extinction and colonization estimators described in the manuscript.

Run from the package root:

```r
source("analysis/simulation_study/run_simulation_study.R")
```

The script:

- sources the local package functions from `R/`;
- simulates sighting records under known extinction and colonization dates;
- compares homogeneous Solow-style inference, the non-homogeneous Kodikara-style
  estimator, and the fixed-alpha effort-informed estimator;
- writes summary tables and figures to `analysis/simulation_study/results/`;
- optionally mirrors figures and tables into the manuscript folder when it is
  available locally.

## Extinction-date diagnostics

Additional diagnostics compare two ways to convert the model output into a
single estimated extinction year:

- threshold estimator: the first year where posterior persistence drops below
  0.5;
- posterior-time estimator: the posterior median of the extinction time `te`,
  implemented in `posterior_extinction_year_quantile()`.

Run:

```r
source("analysis/simulation_study/diagnose_extinction_improvements.R")
source("analysis/simulation_study/plot_extinction_quantile_comparison.R")
```

These diagnostics include constant, increasing, and decreasing observation
effort scenarios. The matched-sightings scenarios adjust the observation-rate
parameter so the expected number of sightings is comparable across effort
shapes. This separates the effect of temporal effort shape from the effect of
having more or fewer observations.

The main conclusion is that the posterior median of `te` is usually a better
date estimator than the threshold rule. The threshold rule often estimates
extinction too late because it waits for the posterior persistence curve to
cross an arbitrary decision boundary. The posterior median directly summarizes
the inferred extinction-time distribution.

Mean absolute errors from the current diagnostic run:

| Scenario | Solow threshold | Solow median `te` | Effort threshold | Effort median `te` |
|---|---:|---:|---:|---:|
| Constant effort | 7.6 | 3.7 | 7.5 | 3.3 |
| Constant effort, matched sightings | 5.4 | 1.7 | 6.0 | 2.0 |
| Increasing effort | 6.9 | 1.1 | 4.0 | 0.8 |
| Decreasing effort | 7.7 | 4.8 | 7.2 | 3.7 |
| Decreasing effort, matched sightings | 5.4 | 2.8 | 10.0 | 1.8 |

For decreasing effort before extinction (`alpha < 1`), the effort-informed
posterior median still improves over the threshold rule, but sparse late
observations remain difficult: if effort decreases near the extinction date,
missing late sightings are less informative.

The comparison figure is written to:

```text
analysis/simulation_study/results/figures/extinction_quantile_estimator_comparison.pdf
analysis/simulation_study/results/figures/extinction_quantile_estimator_comparison.png
```
