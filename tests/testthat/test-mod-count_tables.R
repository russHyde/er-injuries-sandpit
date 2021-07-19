test_selected <- tibble::tibble(
  age = c(12, 34),
  prod_code = 1234,
  diag = c("A", "C"),
  body_part = c("leg", "leg"),
  location = c("Home", "Other Public Property"),
  sex = c("male", "female"),
  weight = c(20, 15)
)

expected_diag <- tibble::tibble(
  diag = c("A", "C"),
  n = c(20, 15)
)
expected_body_part <- tibble::tibble(
  body_part = "leg",
  n = 35
)
expected_location <- tibble::tibble(
  location = c("Home", "Other Public Property"),
  n = c(20, 15)
)

test_that("tables display the counts correctly", {
  rx_selected <- reactive(test_selected)

  testServer(count_tables_server, args = list(selected = rx_selected), {
    expect_equal(
      diag(),
      expected = expected_diag
    )

    expect_equal(
      body_part(),
      expected = expected_body_part
    )

    expect_equal(
      location(),
      expected = expected_location
    )
  })
})
