plot_fun <- function(fill_var, title, df) {
  
  if (fill_var == "Rate") {
    ggplot(df) + 
      aes(long, lat, group = group, fill = rate) +
      geom_polygon() +
      geom_path(color = "black") +
      coord_equal() +
      scale_fill_continuous(low = "#edf8fb", high = "#810f7c", na.value = "#f7fcfd", guide = guide_colorbar(title = "Rate")) +
      theme(axis.text.x = element_blank(), axis.text.y = element_blank(), 
            axis.title.x = element_blank(), axis.title.y = element_blank(),
            axis.ticks = element_blank(), panel.background = element_rect(fill = "white"), panel.grid.major = element_line(colour = "white"),
            panel.grid.minor = element_line(colour = "white")) +
      ggtitle(title)
    
  } else {
    
    ggplot(df) + 
      aes(long, lat, group = group, fill = count) +
      geom_polygon() +
      geom_path(color = "black") +
      coord_equal() +
      scale_fill_continuous(low = "#edf8fb", high = "#810f7c", na.value = "#f7fcfd", guide = guide_colorbar(title = "Count")) +
      theme(axis.text.x = element_blank(), axis.text.y = element_blank(), 
            axis.title.x = element_blank(), axis.title.y = element_blank(),
            axis.ticks = element_blank(), panel.background = element_rect(fill = "white"), panel.grid.major = element_line(colour = "white"),
            panel.grid.minor = element_line(colour = "white")) +
      ggtitle(title)
  }
  
  
}