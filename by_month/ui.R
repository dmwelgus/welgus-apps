# ui.R

shinyUI(fluidPage(
  titlePanel("Crime in Chicago: By Month"),
  
  sidebarLayout(
    sidebarPanel(
      helpText("Get monthly counts for different crime categories"),
      
      selectInput("var", 
                  label = "Select a Crime Category",
                  choices = list("All","Homicides", "Violent Crimes: Def 1", "Violent Crimes: Def 2",
                                 "Property", "Drugs"),
                  selected = "Homicides"),
      
      sliderInput("years",
                  label = "Select years",
                  
                  value = c(2010, 2016),
                  min   = 2001,
                  max   = 2016,
                  step  = 1, 
                  sep   = ""),
      
      tags$p(tags$br()),
      tags$p(tags$br()),
      
      tags$h4(tags$u("Definitions")),
      tags$table(style = "width:100%", border = "1", cellspacing = "2",
                 tags$tr(tags$th("TYPE"), tags$th("FBI Codes")),
                 tags$tr(tags$td("homicides"), tags$td("01A")),
                 tags$tr(tags$td("violent crimes: def 1"), tags$td("01A, 02, 03, 04A, 04B")),
                 tags$tr(tags$td("violent crimes: def 2"), tags$td("01A, 02, 03, 04A, 04B, 08A, 08B")),
                 tags$tr(tags$td("property"), tags$td("05, 06, 07, 09")),
                 tags$tr(tags$td("drugs"), tags$td("18"))),
      tags$a("FBI Code Definitions", href = "http://gis.chicagopolice.org/clearmap_crime_sums/crime_types.html"),
      tags$p(tags$br()),
      
      tags$h4(tags$u("Other Crime Apps")),
      tags$table(stype = "width:100%",
                 tags$tr(tags$td(tags$a("Crime Rates by Community Area", href = "https://welgus-apps.shinyapps.io/by_ca_year"))),
                 tags$tr(tags$td(tags$a("Year-to-Date Crime Totals", href = "https://welgus-apps.shinyapps.io/year_to_date"))))),
    
    
      mainPanel( 
          plotOutput("plot"),
          tableOutput("table")))
  ))
