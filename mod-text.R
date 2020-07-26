# text module ----
text_ui <- function(id) {
  
  fluidRow(
    textOutput(NS(id, "text"))
  )
  
}

text_server <- function(id, df, vbl, threshhold) {
  
  moduleServer(id, function(input, output, session) {
    
    n <- reactive({sum(df()[[vbl]] > threshhold)})
    output$text <- renderText({
      paste("In this month", 
            vbl, 
            "exceeded the average daily threshhold of",
            threshhold,
            "a total of", 
            n(), 
            "days")
    })
    
  })
  
}

text_demo <- function() {
  
  df <- data.frame(day = 1:30, arr_delay = 1:30)
  ui <- fluidPage(text_ui("x"))
  server <- function(input, output, session) {
    text_server("x", reactive({df}), "arr_delay", 15)
  }
  shinyApp(ui, server)
  
}