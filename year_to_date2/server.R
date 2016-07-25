# server.R

library(shiny)
library(jsonlite)
library(curl)
source("year_to_date2.R")
source("stop_date.R")


shinyServer(function(input, output) {
  
  date      <- get_stopDate()
  
  tab_list  <- year_to_date2()
  
  tab <- reactive({
    
    if (input$Table_Type == "Crime Categories") {
      x <- tab_list[[1]]
    } else {
      x <- tab_list[[2]]
    }
    
    x
    
  })
  
  output$table <- renderTable ({

    tab()
    
    
  })
  
  output$downloadData <- downloadHandler(
    
    filename = function() {paste("Year_to_Date_Crime", substr(get_stopDate(), 6, 10), ".csv", sep = "")}, 
    content = function(file) {
         
      
      write.csv(tab(), file)
    }
  )
  
  
})