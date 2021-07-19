# TODO: test that the summary() data frame updates correctly (a bit harder than the test here)

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
  server <- make_er_server(
    injuries = test_injuries,
    products = test_products,
    population = test_population
  )

  # check that the 'selected' table updates correctly
  testServer(
    server,
    {
      session$setInputs(code = 2345)

      expect_equal(
        selected(),
        test_injuries[integer(0), ]
      )

      session$setInputs(code = 1234)

      expect_equal(
        selected(),
        test_injuries[c(1, 3), ]
      )
    }
  )
})
