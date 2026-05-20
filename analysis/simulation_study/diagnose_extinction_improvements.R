set.seed(20260519)

package_root <- normalizePath(getwd(), mustWork = TRUE)
if (!file.exists(file.path(package_root, "DESCRIPTION"))) {
  stop("Run this script from the package root.")
}

source_package_functions <- function(root) {
  files <- list.files(file.path(root, "R"), pattern = "[.]R$", full.names = TRUE)
  for (file in files) {
    source(file, local = .GlobalEnv)
  }
}

source_package_functions(package_root)

results_dir <- file.path(package_root, "analysis", "simulation_study", "results")
dir.create(results_dir, recursive = TRUE, showWarnings = FALSE)

simulate_extinction_sightings <- function(start_year, stop_year, extinction_year, alpha, m) {
  te <- (extinction_year - start_year) / (stop_year - start_year)
  n <- stats::rpois(1, lambda = (m * te)^alpha)
  if (n == 0) {
    return(numeric())
  }
  x <- te * stats::runif(n)^(1 / alpha)
  sort(unique(floor(start_year + x * (stop_year - start_year))))
}

resimulate_until_enough <- function(simulator, min_sightings = 2, max_tries = 200) {
  for (i in seq_len(max_tries)) {
    sightings <- simulator()
    if (length(sightings) >= min_sightings) {
      return(sightings)
    }
  }
  sightings
}

beta_prior_te <- function(shape1, shape2) {
  force(shape1)
  force(shape2)
  function(te) stats::dbeta(te, shape1 = shape1, shape2 = shape2)
}

safe_curve <- function(expr, n_years) {
  tryCatch(
    as.numeric(expr),
    error = function(e) rep(NA_real_, n_years)
  )
}

first_crossing <- function(years, values, threshold, direction = c("below", "above")) {
  direction <- match.arg(direction)
  if (all(is.na(values))) {
    return(NA_real_)
  }
  index <- if (direction == "below") {
    which(values <= threshold)
  } else {
    which(values >= threshold)
  }
  if (length(index) == 0) {
    return(NA_real_)
  }
  years[index[1]]
}

posterior_curve <- function(sightings, start_year, stop_year, method, prior_te = solowdprior_te, alpha = 1) {
  years <- seq(start_year, stop_year)
  if (length(sightings) < 2 || any(is.na(sightings))) {
    return(rep(NA_real_, length(years)))
  }

  safe_curve(
    Vectorize(
      function(t) {
        if (t <= max(sightings)) {
          return(1)
        }
        if (method == "Solow") {
          return(compute_posterior_solow1993(
            sightings = sightings,
            start_year = start_year,
            end_year = t,
            dprior_m = solowdprior_m,
            dprior_te = prior_te,
            prior = 0.5
          ))
        }
        if (method == "Effort_fixed_alpha") {
          return(compute_posterior_non_homogeneous_fixed_alpha(
            sightings = sightings,
            start_year = start_year,
            end_year = t,
            dprior_m = solowdprior_m,
            dprior_te = prior_te,
            prior = 0.5,
            alpha = alpha
          ))
        }
        stop("Unknown method: ", method)
      }
    )(years),
    length(years)
  )
}

evaluate_estimator <- function(sightings, start_year, stop_year, extinction_year, method, prior_name, prior_te, alpha, threshold) {
  years <- seq(start_year, stop_year)
  if (method == "Solow_te_median" || method == "Effort_te_median") {
    estimate <- posterior_te_quantile(
      sightings = sightings,
      start_year = start_year,
      stop_year = stop_year,
      method = method,
      prior_te = prior_te,
      alpha = alpha,
      probability = 0.5
    )
    return(data.frame(
      method = method,
      prior = prior_name,
      alpha = alpha,
      threshold = threshold,
      estimated_year = estimate,
      date_error = estimate - extinction_year,
      absolute_date_error = abs(estimate - extinction_year),
      no_threshold_crossing = is.na(estimate),
      final_probability = -1,
      stringsAsFactors = FALSE
    ))
  }

  curve <- posterior_curve(
    sightings = sightings,
    start_year = start_year,
    stop_year = stop_year,
    method = method,
    prior_te = prior_te,
    alpha = alpha
  )
  estimate <- first_crossing(years, curve, threshold = threshold, direction = "below")
  data.frame(
    method = method,
    prior = prior_name,
    alpha = alpha,
    threshold = threshold,
    estimated_year = estimate,
    date_error = estimate - extinction_year,
    absolute_date_error = abs(estimate - extinction_year),
    no_threshold_crossing = is.na(estimate),
    final_probability = tail(curve, 1),
    stringsAsFactors = FALSE
  )
}

posterior_te_quantile <- function(sightings, start_year, stop_year, method, prior_te, alpha = 1, probability = 0.5) {
  if (length(sightings) < 2 || any(is.na(sightings))) {
    return(NA_real_)
  }

  last_scaled <- max((sightings - start_year) / (stop_year - start_year))
  if (!is.finite(last_scaled) || last_scaled >= 1) {
    return(NA_real_)
  }

  likelihood <- switch(
    method,
    Solow_te_median = function(te) {
      compute_likelihood_extinction_at_te(
        t = (sightings - start_year) / (stop_year - start_year),
        te = te,
        dprior_m = solowdprior_m
      )
    },
    Effort_te_median = function(te) {
      compute_likelihood_extinction_at_te_kodikara_fixed_alpha(
        t = (sightings - start_year) / (stop_year - start_year),
        te = te,
        dprior_m = solowdprior_m,
        alpha = alpha
      )
    },
    stop("Unknown method: ", method)
  )

  density <- function(te) likelihood(te) * prior_te(te)
  normalising_constant <- tryCatch(
    stats::integrate(Vectorize(density), lower = last_scaled, upper = 1, abs.tol = 1e-8)$value,
    error = function(e) NA_real_
  )
  if (!is.finite(normalising_constant) || normalising_constant <= 0) {
    return(NA_real_)
  }

  cdf <- function(te) {
    stats::integrate(Vectorize(density), lower = last_scaled, upper = te, abs.tol = 1e-8)$value /
      normalising_constant
  }

  scaled_estimate <- tryCatch(
    stats::uniroot(
      function(te) cdf(te) - probability,
      interval = c(last_scaled, 1)
    )$root,
    error = function(e) NA_real_
  )
  if (!is.finite(scaled_estimate)) {
    return(NA_real_)
  }

  round(start_year + scaled_estimate * (stop_year - start_year))
}

