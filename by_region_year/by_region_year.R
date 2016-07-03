library(jsonlite)
library(curl)


by_region_year <- function(year, type = "All", order_by = "rate", region = "CA") {
  
  
  region_list <- c(CA = "community_area", District = "district")
  file_list   <- c(CA = "ca_pops.csv", District = "district_pops.csv")
  name_list   <- c(CA = "ca_pops", District = "district_pops")
  
  assign(name_list[region], read.csv(file_list[region], stringsAsFactors = FALSE))
  region <- region_list[region]
  
  if (type == "All") {
    
    url <- sprintf("https://data.cityofchicago.org/resource/6zsd-86xi.json?$select=%s,count(*)&$group=%s&$where=year=%s", region, region, year)
    
  } else {
    
    types <- c("Homicides", "Violent Crimes: Def 1", "Violent Crimes: Def 2", "Drugs", "Property")
    
    code_list <- c("'01A'", "'01A','02','03','04A','04B'", "'01A','02','03','04A','04B','08A','08B'", 
                   "'18'", "'05','06','07','09'")
    
    codes <- code_list[types == type]
    
    url <- sprintf("https://data.cityofchicago.org/resource/6zsd-86xi.json?$select=%s,count(*)&$group=%s&$where=year=%s+AND+fbi_code+in(%s)",
                   region, region, year, codes)
    
  }
  
  
  
  x <- jsonlite::fromJSON(url)
  x$count <- as.integer(x$count)
  
  if(region == "community_area") {
  
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
  
  } else {
    
    x$district <- as.numeric(x$district)
    x <- merge(x, district_pops, by = "district", all.x = TRUE, row.names = FALSE)
    
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
    
    x <- x[, c(1, 2, 3, y_col + 1, 15)]
    
    names(x) <- c(" ","District", "Count", "Pop", "Rate (per 100K)")
    
  }
  
  x

}
