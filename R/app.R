#' er_app
#'
#' @import   shiny

er_app <- function() {
  # `injuries`, `products` and `population` are package-hosted datasets
  # They can be accessed by name (but R CMD check complains about you referring to undefined vars)
  injuries <- get("injuries")
  products <- get("products")
  population <- get("population")

  ui <- er_ui(products = products)

  server <- purrr::partial(
    er_server,
    injuries = injuries, products = products, population = population
  )

  shiny::shinyApp(ui, server)
}

er_ui <- function(products) {
  prod_codes <- stats::setNames(products$prod_code, products$title)

  ui <- fluidPage(
    fluidRow(
      column(
        6,
        selectInput("code", "Product", choices = prod_codes)
      )
    ),
    fluidRow(
      column(4, tableOutput("diag")),
      column(4, tableOutput("body_part")),
      column(4, tableOutput("location"))
    ),
    fluidRow(
      column(12, plotOutput("age_sex"))
    )
  )

  ui
}

er_server <- function(input,
                      output,
                      session,
                      injuries,
                      products,
                      population) {
  some_random_variable_name <- reactive(1)

  selected <- reactive({
    injuries %>% dplyr::filter(.data[["prod_code"]] == input$code)
  })

  output$diag <- renderTable(
    count_by_weight(selected(), "diag")
  )
  output$body_part <- renderTable(
    count_by_weight(selected(), "body_part")
  )
  output$location <- renderTable(
    count_by_weight(selected(), "location")
  )

  summary <- reactive({
    selected() %>%
      dplyr::count(.data[["age"]], .data[["sex"]], wt = .data[["weight"]]) %>%
      dplyr::left_join(population, by = c("age", "sex")) %>%
      dplyr::mutate(rate = .data[["n"]] / .data[["population"]] * 1e4)
  })

  output$age_sex <- renderPlot(
    {
      summary() %>%
        ggplot2::ggplot(ggplot2::aes(.data[["age"]], .data[["n"]], colour = .data[["sex"]])) +
        ggplot2::geom_line() +
        ggplot2::labs(y = "Estimated number of injuries")
    },
    res = 96
  )
}
