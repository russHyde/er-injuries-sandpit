count_by_weight <- function(x, column) {
  tibble::tibble(
    {{ column }} := character(0),
    n = numeric(0)
  )
}