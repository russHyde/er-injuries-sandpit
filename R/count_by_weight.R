count_by_weight <- function(x, column) {
  dplyr::count(x, .data[[column]], wt = .data[["weight"]], sort = TRUE)
}
