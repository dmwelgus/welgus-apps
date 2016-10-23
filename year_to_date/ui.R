shinyUI(fluidPage(
  titlePanel("Crime in Chicago: Year to Date"),
  
  sidebarLayout(
    sidebarPanel(
      helpText("Year-to-date Crime totals"),
      
      selectInput("type", 
                  label = "Select a Crime Category",
                  choices = list("All","Homicides", "Non-fatal Shootings", "Violent Crimes: Def 1", "Violent Crimes: Def 2",
                                 "Property", "Drugs", "Weapons"),
                  selected = "Violent Crimes: Def 1"),
      
      sliderInput("years",
                  label = "Select years",
                  
                  value = c(2010, 2016),
                  min   = 2001,
                  max   = 2016,
                  step  = 1, 
                  sep   = ""),
      
      downloadButton('downloadData','Save Table'),
      
      tags$p(tags$br()),
      tags$p(tags$br()),
      
      tags$h4(tags$u("Definitions")),
      tags$table(style = "width:100%", border = "1", cellspacing = "2",
                 tags$tr(tags$th("TYPE"), tags$th("FBI Codes")),
                 tags$tr(tags$td("Homicides"), tags$td("01A")),
                 tags$tr(tags$td("Violent Crimes: Def 1"), tags$td("01A, 02, 03, 04A, 04B")),
                 tags$tr(tags$td("Violent Crimes: Def 2"), tags$td("01A, 02, 03, 04A, 04B, 08A, 08B")),
                 tags$tr(tags$td("Property"), tags$td("05, 06, 07, 09")),
                 tags$tr(tags$td("Drugs"), tags$td("18"))),
      tags$a("FBI Code Definitions", href = "http://gis.chicagopolice.org/clearmap_crime_sums/crime_types.html"),
      tags$p(tags$br()),
      
      tags$h4(tags$u("Other Crime Apps")),
      tags$table(stype = "width:100%",
                tags$tr(tags$td(tags$a("Crime Rates by Region", href = "https://welgus-apps.shinyapps.io/by_region_year"))),
                tags$tr(tags$td(tags$a("Monthly Crime Rates", href = "https://welgus-apps.shinyapps.io/by_month"))))),
            
    
    mainPanel( 

      tableOutput("table")))
  ))
