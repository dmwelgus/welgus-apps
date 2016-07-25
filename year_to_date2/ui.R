library(jsonlite)
source("stop_date.R")

stop_date <- get_stopDate()
title <- paste("Year to Date Crime: 1-1 to ", substr(stop_date, 6, 10), sep = "")

shinyUI(fluidPage(
  titlePanel("Crime in Chicago: Year to Date"),
  
  sidebarLayout(
    sidebarPanel(
      helpText("Year-to-date Crime totals"),
      
      selectInput("Table_Type", 
                  label = "Select a Table Type",
                  choices = list("Crime Categories", "Raw FBI Codes"),
                  selected = "Crime Categories"),
      
      downloadButton('downloadData','Save Table'),
      
      tags$p(tags$br()),
      tags$p(tags$br()),
      
      tags$h4(tags$u("Definitions")),
      tags$table(style = "width:100%", border = "1", cellspacing = "2",
                 tags$tr(tags$th("TYPE"), tags$th("FBI Codes")),
                 tags$tr(tags$td("Homicides"), tags$td("01A")),
                 tags$tr(tags$td("Severe Violent Crimes"), tags$td("01A, 02, 03, 04A, 04B")),
                 tags$tr(tags$td("Violent Crimes"), tags$td("01A, 02, 03, 04A, 04B, 08A, 08B")),
                 tags$tr(tags$td("Property Crimes"), tags$td("05, 06, 07, 09")),
                 tags$tr(tags$td("Weapons Offense"), tags$td("15")),
                 tags$tr(tags$td("Drugs Crimes"), tags$td("18"))),
      tags$a("FBI Code Definitions", href = "http://gis.chicagopolice.org/clearmap_crime_sums/crime_types.html"),
      tags$p(tags$br()),
      
      tags$h4(tags$u("Other Crime Apps")),
      tags$table(stype = "width:100%",
                 tags$tr(tags$td(tags$a("Crime Rates by Region", href = "https://welgus-apps.shinyapps.io/by_region_year"))),
                 tags$tr(tags$td(tags$a("Monthly Crime Rates", href = "https://welgus-apps.shinyapps.io/by_month"))))),
    
    
    mainPanel( 
      
      h4(title),
      tableOutput("table")))
))
