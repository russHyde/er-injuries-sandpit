test_that("it returns in count-sorted order", {
  df <- tibble::tibble(
    x = c(rep("a", 5), rep("b", 3), rep("c", 9)),
    weight = 1
  )

  counted <- count_by_weight(df, column = "x")
  expect_equal(
    object = counted[["n"]],
    expected = sort(counted[["n"]])
  )
})
