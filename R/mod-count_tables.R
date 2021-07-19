count_tables_ui <- function(id) {
  ns <- NS(id)
  fluidRow(
    column(4, tableOutput(ns("diag"))),
    column(4, tableOutput(ns("body_part"))),
    column(4, tableOutput(ns("location")))
  )
}

count_tables_server <- function(id, selected) {
  stopifnot(is.reactive(selected))

  moduleServer(id, function(input, output, session) {
    output$diag <- renderTable(
      count_by_weight(selected(), "diag")
    )
    output$body_part <- renderTable(
      count_by_weight(selected(), "body_part")
    )
    output$location <- renderTable(
      count_by_weight(selected(), "location")
    )
  })
}