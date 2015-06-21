# server.R

library(shiny)
source("by_month.R")


shinyServer(function(input, output) {
  
  get_years <- function(x) (x[1]:x[2])
 
  output$table <- renderTable({
    
    years <- get_years(input$years)
    
    x <- by_month(years, type = input$var)
    x$month <- substr(x$month, 1, 7)
    
    x
  }, include.rownames = FALSE)
  
  output$plot <- renderPlot({
    
    years <- get_years(input$years)
    x <- by_month(years, type = input$var)
    x$month <- as.Date(x$month, "%Y-%m-%d")
    plot(x$month, x$total, type = "l", xlab = "Month", ylab = "Total",
         main = input$var, col = "green", lwd = 2)
    
  })
})