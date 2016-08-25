library(shiny)
library(ggplot2)
library(plyr)


source("by_region_year.R")
source("plot_fun.R")

shinyServer(function(input, output) {
  
  
  
  dataInput <- reactive({
    
    if (input$region == "Community Areas") {
      regions <- "CA"
      cols <- c(3, 1, 2, 4, 5)
    } else {
      regions <- "District"
      cols <- c( "District", "Count", "Pop", "Rate (per 100K)")
    }
    
    x <- by_region_year(year = input$year, type = input$type, order_by = "Rate", region = regions)
    
    x <- x[, cols]
    
    if (input$region == "Police Districts") {
      x$District <- as.integer(x$District)
    }
    
    x
    
  })
  
  output$plot <- renderPlot({
    
    if (input$region == "Community Areas") {
      
      x <- dataInput()  
      load("ca_df.RData")
      plot_df <- ca_df
      plot_df <- merge(plot_df, x[, c(2, 3,  5)], by.x = "AREA_NUMBE", by.y = "CA", all.x = TRUE)
      
      
    } else {
      
      x <- dataInput()
      load("district_df.RData")
      plot_df <- district_df
      plot_df <- merge(plot_df, x[, c(1, 2, 4)], by.x = "DISTRICT", by.y = "District", all.x = TRUE)
    }
    
    
    plot_df <- plot_df[order(plot_df$order), ]
    names(plot_df)[c(ncol(plot_df) - 1, ncol(plot_df))] <- c("count", "rate")
    
    plot_df$count[is.na(plot_df$count)] <- 0
    plot_df$rate[is.na(plot_df$rate)]   <- 0
    
    
    plot_fun(df = plot_df, fill_var = input$order_by, title = input$title)
    
    
  })
    
  output$table <- renderTable({
    
  tab <- dataInput()
  
   if(input$order_by == "Rate") {
     tab[order(-tab[, ncol(tab)]), ]
     
   } else {
     tab[order(-tab[, "Count"]), ]
   }
  
    }, include.rownames = FALSE) 
  
  
  
  output$downloadData <- downloadHandler(
    filename = function() {paste(input$type, "by", input$region, input$year, ".csv", sep = "")}, 
    content = function(file) {
      
      
      write.csv(dataInput(), file, row.names = FALSE)
    }
  )
  
  output$downloadPlot <- downloadHandler(
    filename = function() {paste(input$type, "by", input$region, input$year, ".png", sep = "")},
    
    content = function(file) {
    ggsave(file, plot = myPlot())
  })
  
})
