library(EnvStats)
sightings <- 12 * c(6/12, 7/12, 8/12, 10/12, 1+5/12, 1+6/12, 1+7/12,1+8/12, 1+9/12, 1+10/12, 2+6/12, 2+7/12, 3+5/12, 3+8/12, 3+10/12, 4+5/12, 4+9/12, 4+10/12, 5+6/12, 7+6/12, 9+9/12, 9+10/12, 10+2/12, 10+3/12, 10+7/12, 11+7/12, 12+7/12, 12+9/12)
# sightings <- 12 * c(6/12, 7/12, 8/12, 10/12, 1+5/12, 1+6/12, 1+7/12, 1+10/12, 2+6/12, 4+9/12, 4+10/12, 5+6/12, 7+6/12, 9+9/12, 9+10/12,  12+9/12)
# sightings <- 12 * c(6/12, 4+9/12, 4+10/12, 5+6/12, 7+6/12, 9+9/12, 9+10/12, 10+2/12, 10+3/12, 10+7/12, 11+7/12, 12+7/12, 12+9/12)

start = 0
end = 229
dprior_m = solowdprior_m
dprior_te = solowdprior_te

t <- (sightings - start) / (end - start)
n = length(t)

te=0.5
alpha = 1
K = prod(t)

# Solow H0 function (integral or analytical)

integrate(
  function(m) {
    exp(alpha*n*log(m) - (m * te) ^ alpha + log(dprior_m(m)))
  },
  lower = 0,
  upper = Inf
)$value

(1/alpha)*te^(-alpha*n)*gamma(n)


# Kodicara te function (integral or analytical)

integrate(
  Vectorize(
    function(alpha) {
      exp(n*log(alpha) + (alpha-1)*log(K) -log(alpha) - alpha * n * log(te) + log(gamma(n)))
    }
  ),
  lower = 0,
  upper = Inf,
  abs.tol = 1e-8
)$value

f1 = Vectorize(function(te) {
  gamma(n) * te ^ (-n)
})

f2 = Vectorize(function(te) {
  a = gamma(n) ^ 2 / prod(t) / (n * log(te) - log(K)) ^ n
  if(is.infinite(a))
    a = 0
  a
})

aa = Vectorize(function(tt) {
  if(tt<max(t))
    return(0)
  integrate(
    f2,
    lower = max(t),
    upper = tt,
    abs.tol = 1e-8
  )$value / f2(tt)
})

bb = Vectorize(function(te) {
  1 / (1 + (1 - prior) / prior / aa(te))
})


prior = 0.5
f3 = Vectorize(function(te) {
  1 / (1 + (1 - prior) / prior / (1/(1-n)*(te^(1-n)-max(t)^(1-n))))
})

C = log(K)
f4 = Vectorize(function(tt) {
  if(tt<=max(t))
    return(0)
  1 / (1 + (1 - prior) / prior / (tt*log(tt^n/K)-max(t)*log(max(t)^n/K)))
})

f5 = Vectorize(function(tt) {
  if(tt<=max(t))
    return(1)
  1 / (1 + (1 - prior) / prior / ((n-1)/((tt/max(t))^(n*alpha-1)-1)))
})


fa = Vectorize(function(tt) {
integrate(
  Vectorize(
    function(tt) {
      exp(n*log(alpha) + (alpha-1)*log(K) -log(alpha) - alpha * n * log(tt) + log(gamma(n)))
    }
  ),
  lower = max(t),
  upper = tt,
  abs.tol = 1e-8
)$value
})

alpha = Vectorize(function(t) {
  if(t>0.8 && t < 0.85) { return(1.1)}
  return(1)
})

