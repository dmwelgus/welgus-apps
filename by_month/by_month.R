
library(jsonlite)
library(curl)

by_month <- function(years, type = "all") {
  
  if (type == "homicides")              (codes <- "'01A'")
  if (type == "violent crimes: def 1")  (codes <- "'01A','02','03','04A','04B'")
  if (type == "violent crimes: def 2")  (codes <- "'01A','02','03','04A','04B','08A','08B'")
  if (type == "drugs")                  (codes <- "'18'")
  if (type == "property")               (codes <- "'05','06','07','09'")
  
  
  years <- paste(years, collapse = ",")
  

  if (type == "all") {
    
      url <- sprintf("https://data.cityofchicago.org/resource/6zsd-86xi.json?$select=date_trunc_ym(date)+AS+month,count(*)+AS+total&$group=month&$where=year+in(%s)",
                     years)
  
    } else {
    
      url <- sprintf("https://data.cityofchicago.org/resource/6zsd-86xi.json?$select=date_trunc_ym(date)+AS+month,count(*)+AS+total&$group=month&$where=year+in(%s)+and+fbi_code+in(%s)",
                     years, codes)
            
  }
  
  
  x <- fromJSON(url)
  x <- x[order(x$month), ]
  
  x$total <- as.integer(x$total)
  
  x
}