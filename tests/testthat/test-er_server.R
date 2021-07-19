test_that("it updates tables when product-code changes", {
  # define test-data
  test_injuries <- tibble::tibble(
    age = c(12, 51, 34, 76),
    prod_code = c(1234, 9876, 1234, 5678),
    diag = LETTERS[1:4],
    sex = c("male", "female", "female", "male")
  )
  test_products <- tibble::tibble(
    prod_code = c(1234, 2345, 9876, 5678),
    title = c("toilets", "bathtubs", "tableware", "rugs")
  )
  test_population <- tibble::tibble(
    age = rep(c(12, 34, 51, 76), each = 2),
    sex = rep(c("female", "male"), times = 4),
    population = 1
  )

  # pass test-data into the server function
  server <- function(input, output, session) {
    er_server(
      input,
      output,
      session,
      injuries = test_injuries,
      products = test_products,
      population = test_population
    )
  }

  # check that the summary table
  # ? should we check the values of `output$location` etc ...
  testServer(
    server,
    {
      session$setInputs(code = 2345)
      expect_equal(
        some_random_variable_name(),
        1
      )

      expect_equal(
        selected(),
        test_injuries[integer(0), ]
      )

      expect_equal(
        summary(),
        expected = "BLAH"
      )
    }
  )
})
