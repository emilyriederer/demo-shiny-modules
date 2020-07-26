# # load libraries ----
# library(nycflights13)
# library(shiny)
# library(ggplot2)
# library(dplyr)
# 
# # data prep ----
# ua_data <-
#   nycflights13::flights %>%
#   filter(carrier == "UA") %>%
#   mutate(ind_arr_delay = (arr_delay > 5)) %>%
#   group_by(year, month, day) %>%
#   summarize(
#     n = n(),
#     across(ends_with("delay"), mean, na.rm = TRUE)
#   ) %>%
#   ungroup()
# 
# # plotting function ----
# viz_monthly <- function(df, y_var, threshhold = NULL) {
#   
#   ggplot(df) +
#     aes(
#       x = .data[["day"]],
#       y = .data[[y_var]]
#     ) +
#     geom_line() +
#     geom_hline(yintercept = threshhold, color = "red", linetype = 2) +
#     scale_x_continuous(breaks = seq(1, 29, by = 7)) +
#     theme_minimal()
# }
# 
# # plot module ----
# plot_ui <- function(id) {
#   
#   fluidRow(
#     column(11, plotOutput(NS(id, "plot"))),
#     column( 1, downloadButton(NS(id, "dnld"), label = ""))
#   )
#   
# }
# 
# plot_server <- function(id, df, vbl, threshhold = NULL) {
#   
#   moduleServer(id, function(input, output, session) {
#     
#     plot <- reactive({viz_monthly(df(), vbl, threshhold)})
#     output$plot <- renderPlot({plot()})
#     output$dnld <- downloadHandler(
#       filename = function() {paste0(vbl, '.png')},
#       content = function(file) {ggsave(file, plot())}
#     )
#     
#   })
# }
# 
# plot_demo <- function() {
#   
#   df <- data.frame(day = 1:30, arr_delay = 1:30)
#   ui <- fluidPage(plot_ui("x"))
#   server <- function(input, output, session) {
#     plot_server("x", reactive({df}), "arr_delay")
#   }
#   shinyApp(ui, server)
#   
# }
# 
# # text module ----
# text_ui <- function(id) {
#   
#   fluidRow(
#     textOutput(NS(id, "text"))
#   )
#   
# }
# 
# text_server <- function(id, df, vbl, threshhold) {
#   
#   moduleServer(id, function(input, output, session) {
#     
#     n <- reactive({sum(df()[[vbl]] > threshhold)})
#     output$text <- renderText({
#       paste("In this month", 
#             vbl, 
#             "exceeded the average daily threshhold of",
#             threshhold,
#             "a total of", 
#             n(), 
#             "days")
#     })
#     
#   })
#   
# }
# 
# text_demo <- function() {
#   
#   df <- data.frame(day = 1:30, arr_delay = 1:30)
#   ui <- fluidPage(text_ui("x"))
#   server <- function(input, output, session) {
#     text_server("x", reactive({df}), "arr_delay", 15)
#   }
#   shinyApp(ui, server)
#   
# }
# 
# # metric module ----
# metric_ui <- function(id) {
#   
#   fluidRow(
#     text_ui(NS(id, "metric")),
#     plot_ui(NS(id, "metric"))
#   )
#   
# }
# 
# metric_server <- function(id, df, vbl, threshhold) {
#   
#   moduleServer(id, function(input, output, session) {
#     
#     text_server("metric", df, vbl, threshhold)
#     plot_server("metric", df, vbl, threshhold)
#     
#   })
#   
# }
# 
# metric_demo <- function() {
#   
#   df <- data.frame(day = 1:30, arr_delay = 1:30)
#   ui <- fluidPage(metric_ui("x"))
#   server <- function(input, output, session) {
#     metric_server("x", reactive({df}), "arr_delay", 15)
#   }
#   shinyApp(ui, server)
#   
# }
# 
# # full application ----
# ui <- fluidPage(
#   
#   titlePanel("Flight Delay Report"),
#   
#   sidebarLayout(
#     sidebarPanel = sidebarPanel(
#       selectInput("month", "Month", 
#                   choices = setNames(1:12, month.abb),
#                   selected = 1
#       )
#     ),
#     mainPanel = mainPanel(
#       h2(textOutput("title")),
#       h3("Average Departure Delay"),
#       metric_ui("dep_delay"),
#       h3("Average Arrival Delay"),
#       metric_ui("arr_delay"),
#       h3("Proportion Flights with >5 Min Arrival Delay"),
#       metric_ui("ind_arr_delay")
#     )
#   )
# )
# server <- function(input, output, session) {
#   
#   output$title <- renderText({paste(month.abb[as.integer(input$month)], "Report")})
#   df_month <- reactive({filter(ua_data, month == input$month)})
#   metric_server("dep_delay", df_month, vbl = "dep_delay", threshhold = 10)
#   metric_server("arr_delay", df_month, vbl = "arr_delay", threshhold = 10)
#   metric_server("ind_arr_delay", df_month, vbl = "ind_arr_delay", threshhold = 0.5)
#   
# }
# shinyApp(ui, server)
