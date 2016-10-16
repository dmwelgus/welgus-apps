library(jsonlite)
library(curl)


by_region_year <- function(year, type = "All", order_by = "Rate", region = "CA") {
  
  
  region_list <- c(CA = "community_area", District = "district")
  file_list   <- c(CA = "ca_pops.csv", District = "district_pops.csv")
  name_list   <- c(CA = "ca_pops", District = "district_pops")
  
  assign(name_list[region], read.csv(file_list[region], stringsAsFactors = FALSE))
  region <- region_list[region]
  
  if (type == "All") {
    
    url <- sprintf("https://data.cityofchicago.org/resource/6zsd-86xi.json?$select=%s,count(*)&$group=%s&$where=year=%s", region, region, year)
    
  } else if (type == "Non-fatal Shootings"){
    
    shooting_descriptions <- read.csv("shooting_descriptions.csv")
    shooting_descriptions <- shooting_descriptions$x
    
    shooting_descriptions <- paste("'", shooting_descriptions, "'", sep = "")
    shooting_descriptions <- paste(shooting_descriptions, collapse = ",")
    shooting_descriptions <- gsub(" ", "%20", shooting_descriptions)
    
    url <- sprintf("https://data.cityofchicago.org/resource/6zsd-86xi.json?$select=%s,count(*)&$group=%s&$where=year=%s+AND+fbi_code='04B'+AND+description+in(%s)", 
                   region, region, year, shooting_descriptions)
    
  } else {
    
    types <- c("Homicides", "Violent Crimes: Def 1", "Violent Crimes: Def 2", "Drugs", "Property", "Weapons")
    
    code_list <- c("'01A'", "'01A','02','03','04A','04B'", "'01A','02','03','04A','04B','08A','08B'", 
                   "'18'", "'05','06','07','09'", "'15'")
    
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
  
      if (order_by == "Count") {
    
          x <- x[order(-x$count), ]
    
      } else {
    
          x <- x[order(-x$rate), ]
      }
  
      
  
      x <- x[, c(1, 2, 3, y_col , 15)]
  
      names(x) <- c("CA", "Count", "Community Area", "Population", "Rate per 100K")
  
  } else {
    
    x$district <- as.numeric(x$district)
    x <- merge(x, district_pops, by = "district", all.x = TRUE, row.names = FALSE)
    
    if (year >= 2010) {
      
      y_col <- which(names(x) == "pop_2010")
      
    } else {
      
      y_col <- grep(year, names(x), fixed = TRUE)
      
    }
    
    x$rate <- (x$count / x[, y_col]) * 100000
    
      if (order_by == "count") {
      
        x <- x[order(-x$count), ]
      
      } else {
      
        x <- x[order(-x$rate), ]
      }
    
    
    x <- x[, c(1, 2, y_col, 14)]
    
    names(x) <- c("District", "Count", "Population", "Rate per 100K")
    
  }
  
  x

}


add_arrests <- function(year, type = "All", region = "CA") {
  
  region_list <- c(CA = "community_area", District = "district")
  region <- region_list[region]
  
  if (type == "All") {
    
    url_a <- sprintf("https://data.cityofchicago.org/resource/6zsd-86xi.json?$select=%s,count(*)&$group=%s&$where=year=%s+AND+arrest=true", region, region, year)
    url_b <- sprintf("https://data.cityofchicago.org/resource/6zsd-86xi.json?$select=%s,count(*)&$group=%s&$where=year=%s+AND+arrest=false", region, region, year)
  } else if (type == "Non-fatal Shootings"){
    
    shooting_descriptions <- read.csv("shooting_descriptions.csv")
    shooting_descriptions <- shooting_descriptions$x
    
    shooting_descriptions <- paste("'", shooting_descriptions, "'", sep = "")
    shooting_descriptions <- paste(shooting_descriptions, collapse = ",")
    shooting_descriptions <- gsub(" ", "%20", shooting_descriptions)
    
    url_a <- sprintf("https://data.cityofchicago.org/resource/6zsd-86xi.json?$select=%s,count(*)&$group=%s&$where=year=%s+AND+fbi_code='04B'+AND+description+in(%s)+AND+arrest=true", 
                   region, region, year, shooting_descriptions)
    url_b <- sprintf("https://data.cityofchicago.org/resource/6zsd-86xi.json?$select=%s,count(*)&$group=%s&$where=year=%s+AND+fbi_code='04B'+AND+description+in(%s)+AND+arrest=false", 
                     region, region, year, shooting_descriptions)
    
    
  } else {
    
    types <- c("Homicides", "Violent Crimes: Def 1", "Violent Crimes: Def 2", "Drugs", "Property", "Weapons")
    
    code_list <- c("'01A'", "'01A','02','03','04A','04B'", "'01A','02','03','04A','04B','08A','08B'", 
                   "'18'", "'05','06','07','09'", "'15'")
    
    codes <- code_list[types == type]
    
    url_a <- sprintf("https://data.cityofchicago.org/resource/6zsd-86xi.json?$select=%s,count(*)&$group=%s&$where=year=%s+AND+fbi_code+in(%s)+AND+arrest=true",
                   region, region, year, codes)
    url_b <- sprintf("https://data.cityofchicago.org/resource/6zsd-86xi.json?$select=%s,count(*)&$group=%s&$where=year=%s+AND+fbi_code+in(%s)+AND+arrest=false",
                     region, region, year, codes)
  }
  
  
  
  x <- jsonlite::fromJSON(url_a)
  y <- jsonlite::fromJSON(url_b)
  
  
  if (region == "community_area") {
    
    names(x) <- c("CA", "Arrest Made")
    names(y) <- c("CA", "No Arrest Made")
  
    df <- merge(x, y, by = "CA", all = TRUE)
    } else {
    
    names(x) <- c("Arrest Made", "District")
    names(y) <- c("No Arrest Made", "District")
    
    x$District <- as.integer(x$District)
    y$District <- as.integer(y$District)
    
    df <- merge(x, y, by = "District", all = TRUE)
  }
  

  df[["Arrest Made"]][is.na(df[["Arrest Made"]])] <- 0
  df[["No Arrest Made"]][is.na(df[["No Arrest Made"]])] <- 0
  
  df[["Arrest Made"]]    <- as.integer(df[["Arrest Made"]])
  df[["No Arrest Made"]] <- as.integer(df[["No Arrest Made"]])
  
  df
}

