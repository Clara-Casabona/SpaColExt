test_that("Solow 1993 posterior is reproducible for the README example", {
  posterior <- compute_posterior_solow1993(
    sightings = c(1901, 1902, 1903, 1905, 1908, 1910),
    start_year = 1900,
    end_year = 1920,
    dprior_m = solowdprior_m,
    dprior_te = solowdprior_te,
    prior = 0.5
  )

  expect_equal(posterior, 0.1388889, tolerance = 1e-7)
})

test_that("canonical likelihood names are available", {
  scaled_sightings <- (c(1901, 1902, 1903, 1905, 1908, 1910) - 1900) / (1920 - 1900)

  likelihood <- compute_likelihood_extinction_at_te(
    t = scaled_sightings,
    te = 1,
    dprior_m = solowdprior_m
  )

  expect_type(likelihood, "double")
  expect_gt(likelihood, 0)
})

test_that("varying end-year posterior returns one value per analysis year", {
  posterior <- posterior_probability_extinction_varying_end_year(
    sightings = c(1901, 1902, 1903, 1905, 1908, 1910),
    start_year = 1900,
    stop_year = 1920
  )

  expect_length(posterior, 21)
  expect_true(all(posterior >= 0 & posterior <= 1))
  expect_equal(posterior[1:11], rep(1, 11))
})

test_that("colonization transform uses explicit study bounds", {
  expect_equal(
    transform_and_reverse(c(1901, 1902, 1903), t_start = 1900, t_end = 1920),
    c(1917, 1918, 1919)
  )
})

test_that("colonization posterior returns one probability per year", {
  posterior <- posterior_probability_colonization_varying_year(
    sightings = c(2002, 2004, 2008, 2012),
    start_year = 1980,
    stop_year = 2020
  )

  expect_length(posterior, 41)
  expect_true(all(posterior >= 0 & posterior <= 1, na.rm = TRUE))
  expect_equal(tail(posterior, 9), rep(1, 9))
})

test_that("deprecated misspelled aliases still work during transition", {
  scaled_sightings <- (c(1901, 1902, 1903, 1905, 1908, 1910) - 1900) / (1920 - 1900)

  expect_warning(
    old <- compute_likelyhood_extinction_at_te(
      t = scaled_sightings,
      te = 1,
      dprior_m = solowdprior_m
    ),
    "deprecated"
  )

  new <- compute_likelihood_extinction_at_te(
    t = scaled_sightings,
    te = 1,
    dprior_m = solowdprior_m
  )

  expect_equal(old, new)
})
