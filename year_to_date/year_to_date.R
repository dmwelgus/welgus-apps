## Underlying functions for 'year-to-date' app

library(jsonlite)
library(curl)


year_to_date <- function(years, type) {
  
  # Quick query to get most recent date in crime table
  url <- "https://data.cityofchicago.org/resource/6zsd-86xi.json?$select=fbi_code,max(date)&$group=fbi_code&$where=year>=2015"
  x <- fromJSON(url)
  
  stop_date <- max(x$max_date)
  base_year <- substr(stop_date, 1, 4)
  
  quotes <- function(x) paste("'",x,"'",sep ="")
  stop_date <- quotes(stop_date)
  
  if (type == "homicides")               (codes <- "'01A'")
  if (type == "violent crimes: def 1")   (codes <- "'01A','02','03','04A','04B'")
  if (type == "violent crimes: def 2")   (codes <- "'01A','02','03','04A','04B','08A','08B'")
  if (type == "drugs")                   (codes <- "'18'")
  if (type == "property")                (codes <- "'05','06','07','09'")

  
  
  table <- c()
  
  for (i in 1:length(years)) {
    
    if (i > 1) (base_year <- substr(stop_date, 2, 5))
    stop_date <- gsub(base_year, years[i], stop_date)
    
        if (type == "all") {
      
            url <- "https://data.cityofchicago.org/resource/6zsd-86xi.json?$select=fbi_code,count(*)&$group=fbi_code&$where=date+between'%s-01-01T00:00:00'+and+%s"
            url <- sprintf(url, years[i], stop_date)
      
          } else {
      
            url <- "https://data.cityofchicago.org/resource/6zsd-86xi.json?$select=fbi_code,count(*)&$group=fbi_code&$where=fbi_code+in(%s)+and+date+between'%s-01-01T00:00:00'+and+%s"
            url <- sprintf(url, codes, years[i], stop_date)
          }
   
  
    tab <- fromJSON(url)
    
    table[i] <- sum(as.numeric(tab$count))
  
  }
  
  table <- append(table, substr(stop_date, 7, 11))
  table <- as.data.frame(t(table))
  names(table) <- append(years, "stop_date")
  
  table
}








