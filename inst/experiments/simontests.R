library(EnvStats)

sightings <- 12 * c(
  6 / 12, 7 / 12, 8 / 12, 10 / 12, 1 + 5 / 12, 1 + 6 / 12,
  1 + 7 / 12, 1 + 8 / 12, 1 + 9 / 12, 1 + 10 / 12, 2 + 6 / 12,
  2 + 7 / 12, 3 + 5 / 12, 3 + 8 / 12, 3 + 10 / 12, 4 + 5 / 12,
  4 + 9 / 12, 4 + 10 / 12, 5 + 6 / 12, 7 + 6 / 12, 9 + 9 / 12,
  9 + 10 / 12, 10 + 2 / 12, 10 + 3 / 12, 10 + 7 / 12, 11 + 7 / 12,
  12 + 7 / 12, 12 + 9 / 12
)

start <- 0
end <- 229
dprior_m <- solowdprior_m
dprior_te <- solowdprior_te

t <- (sightings - start) / (end - start)
n <- length(t)

te <- 0.5
alpha <- 1
K <- prod(t)

integrate(
  function(m) {
    exp(alpha * n * log(m) - (m * te)^alpha + log(dprior_m(m)))
  },
  lower = 0,
  upper = Inf
)$value

(1 / alpha) * te^(-alpha * n) * gamma(n)

integrate(
  Vectorize(
    function(alpha) {
      exp(
        n * log(alpha) + (alpha - 1) * log(K) - log(alpha) -
          alpha * n * log(te) + log(gamma(n))
      )
    }
  ),
  lower = 0,
  upper = Inf,
  abs.tol = 1e-8
)$value
