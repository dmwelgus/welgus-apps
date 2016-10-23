## Underlying function for 'year-to-date' app

year_to_date <- function(years, type, stop_date) {
  

  base_year <- substr(stop_date, 1, 4)
  
  stop_date <- quotes(stop_date)
  
  if (type == "Homicides")               (codes <- "'01A'")
  if (type == "Violent Crimes: Def 1")   (codes <- "'01A','02','03','04A','04B'")
  if (type == "Violent Crimes: Def 2")   (codes <- "'01A','02','03','04A','04B','08A','08B'")
  if (type == "Drugs")                   (codes <- "'18'")
  if (type == "Property")                (codes <- "'05','06','07','09'")

  
  
 
  table_a <- c()
  table_b <- c()

  for (i in 1:length(years)) {
    
    if (i > 1) (base_year <- substr(stop_date, 2, 5))
    stop_date <- gsub(base_year, years[i], stop_date)
    
        if (type == "All") {
      
            url <- "https://data.cityofchicago.org/resource/6zsd-86xi.json?$select=fbi_code,count(*)&$group=fbi_code&$where=date+between'%s-01-01T00:00:00'+and+%s"
            url <- sprintf(url, years[i], stop_date)
      
          } else if (type == "Non-fatal Shootings"){
            
            shooting_descriptions <- read.csv("shooting_descriptions.csv")
            shooting_descriptions <- shooting_descriptions$x
            
            shooting_descriptions <- paste("'", shooting_descriptions, "'", sep = "")
            shooting_descriptions <- paste(shooting_descriptions, collapse = ",")
            shooting_descriptions <- gsub(" ", "%20", shooting_descriptions)
            
            url <- "https://data.cityofchicago.org/resource/6zsd-86xi.json?$select=fbi_code,count(*)&$group=fbi_code&$where=fbi_code='04B'+and+description+in(%s)+and+date+between'%s-01-01T00:00:00'+and+%s"
            url <- sprintf(url, shooting_descriptions, years[i], stop_date)
          
          } else {
            
            url <- "https://data.cityofchicago.org/resource/6zsd-86xi.json?$select=fbi_code,count(*)&$group=fbi_code&$where=fbi_code+in(%s)+and+date+between'%s-01-01T00:00:00'+and+%s"
            url <- sprintf(url, codes, years[i], stop_date)
            
          }
   
    url_a <-  paste(url, "+AND+arrest=true", sep = "")
    url_b <-  paste(url, "+AND+arrest=false", sep = "")
    
    tab_a <- fromJSON(url_a)
    tab_b <- fromJSON(url_b)
    
    table_a[i] <- sum(as.numeric(tab_a$count))
    table_b[i] <- sum(as.numeric(tab_b$count))
  }
  

  table_a <- append(table_a, substr(stop_date, 7, 11))
  table_a <- as.data.frame(t(table_a), stringsAsFactors = FALSE)
  names(table_a) <- append(years, "Stop Date")
  
  table_b <- append(table_b, substr(stop_date, 7, 11))
  table_b <- as.data.frame(t(table_b), stringsAsFactors = FALSE)
  names(table_b) <- append(years, "Stop Date")
  
  final_table <- rbind(table_a, table_b)
  final_table[, as.character(years)] <- lapply(final_table[, as.character(years)], as.numeric)
  
  sums <- apply(final_table[, as.character(years)], 2, sum)
  
  final_table <- rbind(final_table, rep(NA, 3))
  final_table[["Stop Date"]][3] <- final_table[["Stop Date"]][1]
  final_table[3, 1:(ncol(final_table) - 1)] <- sums
  
  rownames(final_table) <- c("Arrest Made", "No Arrest Made", "All")
  final_table
}








