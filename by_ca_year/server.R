library(shiny)
library(rgdal)
library(maptools)
library(ggplot2)
library(plyr)
# library(gpclib)
# gpclibPermit()

source("by_ca_year.R")


shinyServer(function(input, output) {
  
  
  
  output$table <- renderTable({
    
    x <- by_ca_year(input$year, input$type, input$order_by)
    x <- x[, c(1, 4, 2, 3, 5, 6)]
    
    x
  }, include.rownames = FALSE) 
  
  
  
  output$plot <- renderPlot({
    
    x <- by_ca_year(input$year, input$type, input$order_by)
    x <- x[, c(1, 4, 2, 3, 5, 6)]
   
    chi.df <- read.csv("chi_df.csv", stringsAsFactors = FALSE)
    chi.df <- merge(chi.df, x[, c(3, 4,  6)], by.x = "AREA_NUMBE", by.y = "CA", all.x = TRUE)
    
    chi.df <- chi.df[order(chi.df$order), ]
    names(chi.df)[c(17, 18)] <- c("count", "rate")
    
    if (input$order_by == "rate") {
    ggplot(chi.df) + 
      aes(long, lat, group = group, fill = rate) +
      geom_polygon() +
      geom_path(color="white") +
      coord_equal() +
      scale_fill_continuous(low = "#ffeda0", high = "#800026", na.value = "#ffffcc") +
      ggtitle("Crime Rates by Community Area")
    
    } else {
      ggplot(chi.df) + 
        aes(long, lat, group = group, fill = count) +
        geom_polygon() +
        geom_path(color="white") +
        coord_equal() +
        scale_fill_continuous(low = "#ffeda0", high = "#800026", na.value = "#ffffcc") +
        ggtitle("Crime Counts by Community Area")
      
    }
    
  })
  
  
  })
