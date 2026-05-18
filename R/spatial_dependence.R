#' Build an adjacency list for a regular spatial grid
#'
#' @param nrow Number of grid rows.
#' @param ncol Number of grid columns.
#' @param diagonal Logical. If `TRUE`, diagonal neighbours are included.
#'
#' @return A list of integer vectors. Each element contains the linear indices
#'   of the neighbours of one grid cell.
#' @export
#'
#' @examples
#' make_grid_adjacency(2, 2)
make_grid_adjacency <- function(nrow, ncol, diagonal = FALSE) {
  if (nrow < 1 || ncol < 1) {
    stop("`nrow` and `ncol` must be positive integers.", call. = FALSE)
  }

  offsets <- rbind(
    c(-1, 0),
    c(1, 0),
    c(0, -1),
    c(0, 1)
  )

  if (isTRUE(diagonal)) {
    offsets <- rbind(
      offsets,
      c(-1, -1),
      c(-1, 1),
      c(1, -1),
      c(1, 1)
    )
  }

  adjacency <- vector("list", nrow * ncol)

  for (row in seq_len(nrow)) {
    for (col in seq_len(ncol)) {
      neighbours <- apply(offsets, 1, function(offset) {
        neighbour_row <- row + offset[1]
        neighbour_col <- col + offset[2]

        if (
          neighbour_row < 1 || neighbour_row > nrow ||
            neighbour_col < 1 || neighbour_col > ncol
        ) {
          return(NA_integer_)
        }

        cbind_index(neighbour_row, neighbour_col, nrow)
      })

      neighbours <- as.integer(neighbours)
      adjacency[[cbind_index(row, col, nrow)]] <- neighbours[!is.na(neighbours)]
    }
  }

  adjacency
}

#' Smooth spatial posterior curves using neighbouring cells
#'
#' This function applies a transparent neighbour-informed adjustment to spatial
#' posterior probability curves. It is a spatial smoothing method, not a full
#' hierarchical spatial model.
#'
#' @param spatial_posterior Matrix/list returned by
#'   [spatial_posterior_probability_extinction_varying_end_year()].
#' @param rho Numeric value between 0 and 1 controlling neighbour influence.
#'   `rho = 0` returns the independent local posteriors. Larger values borrow
#'   more information from neighbouring cells.
#' @param adjacency Optional adjacency list. If `NULL`, rook neighbours are used
#'   for the dimensions of `spatial_posterior`.
#' @param iterations Number of smoothing iterations.
#' @param eps Small value used to keep probabilities away from 0 and 1 before
#'   applying the logit transform.
#'
#' @return Matrix/list of smoothed posterior probability vectors.
#' @export
#'
#' @examples
#' grid <- list(c(1880, 1883, 1895), c(1881, 1884, 1892), NA, c(1882, 1884, 1896))
#' dim(grid) <- c(2, 2)
#' posterior <- spatial_posterior_probability_extinction_varying_end_year(grid, 1880, 1900)
#' smooth_spatial_posterior(posterior, rho = 0.25)
smooth_spatial_posterior <- function(
  spatial_posterior,
  rho = 0.25,
  adjacency = NULL,
  iterations = 1,
  eps = 1e-6
) {
  if (is.null(dim(spatial_posterior))) {
    stop("`spatial_posterior` must have grid dimensions.", call. = FALSE)
  }

  if (!is.numeric(rho) || length(rho) != 1 || rho < 0 || rho > 1) {
    stop("`rho` must be a single numeric value between 0 and 1.", call. = FALSE)
  }

  if (iterations < 1) {
    stop("`iterations` must be at least 1.", call. = FALSE)
  }

  grid_dim <- dim(spatial_posterior)
  if (is.null(adjacency)) {
    adjacency <- make_grid_adjacency(grid_dim[1], grid_dim[2])
  }

  posterior <- as.vector(spatial_posterior)
  smoothed <- posterior

  for (iteration in seq_len(iterations)) {
    previous <- smoothed

    for (cell in seq_along(previous)) {
      local_curve <- previous[[cell]]
      if (!is_probability_curve(local_curve)) next

      neighbour_indices <- adjacency[[cell]]
      neighbour_curves <- previous[neighbour_indices]
      neighbour_curves <- Filter(is_probability_curve, neighbour_curves)

      if (length(neighbour_curves) == 0) next

      neighbour_logit <- Reduce(
        "+",
        lapply(neighbour_curves, function(curve) {
          stats::qlogis(clamp_probability(as.numeric(curve), eps))
        })
      ) / length(neighbour_curves)

      local_logit <- stats::qlogis(clamp_probability(as.numeric(local_curve), eps))
      smoothed[[cell]] <- stats::plogis((1 - rho) * local_logit + rho * neighbour_logit)
    }
  }

  dim(smoothed) <- grid_dim
  smoothed
}

#' Extract the final posterior probability from each spatial cell
#'
#' @param spatial_posterior Matrix/list of posterior probability vectors.
#'
#' @return Numeric matrix with the final posterior probability for each cell.
#' @export
final_year_probability_grid <- function(spatial_posterior) {
  grid_dim <- dim(spatial_posterior)
  if (is.null(grid_dim)) {
    stop("`spatial_posterior` must have grid dimensions.", call. = FALSE)
  }

  matrix(
    vapply(
      as.vector(spatial_posterior),
      function(x) {
        if (!is_probability_curve(x)) return(NA_real_)
        utils::tail(as.numeric(x), 1)
      },
      numeric(1)
    ),
    nrow = grid_dim[1],
    ncol = grid_dim[2]
  )
}

cbind_index <- function(row, col, nrow) {
  row + (col - 1) * nrow
}

is_probability_curve <- function(x) {
  is.numeric(x) && length(x) > 1 && !all(is.na(x))
}

clamp_probability <- function(x, eps) {
  pmin(pmax(x, eps), 1 - eps)
}
