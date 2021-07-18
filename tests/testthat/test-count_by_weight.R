test_that("it returns the selected column, and a count column", {
  df <- tibble::tibble(
    x = letters,
    weight = 1
  )

  expect_equal(
    object = colnames(count_by_weight(df, column = "x")),
    expected = c("x", "n")
  )
})

test_that("it returns in count-sorted order", {
  df <- tibble::tibble(
    x = c(rep("a", 5), rep("b", 3), rep("c", 9)),
    weight = 1
  )

  counted <- count_by_weight(df, column = "x")
  expect_equal(
    object = counted[["n"]],
    expected = sort(counted[["n"]], decreasing = TRUE)
  )
})

test_that("count equals number of rows, when weights are all 1", {
  number_of_a <- 5
  df <- tibble::tibble(
    y = rep("a", number_of_a),
    weight = 1
  )

  expect_equal(
    count_by_weight(df, column = "y")[["n"]],
    expected = number_of_a
  )
})

test_that("non-equal weights", {
  weights <- c(0.2, 0.5, 0.7, 0.1, 0.3)
  df <- tibble::tibble(
    z = rep("a", length(weights)),
    weight = weights
  )
  expect_equal(
    count_by_weight(df, column = "z")[["n"]],
    expected = sum(weights)
  )
})
