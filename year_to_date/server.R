# server.R

library(shiny)
library(jsonlite)
library(curl)
source("year_to_date.R")
source("stop_date.R")


shinyServer(function(input, output) {
  
  base_date  <- get_stopDate()
  base_year  <- substr(base_date, 1, 4)
  base_month <- substr(base_date, 6, 7)
  base_day   <- substr(base_date, 9, 10)
  

  data <- reactive({
    
    input_date  <- as.Date(paste(base_year, input$month, input$day, sep = "-"), "%Y-%m-%d")
    latest_date <- as.Date(base_date, "%Y-%m-%d")
    
    shiny::validate(
      shiny::need(input_date <= latest_date, paste("Error!!! Latest available date is " ,  
                                                   paste(base_month, base_day, sep = "-"), sep = " ")) 
    )
    
    x <- paste(base_year, input$month, input$day, sep = "-")
    x <- paste(x, "T23:59:59", sep = "")
      
    years <- get_years(input$years)
    
    year_to_date(years, type = input$type, stop_date = x)
    
  })
  
  
  output$table <- renderTable({

    data()
    
  }, include.rownames = TRUE)
  
  output$downloadData <- downloadHandler(
    filename = function() {paste(input$type, ".year_to_date", ".csv", sep = "")}, 
    content = function(file) {
      
      write.csv(data_table(), file, row.names = FALSE)
    }
  )
  
})