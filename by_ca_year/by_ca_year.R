library(jsonlite)
library(curl)

ca_pops <- read.csv("ca_pops.csv", stringsAsFactors = FALSE)

by_ca_year <- function(year, type = "all", order_by = "rate") {
  
  
  if (type == "all") {
    
    url <- sprintf("https://data.cityofchicago.org/resource/6zsd-86xi.json?$select=community_area,count(*)&$group=community_area&$where=year=%s", year)
    
  } else {
    
    types <- c("homicides", "violent crimes: def 1", "violent crimes: def 2", "drugs", "property")
    
    code_list <- c("'01A'", "'01A','02','03','04A','04B'", "'01A','02','03','04A','04B','08A','08B'", 
                   "'18'", "'05','06','07','09'")
    
    codes <- code_list[types == type]
    
    url <- sprintf("https://data.cityofchicago.org/resource/6zsd-86xi.json?$select=community_area,count(*)&$group=community_area&$where=year=%s+AND+fbi_code+in(%s)",
                   year, codes)
    
  }
  
  
  
  x <- fromJSON(url)
  x$count <- as.integer(x$count)
  
  x <- merge(x, ca_pops, by.x = "community_area", by.y = "ca_num", all.x = TRUE, row.names = FALSE)
  
  if (year >= 2010) {
    
    y_col <- 5
    
  } else {
    
    y_col <- grep(year, names(x), fixed = TRUE)
    
  }
  
  
  x$rate <- (x$count / x[, y_col]) * 100000
  
  if (order_by == "count") {
    
    x <- x[order(-x$count), ]
    
  } else {
    
    x <- x[order(-x$rate), ]
  }
  
  x <- cbind(1:nrow(x), x)
  
  x <- x[, c(1, 2, 3, 4, y_col + 1, 16)]
  
  names(x) <- c(" ","CA", "Count", "Community Area", "Pop", "Rate (per 100K)")
  
  x
}
