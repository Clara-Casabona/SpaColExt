#' SpaColExt: Infer spatial colonization and extinction dates
#'
#' SpaColExt implements Bayesian estimators for extinction inference from
#' sighting records, including Solow-style estimators and spatial wrappers for
#' gridded sighting data.
#'
#' @keywords internal
#' @importFrom stats approxfun integrate
"_PACKAGE"

utils::globalVariables(c("posterior", "site", "value", "year"))
