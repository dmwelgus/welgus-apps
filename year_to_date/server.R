# server.R

library(shiny)
library(jsonlite)
library(curl)
source("year_to_date.R")
source("stop_date.R")


shinyServer(function(input, output) {
  
  
  date      <- get_stopDate()
  
  output$table <- renderTable({
    
    years <- get_years(input$years)
    
    year_to_date(years, type = input$type, stop_date = date)

  }, include.rownames = FALSE)
  
  output$downloadData <- downloadHandler(
    filename = function() {paste(input$type, ".year_to_date", ".csv", sep = "")}, 
    content = function(file) {
      
      get_years <- function(x) (x[1]:x[2])
      years <- get_years(input$years)
      
      x <- year_to_date(years, type = input$type)
      write.csv(x, file, row.names = FALSE)
    }
  )
  
})