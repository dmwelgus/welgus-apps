# server.R

library(shiny)
library(jsonlite)
library(curl)
source("year_to_date.R")
source("stop_date.R")


shinyServer(function(input, output) {
  
  
  date      <- get_stopDate()
  
  data_table <- reactive({
    
    years <- get_years(input$years)
    
    year_to_date(years, type = input$type, stop_date = date)

  })
  
  output$table <- renderTable({
    
    data_table()
  }, include.rownames = TRUE)
  
  output$downloadData <- downloadHandler(
    filename = function() {paste(input$type, ".year_to_date", ".csv", sep = "")}, 
    content = function(file) {
      
      write.csv(data_table(), file, row.names = FALSE)
    }
  )
  
})