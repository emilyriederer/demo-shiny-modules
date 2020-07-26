# plot module ----
plot_ui <- function(id) {
  
  fluidRow(
    column(11, plotOutput(NS(id, "plot"))),
    column( 1, downloadButton(NS(id, "dnld"), label = ""))
  )
  
}

plot_server <- function(id, df, vbl, threshhold = NULL) {
  
  moduleServer(id, function(input, output, session) {
    
    plot <- reactive({viz_monthly(df(), vbl, threshhold)})
    output$plot <- renderPlot({plot()})
    output$dnld <- downloadHandler(
      filename = function() {paste0(vbl, '.png')},
      content = function(file) {ggsave(file, plot())}
    )
    
  })
}

plot_demo <- function() {
  
  df <- data.frame(day = 1:30, arr_delay = 1:30)
  ui <- fluidPage(plot_ui("x"))
  server <- function(input, output, session) {
    plot_server("x", reactive({df}), "arr_delay")
  }
  shinyApp(ui, server)
  
}