library(shiny)
library(ggplot2)
library(geojsonio)


shinyServer(function(input, output, session) {
  

  dataInput <- reactive({
    
    if (input$region == "Community Areas") {
      regions <- "CA Number"
      cols <- ca_names
    } else {
      regions <- "District"
      cols <- district_names
    }
    
    x <- by_region_year(year = input$year, type = input$type, region = regions)
    names(x) <- cols
    
    
    if (input$add_arrests == "Yes") {
      y <- add_arrests(year = input$year, type = input$type, region = regions)
      x <- dplyr::left_join(x, y, by = regions)
      
      if (input$region == "Police Districts") {
        cols <- append(district_names, arrest_names, after = 2)
      } else {
        cols <- append(ca_names, arrest_names, after = 3)
      }
      
      x[arrest_names][is.na(x[arrest_names])] <- 0
      
    }
    
    x[, cols]
    
  })
  
  myPlot <- reactive({
    
    x <- dataInput()
    
    if (input$region == "Community Areas") {
      
      load("ca_df.RData")
      plot_df <- ca_df
      plot_df <- merge(plot_df, x[, c("CA Number", "Total",  "Rate per 100K")], by.x = "AREA_NUMBE", by.y = "CA Number", all.x = TRUE)
      
      
    } else {
      
      load("district_df.RData")
      plot_df <- district_df
      plot_df <- merge(plot_df, x[, c("District", "Total", "Rate per 100K")], by.x = "DISTRICT", by.y = "District", all.x = TRUE)
    }
    
    
    plot_df <- plot_df[order(plot_df$order), ]
    names(plot_df)[c(ncol(plot_df) - 1, ncol(plot_df))] <- c("Total", "Rate")
    
    plot_fun(df = plot_df, fill_var = input$order_by, title = input$title)
    
  })
  
  
  
  
  # Output Table  
  output$table <- renderTable({
    
  tab <- dataInput()
  
   if(input$order_by == "Rate") {
     tab[order(-tab[, "Rate per 100K"]), ]
   } else {
     tab[order(-tab[, "Total"]), ]
   }
 }, include.rownames = FALSE)
  
  
  # Output Plot
  output$plot <- renderPlot({
    myPlot()
  })
  
  
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
  
  my_d3 <- reactive({ 
    data <- dataInput()
    
    if(input$order_by == "Rate") {
      data[order(-data[, "Rate per 100K"]), ]
    } else {
      data[order(-data[, "Total"]), ]
    }
    
    names(data) = c("ca_num", "community_area", "count", "population", "rateper100K")
    #topo_json = fromJSON('community_areas.topojson')
    session$sendCustomMessage(type="jsondata", data)
  })
  
  observeEvent(input$do, {
    my_d3()
  })
  
  
})
