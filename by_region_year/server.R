library(shiny)
library(ggplot2)
library(plyr)
# library(gpclib)
# gpclibPermit()

source("by_region_year.R")


shinyServer(function(input, output) {
  

  output$table <- renderTable({
    
    if (input$region == "Community Areas") {
      regions <- "CA"
      cols <- c(1, 4, 2, 3, 5, 6)
    } else {
      regions <- "District"
      cols <- c(" ", "District", "Count", "Pop", "Rate (per 100K)")
    }
    
    x <- by_region_year(year = input$year, type = input$type, order_by = input$order_by, region = regions)
    
    x <- x[, cols]
    
    if (input$region == "Police Districts") {
      x$District <- as.integer(x$District)
    }

    x
  
    }, include.rownames = FALSE) 
  
  
  
  output$plot <- renderPlot({
    
    if (input$region == "Community Areas") {
      regions <- "CA"
      title_region <- "Community Area"
      cols <- c(1, 4, 2, 3, 5, 6)
      
      x <- by_region_year(year = input$year, type = input$type, order_by = input$order_by, region = regions)
      x <- x[, cols]
      
      plot_df <- read.csv("ca_df.csv", stringsAsFactors = FALSE)
      plot_df <- merge(plot_df, x[, c(3, 4,  6)], by.x = "AREA_NUMBE", by.y = "CA", all.x = TRUE)
      
      
    } else {
      regions <- "District"
      title_region <- "Police District"
      cols <- c(" ", "District", "Count", "Pop", "Rate (per 100K)")
      
      x <- by_region_year(year = input$year, type = input$type, order_by = input$order_by, region = regions)
      x <- x[, cols]
      
      plot_df <- read.csv("district_df.csv", stringsAsFactors = FALSE)
      plot_df <- merge(plot_df, x[, c(2, 3, 5)], by.x = "DISTRICT", by.y = "District", all.x = TRUE)
    }
    
  
    plot_df <- plot_df[order(plot_df$order), ]
    names(plot_df)[c(ncol(plot_df) - 1, ncol(plot_df))] <- c("count", "rate")
    
    plot_df$count[is.na(plot_df$count)] <- 0
    plot_df$rate[is.na(plot_df$rate)]  <- 0
    
    
    
    if (input$order_by == "rate") {
      
#      title <- paste(input$type, "Rate", "by", input$region, input$year, sep = " ")
      
    ggplot(plot_df) + 
      aes(long, lat, group = group, fill = rate) +
      geom_polygon() +
      geom_path(color = "black") +
      coord_equal() +
      scale_fill_continuous(low = "#ffeda0", high = "#800026", na.value = "#ffffcc") +
      theme(axis.text.x = element_blank(), axis.text.y = element_blank(), 
            axis.title.x = element_blank(), axis.title.y = element_blank(),
            axis.ticks = element_blank(), panel.background = element_rect(fill = "white"), panel.grid.major = element_line(colour = "white"),
            panel.grid.minor = element_line(colour = "white")) +
      ggtitle(input$title)
    
    } else {
      
#      title <- paste("Crime Counts by", title_region)
      ggplot(plot_df) + 
        aes(long, lat, group = group, fill = count) +
        geom_polygon() +
        geom_path(color = "black") +
        coord_equal() +
        scale_fill_continuous(low = "#ffeda0", high = "#800026", na.value = "#ffffcc") +
        theme(axis.text.x = element_blank(), axis.text.y = element_blank(), 
            axis.title.x = element_blank(), axis.title.y = element_blank(),
            axis.ticks = element_blank(), panel.background = element_rect(fill = "white"), panel.grid.major = element_line(colour = "white"),
            panel.grid.minor = element_line(colour = "white")) +
        ggtitle(input$title)
      
    }
    
  })
  
  
  output$downloadData <- downloadHandler(
    filename = paste(input$type, "by", input$region, input$year, ".csv", sep = ""), 
    content = function(file) {
      if (input$region == "Community Areas") {
        regions <- "CA"
        cols <- c(1, 4, 2, 3, 5, 6)
      } else {
        regions <- "District"
        cols <- c(" ", "District", "Count", "Pop", "Rate (per 100K)")
      }
      
      x <- by_region_year(year = input$year, type = input$type, order_by = input$order_by, region = regions)
      x <- x[, cols]
      
      write.csv(x, file, row.names = FALSE)
    }
  )
  
  output$downloadPlot <- downloadHandler(
    filename = function() {paste(input$type, "by", input$region, input$year, ".png", sep = "")},
    
    content = function(file) {
    
      if (input$region == "Community Areas") {
      regions <- "CA"
      title_region <- "Community Area"
      cols <- c(1, 4, 2, 3, 5, 6)
      
      x <- by_region_year(year = input$year, type = input$type, order_by = input$order_by, region = regions)
      x <- x[, cols]
      
      plot_df <- read.csv("ca_df.csv", stringsAsFactors = FALSE)
      plot_df <- merge(plot_df, x[, c(3, 4,  6)], by.x = "AREA_NUMBE", by.y = "CA", all.x = TRUE)
      
      
    } else {
      regions <- "District"
      title_region <- "Police District"
      cols <- c(" ", "District", "Count", "Pop", "Rate (per 100K)")
      
      x <- by_region_year(year = input$year, type = input$type, order_by = input$order_by, region = regions)
      x <- x[, cols]
      
      plot_df <- read.csv("district_df.csv", stringsAsFactors = FALSE)
      plot_df <- merge(plot_df, x[, c(2, 3, 5)], by.x = "DISTRICT", by.y = "District", all.x = TRUE)
    }
    
    
    plot_df <- plot_df[order(plot_df$order), ]
    names(plot_df)[c(ncol(plot_df) - 1, ncol(plot_df))] <- c("count", "rate")
    
    plot_df$count[is.na(plot_df$count)] <- 0
    plot_df$rate[is.na(plot_df$rate)]  <- 0
    
    
    
    if (input$order_by == "rate") {
      
#      title <- paste("Crime Rates by", title_region)
      
      my_plot <- ggplot(plot_df) + 
                  aes(long, lat, group = group, fill = rate) +
                  geom_polygon() +
                  geom_path(color = "black") +
                  coord_equal() +
                  scale_fill_continuous(low = "#ffeda0", high = "#800026", na.value = "#ffffcc") +
                  theme(axis.text.x = element_blank(), axis.text.y = element_blank(), 
                  axis.title.x = element_blank(), axis.title.y = element_blank(),
                  axis.ticks = element_blank(), panel.background = element_rect(fill = "white"), panel.grid.major = element_line(colour = "white"),
                  panel.grid.minor = element_line(colour = "white")) +
                  ggtitle(input$title)
      
    } else {
      
#      title <- paste("Crime Counts by", title_region)
      my_plot <- ggplot(plot_df) + 
                    aes(long, lat, group = group, fill = count) +
                    geom_polygon() +
                    geom_path(color = "black") +
                    coord_equal() +
                    scale_fill_continuous(low = "#ffeda0", high = "#800026", na.value = "#ffffcc") +
                    theme(axis.text.x = element_blank(), axis.text.y = element_blank(), 
                    axis.title.x = element_blank(), axis.title.y = element_blank(),
                    axis.ticks = element_blank(), panel.background = element_rect(fill = "white"), panel.grid.major = element_line(colour = "white"),
                    panel.grid.minor = element_line(colour = "white")) +
                    ggtitle(input$title)
      
    }
    
    
    ggsave(file, plot = my_plot)
  })
  
})
