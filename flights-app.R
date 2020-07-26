# load libraries ----
library(nycflights13)
library(shiny)
library(ggplot2)
library(dplyr)

# load resources ----
source("viz-mtly.R")
source("mod-plot.R")
source("mod-text.R")
source("mod-metr.R")

# data prep ----
ua_data <-
  nycflights13::flights %>%
  filter(carrier == "UA") %>%
  mutate(ind_arr_delay = (arr_delay > 5)) %>%
  group_by(year, month, day) %>%
  summarize(
    n = n(),
    across(ends_with("delay"), mean, na.rm = TRUE)
    ) %>%
  ungroup()

# full application ----
ui <- fluidPage(
  
  titlePanel("Flight Delay Report"),
  
  sidebarLayout(
  sidebarPanel = sidebarPanel(
    selectInput("month", "Month", 
                choices = setNames(1:12, month.abb),
                selected = 1
    )
  ),
  mainPanel = mainPanel(
    h2(textOutput("title")),
    h3("Average Departure Delay"),
    metric_ui("dep_delay"),
    h3("Average Arrival Delay"),
    metric_ui("arr_delay"),
    h3("Proportion Flights with >5 Min Arrival Delay"),
    metric_ui("ind_arr_delay")
  )
)
)
server <- function(input, output, session) {
  
  output$title <- renderText({paste(month.abb[as.integer(input$month)], "Report")})
  df_month <- reactive({filter(ua_data, month == input$month)})
  metric_server("dep_delay", df_month, vbl = "dep_delay", threshhold = 10)
  metric_server("arr_delay", df_month, vbl = "arr_delay", threshhold = 10)
  metric_server("ind_arr_delay", df_month, vbl = "ind_arr_delay", threshhold = 0.5)
  
}
shinyApp(ui, server)
