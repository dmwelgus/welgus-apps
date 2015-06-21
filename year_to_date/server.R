# server.R

library(shiny)
source("year_to_date.R")


shinyServer(function(input, output) {
  
  get_years <- function(x) (x[1]:x[2])
 
  output$table <- renderTable({
    
    years <- get_years(input$years)
    
    year_to_date(years, type = input$type)

  }, include.rownames = FALSE)
  
})