run_replicate <- function(replicate, scenario, start_year, stop_year, extinction_year, sim_alpha, sim_m, estimators) {
  sightings <- resimulate_until_enough(
    function() simulate_extinction_sightings(start_year, stop_year, extinction_year, sim_alpha, sim_m)
  )

  out <- do.call(
    rbind,
    lapply(seq_len(nrow(estimators)), function(i) {
      estimator <- estimators[i, ]
      evaluate_estimator(
        sightings = sightings,
        start_year = start_year,
        stop_year = stop_year,
        extinction_year = extinction_year,
        method = estimator$method,
        prior_name = estimator$prior,
        prior_te = estimator$prior_te[[1]],
        alpha = estimator$alpha,
        threshold = estimator$threshold
      )
    })
  )

  cbind(
    scenario = scenario,
    replicate = replicate,
    n_sightings = length(sightings),
    last_sighting = max(sightings),
    out,
    stringsAsFactors = FALSE
  )
}

summarise_diagnostics <- function(results) {
  summary <- aggregate(
    cbind(
      n_sightings,
      final_probability,
      date_error,
      absolute_date_error,
      no_threshold_crossing
    ) ~ scenario + method + prior + alpha + threshold,
    data = results,
    FUN = function(x) mean(x, na.rm = TRUE)
  )
  summary[order(summary$scenario, summary$absolute_date_error, abs(summary$date_error)), ]
}

n_replicates <- 40
start_year <- 1980
stop_year <- 2020
extinction_year <- 2005
te <- (extinction_year - start_year) / (stop_year - start_year)

target_lambda <- (6 * te)^1.8
constant_matched_m <- target_lambda / te
decreasing_alpha <- 0.6
decreasing_matched_m <- target_lambda^(1 / decreasing_alpha) / te

scenarios <- data.frame(
  scenario = c(
    "constant observation effort",
    "constant observation effort, matched expected sightings",
    "increasing observation effort",
    "decreasing observation effort",
    "decreasing observation effort, matched expected sightings"
  ),
  alpha = c(1.0, 1.0, 1.8, decreasing_alpha, decreasing_alpha),
  m = c(6.0, constant_matched_m, 6.0, 6.0, decreasing_matched_m),
  stringsAsFactors = FALSE
)

priors <- list(
  uniform = solowdprior_te,
  earlier_beta_1_2 = beta_prior_te(1, 2),
  later_beta_2_1 = beta_prior_te(2, 1)
)

estimators <- do.call(
  rbind,
  c(
    lapply(c(0.3, 0.4, 0.5, 0.6), function(threshold) {
      data.frame(
        method = "Solow",
        prior = names(priors),
        alpha = 1,
        threshold = threshold,
        stringsAsFactors = FALSE
      )
    }),
    lapply(c(0.6, 0.8, 1.0, 1.2, 1.5, 1.8), function(alpha) {
      data.frame(
        method = "Effort_fixed_alpha",
        prior = "uniform",
        alpha = alpha,
        threshold = 0.5,
        stringsAsFactors = FALSE
      )
    }),
    list(
      data.frame(
        method = "Solow_te_median",
        prior = names(priors),
        alpha = 1,
        threshold = -1,
        stringsAsFactors = FALSE
      ),
      data.frame(
        method = "Effort_te_median",
        prior = "uniform",
        alpha = c(0.6, 1, 1.5, 1.8),
        threshold = -1,
        stringsAsFactors = FALSE
      )
    )
  )
)
estimators$prior_te <- unname(priors[estimators$prior])

message("Running extinction diagnostics...")
diagnostic_results <- do.call(
  rbind,
  lapply(seq_len(nrow(scenarios)), function(i) {
    scenario <- scenarios[i, ]
    do.call(
      rbind,
      lapply(seq_len(n_replicates), function(replicate) {
        if (replicate %% 10 == 0) {
          message("  ", scenario$scenario, ": replicate ", replicate, "/", n_replicates)
        }
        run_replicate(
          replicate = replicate,
          scenario = scenario$scenario,
          start_year = start_year,
          stop_year = stop_year,
          extinction_year = extinction_year,
          sim_alpha = scenario$alpha,
          sim_m = scenario$m,
          estimators = estimators
        )
      })
    )
  })
)

diagnostic_summary <- summarise_diagnostics(diagnostic_results)

utils::write.csv(
  diagnostic_results,
  file.path(results_dir, "extinction_diagnostic_results.csv"),
  row.names = FALSE
)
utils::write.csv(
  diagnostic_summary,
  file.path(results_dir, "extinction_diagnostic_summary.csv"),
  row.names = FALSE
)

message("Best estimators by scenario:")
print(stats::aggregate(
  absolute_date_error ~ scenario,
  data = diagnostic_summary,
  FUN = min
))
message("Diagnostics written to: ", results_dir)
