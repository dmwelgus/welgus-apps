library(jsonlite)
library(curl)


by_region_year <- function(year, type = "All", region = "CA Number") {
  
  
  region_list <- c(`CA Number` = "community_area", District = "district")
  file_list   <- c(`CA Number` = "ca_pops.csv", District = "district_pops.csv")
  name_list   <- c(`CA Number` = "ca_pops", District = "district_pops")
  
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
    
    codes <- crime_codes[type]
    
    url <- sprintf("https://data.cityofchicago.org/resource/6zsd-86xi.json?$select=%s,count(*)&$group=%s&$where=year=%s+AND+fbi_code+in(%s)",
                   region, region, year, codes)
    
  }
  
  
  x <- jsonlite::fromJSON(url)
  x$count <- as.integer(x$count)
  
  if(region == "community_area") {
  
      x <- merge(x, ca_pops, by.x = "community_area", by.y = "ca_num", all.y = TRUE, row.names = FALSE)
      x$count[is.na(x$count)] <- 0
      
      if (year >= 2010) {
    
        y_col <- "pop_2010"
    
      } else {
    
        y_col <- grep(year, names(x), fixed = TRUE, value = TRUE)
    
      }
  
  
      x$rate <- (x$count / x[, y_col]) * 100000
      x <- x[, c("community_area", "CommunityArea", "count", y_col , "rate")]
      
  } else {
    
    x$district <- as.integer(x$district)
    x <- merge(x, district_pops, by = "district", all.y = TRUE, row.names = FALSE)
    x$count[is.na(x$district)] <- 0
    
    if (year >= 2010) {
      
      y_col <- "pop_2010"
      
    } else {
      
      y_col <- grep(year, names(x), fixed = TRUE, value = TRUE)
      
    }
    
    x$rate <- (x$count / x[, y_col]) * 100000
    x <- x[, c("district", "count", y_col, "rate")]
    
  }
  
  x

}


add_arrests <- function(year, type = "All", region = "CA Number") {
  
  region_list <- c(`CA Number` = "community_area", District = "district")
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
    
    codes <- crime_codes[type]
    
    url_a <- sprintf("https://data.cityofchicago.org/resource/6zsd-86xi.json?$select=%s,count(*)&$group=%s&$where=year=%s+AND+fbi_code+in(%s)+AND+arrest=true",
                   region, region, year, codes)
    url_b <- sprintf("https://data.cityofchicago.org/resource/6zsd-86xi.json?$select=%s,count(*)&$group=%s&$where=year=%s+AND+fbi_code+in(%s)+AND+arrest=false",
                     region, region, year, codes)
  }
  
  
  
  x <- jsonlite::fromJSON(url_a)
  y <- jsonlite::fromJSON(url_b)
  
  
  if (region == "community_area") {
    
    names(x) <- c("CA Number", "Arrest Made")
    names(y) <- c("CA Number", "No Arrest Made")
  
    df <- merge(x, y, by = "CA Number", all = TRUE)
    } else {
    
    names(x) <- c("Arrest Made", "District")
    names(y) <- c("No Arrest Made", "District")
    
    x$District <- as.integer(x$District)
    y$District <- as.integer(y$District)
    
    df <- merge(x, y, by = "District", all = TRUE)
  }
  
  
  df[arrest_names][is.na(df[arrest_names])] <- 0
  df[arrest_names] <- lapply(df[arrest_names], as.integer)
  
  df
}

