count_by_weight <- function(x, column) {
  dplyr::count(x, .data[[ column ]], sort = TRUE)
}