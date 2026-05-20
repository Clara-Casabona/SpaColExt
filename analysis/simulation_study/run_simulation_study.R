set.seed(20260518)

`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}

package_root <- normalizePath(getwd(), mustWork = TRUE)
if (!file.exists(file.path(package_root, "DESCRIPTION"))) {
  package_root <- normalizePath(file.path(dirname(commandArgs(trailingOnly = FALSE)[1]), "..", ".."), mustWork = TRUE)
}

source_package_functions <- function(root) {
  files <- list.files(file.path(root, "R"), pattern = "[.]R$", full.names = TRUE)
  for (file in files) {
    source(file, local = .GlobalEnv)
  }
}

source_package_functions(package_root)

results_dir <- file.path(package_root, "analysis", "simulation_study", "results")
figures_dir <- file.path(results_dir, "figures")
tables_dir <- file.path(results_dir, "tables")
dir.create(figures_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(tables_dir, recursive = TRUE, showWarnings = FALSE)

article_dir <- path.expand("~/Documents/academia/PhD/RedactionThese/Article1_text")
article_fig_dir <- file.path(article_dir, "figs", "simulation_study")
article_table_dir <- file.path(article_dir, "tables", "simulation_study")
if (dir.exists(article_dir)) {
  suppressWarnings(dir.create(article_fig_dir, recursive = TRUE, showWarnings = FALSE))
  suppressWarnings(dir.create(article_table_dir, recursive = TRUE, showWarnings = FALSE))
}

simulate_extinction_sightings <- function(start_year, stop_year, extinction_year, alpha, m) {
  stopifnot(start_year < extinction_year, extinction_year <= stop_year)
  te <- (extinction_year - start_year) / (stop_year - start_year)
  n <- stats::rpois(1, lambda = (m * te)^alpha)
  if (n == 0) {
    return(numeric())
  }
  x <- te * stats::runif(n)^(1 / alpha)
  sort(unique(floor(start_year + x * (stop_year - start_year))))
}

simulate_colonization_sightings <- function(start_year, stop_year, colonization_year, alpha, m) {
  stopifnot(start_year <= colonization_year, colonization_year < stop_year)
  n <- stats::rpois(1, lambda = m^alpha)
  if (n == 0) {
    return(numeric())
  }
  x <- stats::runif(n)^(1 / alpha)
  sort(unique(ceiling(colonization_year + x * (stop_year - colonization_year))))
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

run_extinction_replicate <- function(replicate, scenario, start_year, stop_year, extinction_year, alpha, m) {
  years <- seq(start_year, stop_year)
  sightings <- resimulate_until_enough(
    function() simulate_extinction_sightings(start_year, stop_year, extinction_year, alpha, m)
  )

  solow <- safe_curve(
    posterior_probability_extinction_varying_end_year(sightings, start_year, stop_year),
    length(years)
  )
  kodikara <- safe_curve(
    posterior_probability_extinction_non_homogeneous_varying_end_year(sightings, start_year, stop_year),
    length(years)
  )
  effort <- safe_curve(
    posterior_extinction_non_homogeneous_fixed_alpha_varying_end_year(sightings, start_year, stop_year, alpha),
    length(years)
  )

  curves <- list(
    Solow = solow,
    Kodikara = kodikara,
    Effort_fixed_alpha = effort
  )

  do.call(
    rbind,
    lapply(names(curves), function(method) {
      estimate <- first_crossing(years, curves[[method]], threshold = 0.5, direction = "below")
      data.frame(
        experiment = "extinction",
        scenario = scenario,
        replicate = replicate,
        method = method,
        true_year = extinction_year,
        n_sightings = length(sightings),
        last_sighting = max(sightings),
        final_probability = tail(curves[[method]], 1),
        estimated_year = estimate,
        date_error = estimate - extinction_year,
        absolute_date_error = abs(estimate - extinction_year),
        no_threshold_crossing = is.na(estimate),
        stringsAsFactors = FALSE
      )
    })
  )
}

run_colonization_replicate <- function(replicate, start_year, stop_year, colonization_year, alpha, m) {
  years <- seq(start_year, stop_year)
  sightings <- resimulate_until_enough(
    function() simulate_colonization_sightings(start_year, stop_year, colonization_year, alpha, m)
  )

  posterior <- safe_curve(
    posterior_probability_colonization_varying_year(sightings, start_year, stop_year),
    length(years)
  )

  estimate <- first_crossing(years, posterior, threshold = 0.5, direction = "above")

  data.frame(
    experiment = "colonization",
    scenario = "increasing effort after colonization",
    replicate = replicate,
    method = "Time_reversed_Solow",
    true_year = colonization_year,
    n_sightings = length(sightings),
    first_sighting = min(sightings),
    final_probability = tail(posterior, 1),
    probability_at_true_year = posterior[match(colonization_year, years)],
    estimated_year = estimate,
    date_error = estimate - colonization_year,
    absolute_date_error = abs(estimate - colonization_year),
    no_threshold_crossing = is.na(estimate),
    stringsAsFactors = FALSE
  )
}

summarise_results <- function(results) {
  aggregate(
    cbind(
      final_probability,
      date_error,
      absolute_date_error,
      no_threshold_crossing,
      n_sightings
    ) ~ experiment + scenario + method,
    data = results,
    FUN = function(x) {
      if (is.logical(x)) {
        mean(x, na.rm = TRUE)
      } else {
        mean(x, na.rm = TRUE)
      }
    }
  )
}

format_summary <- function(summary) {
  within(summary, {
    final_probability <- round(final_probability, 3)
    date_error <- round(date_error, 2)
    absolute_date_error <- round(absolute_date_error, 2)
    no_threshold_crossing <- round(no_threshold_crossing, 2)
    n_sightings <- round(n_sightings, 1)
  })
}

n_replicates <- 80
start_year <- 1980
stop_year <- 2020

extinction_scenarios <- data.frame(
  scenario = c("constant observation effort", "increasing observation effort"),
  extinction_year = c(2005, 2005),
  alpha = c(1.0, 1.8),
  m = c(6.0, 6.0),
  stringsAsFactors = FALSE
)

message("Running extinction simulations...")
extinction_results <- do.call(
  rbind,
  lapply(seq_len(nrow(extinction_scenarios)), function(i) {
    scenario <- extinction_scenarios[i, ]
    do.call(
      rbind,
      lapply(seq_len(n_replicates), function(replicate) {
        if (replicate %% 10 == 0) {
          message("  ", scenario$scenario, ": replicate ", replicate, "/", n_replicates)
        }
        run_extinction_replicate(
          replicate = replicate,
          scenario = scenario$scenario,
          start_year = start_year,
          stop_year = stop_year,
          extinction_year = scenario$extinction_year,
          alpha = scenario$alpha,
          m = scenario$m
        )
      })
    )
  })
)

message("Running colonization simulations...")
colonization_results <- do.call(
  rbind,
  lapply(seq_len(n_replicates), function(replicate) {
    if (replicate %% 10 == 0) {
      message("  colonization: replicate ", replicate, "/", n_replicates)
    }
    run_colonization_replicate(
      replicate = replicate,
      start_year = start_year,
      stop_year = stop_year,
      colonization_year = 1998,
      alpha = 1.5,
      m = 5.0
    )
  })
)

extinction_summary <- format_summary(summarise_results(extinction_results))
colonization_summary <- within(
  aggregate(
    cbind(
      final_probability,
      probability_at_true_year,
      date_error,
      absolute_date_error,
      no_threshold_crossing,
      n_sightings
    ) ~ experiment + scenario + method,
    data = colonization_results,
    FUN = function(x) mean(x, na.rm = TRUE)
  ),
  {
    final_probability <- round(final_probability, 3)
    probability_at_true_year <- round(probability_at_true_year, 3)
    date_error <- round(date_error, 2)
    absolute_date_error <- round(absolute_date_error, 2)
    no_threshold_crossing <- round(no_threshold_crossing, 2)
    n_sightings <- round(n_sightings, 1)
  }
)

utils::write.csv(extinction_results, file.path(results_dir, "extinction_simulation_results.csv"), row.names = FALSE)
utils::write.csv(colonization_results, file.path(results_dir, "colonization_simulation_results.csv"), row.names = FALSE)
utils::write.csv(extinction_summary, file.path(results_dir, "extinction_simulation_summary.csv"), row.names = FALSE)
utils::write.csv(colonization_summary, file.path(results_dir, "colonization_simulation_summary.csv"), row.names = FALSE)

if (requireNamespace("knitr", quietly = TRUE)) {
  extinction_table <- knitr::kable(
    extinction_summary,
    format = "latex",
    booktabs = TRUE,
    caption = "Simulation summary for extinction-date inference. Final probability is the posterior probability of persistence in the last study year. Date error is the estimated crossing year minus the true extinction year."
  )
  colonization_table <- knitr::kable(
    colonization_summary,
    format = "latex",
    booktabs = TRUE,
    caption = "Simulation summary for colonization-date inference. Date error is the estimated crossing year minus the true colonization year."
  )
  writeLines(extinction_table, file.path(tables_dir, "extinction_simulation_summary.tex"))
  writeLines(colonization_table, file.path(tables_dir, "colonization_simulation_summary.tex"))
  if (dir.exists(article_table_dir)) {
    writeLines(extinction_table, file.path(article_table_dir, "extinction_simulation_summary.tex"))
    writeLines(colonization_table, file.path(article_table_dir, "colonization_simulation_summary.tex"))
  }
}

if (requireNamespace("ggplot2", quietly = TRUE)) {
  p_ext <- ggplot2::ggplot(
    extinction_results,
    ggplot2::aes(x = method, y = final_probability, fill = method)
  ) +
    ggplot2::geom_boxplot(width = 0.65, outlier.alpha = 0.4) +
    ggplot2::facet_wrap(~ scenario) +
    ggplot2::coord_cartesian(ylim = c(0, 1)) +
    ggplot2::labs(x = NULL, y = "Posterior persistence probability in 2020") +
    ggplot2::theme_bw(base_size = 10) +
    ggplot2::theme(
      legend.position = "none",
      axis.text.x = ggplot2::element_text(angle = 25, hjust = 1)
    )

  p_err <- ggplot2::ggplot(
    extinction_results[!is.na(extinction_results$date_error), ],
    ggplot2::aes(x = method, y = date_error, fill = method)
  ) +
    ggplot2::geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
    ggplot2::geom_boxplot(width = 0.65, outlier.alpha = 0.4) +
    ggplot2::facet_wrap(~ scenario) +
    ggplot2::labs(x = NULL, y = "Estimated year - true extinction year") +
    ggplot2::theme_bw(base_size = 10) +
    ggplot2::theme(
      legend.position = "none",
      axis.text.x = ggplot2::element_text(angle = 25, hjust = 1)
    )

  p_col <- ggplot2::ggplot(
    colonization_results[!is.na(colonization_results$date_error), ],
    ggplot2::aes(x = method, y = date_error)
  ) +
    ggplot2::geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
    ggplot2::geom_boxplot(width = 0.45, fill = "#66A61E", outlier.alpha = 0.4) +
    ggplot2::labs(x = NULL, y = "Estimated year - true colonization year") +
    ggplot2::theme_bw(base_size = 10)

  ggplot2::ggsave(file.path(figures_dir, "extinction_final_probability.pdf"), p_ext, width = 7, height = 3.8)
  ggplot2::ggsave(file.path(figures_dir, "extinction_date_error.pdf"), p_err, width = 7, height = 3.8)
  ggplot2::ggsave(file.path(figures_dir, "colonization_date_error.pdf"), p_col, width = 4.5, height = 3.5)

  if (dir.exists(article_fig_dir)) {
    ggplot2::ggsave(file.path(article_fig_dir, "extinction_final_probability.pdf"), p_ext, width = 7, height = 3.8)
    ggplot2::ggsave(file.path(article_fig_dir, "extinction_date_error.pdf"), p_err, width = 7, height = 3.8)
    ggplot2::ggsave(file.path(article_fig_dir, "colonization_date_error.pdf"), p_col, width = 4.5, height = 3.5)
  }
}

message("Simulation study complete.")
message("Results written to: ", results_dir)
