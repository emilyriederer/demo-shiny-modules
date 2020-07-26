# metric module ----
metric_ui <- function(id) {
  
  fluidRow(
    text_ui(NS(id, "metric")),
    plot_ui(NS(id, "metric"))
  )
  
}

metric_server <- function(id, df, vbl, threshhold) {
  
  moduleServer(id, function(input, output, session) {
    
    text_server("metric", df, vbl, threshhold)
    plot_server("metric", df, vbl, threshhold)
    
  })
  
}

metric_demo <- function() {
  
  df <- data.frame(day = 1:30, arr_delay = 1:30)
  ui <- fluidPage(metric_ui("x"))
  server <- function(input, output, session) {
    metric_server("x", reactive({df}), "arr_delay", 15)
  }
  shinyApp(ui, server)
  
}