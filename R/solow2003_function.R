#' solow2003_function
#'
#' @param sightings
#' @param alpha
#'
#' @return solow2003_function - estimated
#' @export
#'
#' @examples
#'
solow2003_function <- function(sightings, alpha) {
  # Create a two column data base with year and sightings

  dd = data.frame(
    year = sightings,
    sights = 1
  )
  # Remove rows with non-positive values in the second column
  dd <- dd[dd[, 2] > 0, ]

  # Sort the first column in descending order
  sights <- sort(dd[, 1], decreasing = TRUE)
  n <- length(sights)

  # Calculate v
  v <- (1 / (n - 1)) * sum(log((sights[1] - sights[n]) / (sights[1] - sights[2:(n - 1)])))

  # Create a vector of ones and calculate SL and SU
  e <- rep(1, n)
  SL <- (-log(1 - alpha / 2) / n)^(-v)
  SU <- (-log(alpha / 2) / n)^(-v)

  # Define a function for lambda calculation

  myfun <- function(i, j, v) {
    (gamma(2 * v + i) * gamma(v + j)) / (gamma(v + i) * gamma(j))
  }

  # Calculate lambda matrix
  lambda <- outer(1:n, 1:n, myfun, v = v)
  lambda <- ifelse(lower.tri(lambda), lambda, t(lambda))

  # Calculate a vector
  a <- as.vector(solve(t(e) %*% solve(lambda) %*% e)) * solve(lambda) %*% e

  # Calculate lower and upper confidence intervals
  lowerCI <- max(sights) + ((max(sights) - min(sights)) / (SL - 1))
  upperCI <- max(sights) + ((max(sights) - min(sights)) / (SU - 1))

  # Calculate the estimate
  extest <- sum(a * sights)

  # Create the result data frame
  res <- data.frame(Estimate = extest, lowerCI = lowerCI, upperCI = upperCI)

  res
}
