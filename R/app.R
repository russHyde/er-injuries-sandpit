#' er_app
#'
#' @import   shiny

er_app <- function() {
  # `injuries`, `products` and `population` are package-hosted datasets
  # They can be accessed by name (but R CMD check complains about you referring to undefined vars)
  injuries <- get("injuries")
  products <- get("products")
  population <- get("population")

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

  server <- function(input, output, session) {

    selected <- reactive(injuries %>% dplyr::filter(prod_code == input$code))

    output$diag <- renderTable(
      selected() %>% dplyr::count(diag, wt = weight, sort = TRUE)
    )
    output$body_part <- renderTable(
      selected() %>% dplyr::count(body_part, wt = weight, sort = TRUE)
    )
    output$location <- renderTable(
      selected() %>% dplyr::count(location, wt = weight, sort = TRUE)
    )

    summary <- reactive({
      selected() %>%
        dplyr::count(age, sex, wt = weight) %>%
        dplyr::left_join(population, by = c("age", "sex")) %>%
        dplyr::mutate(rate = n / population * 1e4)
    })

    output$age_sex <- renderPlot(
      {
        summary() %>%
          ggplot2::ggplot(ggplot2::aes(age, n, colour = sex)) +
          ggplot2::geom_line() +
          ggplot2::labs(y = "Estimated number of injuries")
      },
      res = 96
    )
  }

  shiny::shinyApp(ui, server)
}
