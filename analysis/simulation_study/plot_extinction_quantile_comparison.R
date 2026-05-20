package_root <- normalizePath(getwd(), mustWork = TRUE)
if (!file.exists(file.path(package_root, "DESCRIPTION"))) {
  stop("Run this script from the package root.")
}

results_dir <- file.path(package_root, "analysis", "simulation_study", "results")
figures_dir <- file.path(results_dir, "figures")
dir.create(figures_dir, recursive = TRUE, showWarnings = FALSE)

diagnostic_file <- file.path(results_dir, "extinction_diagnostic_results.csv")
if (!file.exists(diagnostic_file)) {
  stop("Missing diagnostic results. Run analysis/simulation_study/diagnose_extinction_improvements.R first.")
}

if (!requireNamespace("ggplot2", quietly = TRUE)) {
  stop("Package `ggplot2` is required to make this figure.")
}

results <- utils::read.csv(diagnostic_file)
true_alpha <- c(
  "constant observation effort" = 1.0,
  "constant observation effort, matched expected sightings" = 1.0,
  "increasing observation effort" = 1.8,
  "decreasing observation effort" = 0.6,
  "decreasing observation effort, matched expected sightings" = 0.6
)
results$true_alpha <- unname(true_alpha[results$scenario])

comparison <- subset(
  results,
  (method == "Solow" & prior == "uniform" & threshold == 0.5) |
    (method == "Solow_te_median" & prior == "uniform") |
    (method == "Effort_fixed_alpha" & prior == "uniform" & alpha == true_alpha & threshold == 0.5) |
    (method == "Effort_te_median" & prior == "uniform" & alpha == true_alpha)
)
comparison <- comparison[is.finite(comparison$date_error), ]

comparison$estimator <- with(
  comparison,
  ifelse(
    method == "Solow" & threshold == 0.5,
    "Solow: threshold 0.5",
    ifelse(
      method == "Solow_te_median",
      "Solow: posterior median te",
      ifelse(
        method == "Effort_fixed_alpha",
        "Effort model: threshold 0.5",
        "Effort model: posterior median te"
      )
    )
  )
)

comparison$estimator <- factor(
  comparison$estimator,
  levels = c(
    "Solow: threshold 0.5",
    "Solow: posterior median te",
    "Effort model: threshold 0.5",
    "Effort model: posterior median te"
  )
)

comparison$scenario <- factor(
  comparison$scenario,
  levels = c(
    "constant observation effort",
    "constant observation effort, matched expected sightings",
    "increasing observation effort",
    "decreasing observation effort",
    "decreasing observation effort, matched expected sightings"
  ),
  labels = c(
    "Constant effort",
    "Constant effort,\nmatched sightings",
    "Increasing effort",
    "Decreasing effort",
    "Decreasing effort,\nmatched sightings"
  )
)

summary <- aggregate(
  cbind(date_error, absolute_date_error) ~ scenario + estimator,
  data = comparison,
  FUN = mean,
  na.rm = TRUE
)
summary$label <- sprintf("MAE %.1f", summary$absolute_date_error)

palette <- c(
  "Solow: threshold 0.5" = "#4C78A8",
  "Solow: posterior median te" = "#72B7B2",
  "Effort model: threshold 0.5" = "#F58518",
  "Effort model: posterior median te" = "#54A24B"
)

plot <- ggplot2::ggplot(
  comparison,
  ggplot2::aes(x = date_error, y = estimator, fill = estimator)
) +
  ggplot2::geom_vline(xintercept = 0, linetype = "dashed", color = "grey35", linewidth = 0.35) +
  ggplot2::geom_boxplot(width = 0.68, outlier.alpha = 0.35, linewidth = 0.35) +
  ggplot2::geom_text(
    data = summary,
    ggplot2::aes(x = 18.5, y = estimator, label = label),
    inherit.aes = FALSE,
    size = 3
  ) +
  ggplot2::facet_wrap(~ scenario, ncol = 1) +
  ggplot2::scale_fill_manual(values = palette) +
  ggplot2::coord_cartesian(xlim = c(-18, 20), clip = "off") +
  ggplot2::labs(
    x = "Estimated extinction year - true extinction year",
    y = NULL
  ) +
  ggplot2::theme_bw(base_size = 10) +
  ggplot2::theme(
    legend.position = "none",
    strip.background = ggplot2::element_rect(fill = "grey92", color = "grey60"),
    plot.margin = ggplot2::margin(5.5, 18, 5.5, 5.5)
  )

pdf_file <- file.path(figures_dir, "extinction_quantile_estimator_comparison.pdf")
png_file <- file.path(figures_dir, "extinction_quantile_estimator_comparison.png")

ggplot2::ggsave(pdf_file, plot, width = 7.5, height = 6)
ggplot2::ggsave(png_file, plot, width = 7.5, height = 6, dpi = 300)

message("Wrote: ", pdf_file)
message("Wrote: ", png_file)
