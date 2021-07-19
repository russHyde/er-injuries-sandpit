#' Count the number of observations, weighted by a weight column
#'
#' @param   x    The input data. (data.frame).
#' @param   column   Some column in the input data.
#'
#' @return   A data.frame or tibble, depending on the input.
#'
#' @examples
#' df <- data.frame(x = letters[1:3], weight = 1)
#' count_by_weight(df, "x")
#'
#' tbl <- tibble::tibble(
#'   bodyPart = c("head", "head", "tail", "middle"),
#'   weight = c(10, 11, 8, 30)
#' )
#' count_by_weight(tbl, "bodyPart")
#' @export

count_by_weight <- function(x, column) {
  stopifnot(column %in% colnames(x))
  dplyr::count(x, .data[[column]], wt = .data[["weight"]], sort = TRUE)
}
