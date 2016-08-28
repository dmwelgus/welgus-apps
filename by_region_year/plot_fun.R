plot_fun <- function(fill_var, title, df) {
  
    ggplot(df) + 
      aes_string(x = "long", y = "lat", group = "group", fill = fill_var) +
      geom_polygon() +
      geom_path(color = "black") +
      coord_equal() +
      scale_fill_continuous(low = "#edf8fb", high = "#810f7c", na.value = "#f7fcfd", guide = guide_colorbar(title = fill_var)) +
      theme(axis.text.x = element_blank(), axis.text.y = element_blank(), 
            axis.title.x = element_blank(), axis.title.y = element_blank(),
            axis.ticks = element_blank(), panel.background = element_rect(fill = "white"), panel.grid.major = element_line(colour = "white"),
            panel.grid.minor = element_line(colour = "white")) +
      ggtitle(title)
  
}