shinyUI(fluidPage(
  titlePanel("Crime in Chicago: by Community Area"),
  
  sidebarLayout(
    sidebarPanel(
      helpText("Annual counts and rates for different crime categories: by 
               Community Area"),
      
      selectInput("type", 
                  label = "Select a Crime Category",
                  choices = list("all","homicides", "violent crimes: def 1", "violent crimes: def 2",
                                 "property", "drugs"),
                  selected = "violent crimes: def 1"),
      
      selectInput("year",
                  label = "Select year",
                  choices = list("2001", "2002", "2003", "2004", "2005", "2006", "2007",
                                 "2008", "2009", "2010", "2011", "2012", "2013", "2014", "2015"),
                  selected = "2014"),
      
      selectInput("order_by",
                  label = "Order By Rate or Count",
                  choices = list("rate", "count"),
                  selected = "rate"),
      
      
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
                 tags$tr(tags$td(tags$a("Year-to-Date Crime Totals", href = "https://welgus-apps.shinyapps.io/year_to_date"))),
                 tags$tr(tags$td(tags$a("Monthly Crime Rates", href = "https://welgus-apps.shinyapps.io/by_month"))))),
    mainPanel( 
    
      plotOutput("plot"),
      
      h4("Crime rates by Community Area"),
      tableOutput("table")))
))
