# Thoughts for new year_to_date app. 

# 1. Start by getting a table of year-to-date totals by FBI.Code going back to 2001. 
# 2. Then let user choose between raw fbi codes and crime types. 
library(jsonlite)

year_to_date2 <- function() {
  
  stop_date <- get_stopDate()
  yr        <- as.numeric(substr(stop_date, 1, 4))
  stop_date <- quotes(stop_date)
  df_list <- list()
  for (i in 2001:yr) {
    
    stop_date2 <- gsub(yr, i, stop_date)
    url <- "https://data.cityofchicago.org/resource/6zsd-86xi.json?$select=fbi_code,count(*)&$group=fbi_code&$where=date+between'%s-01-01T00:00:00'+and+%s"
    url <- sprintf(url, i, stop_date2)
    
    tab <- fromJSON(url)
    tab <- tab[order(tab[, "fbi_code"]), ]
    df  <- data.frame(t(tab[, "count"]))
    names(df) <- tab[, "fbi_code"]
    df_list[[i - 2000]] <- df
    
  }
  
  df <- dplyr::bind_rows(df_list)
  df[] <- lapply(df, as.integer)
  rownames(df) <- 2001:2016
  
  df$vc       <- apply(df[, c("01A", "02", "03", "04A", "04B")], 1, sum)
  df$vc2      <- apply(df[, c("01A", "02", "03", "04A", "04B", "08A", "08B")], 1, sum)
  df$prop     <- apply(df[, c("05", "06", "07", "09")], 1, sum)
  df$drug     <- df[, c("18")]
  df$homicide <- df[, c("01A")]
  df$weapons  <- df[, c("15")]
  
  df2 <- df[, c("homicide", "vc", "vc2", "weapons", "prop", "drug")]
  df <- df[, setdiff(names(df), names(df2))]
  df <- df[, names(df) != "01B"]
  
  names(df2) <- c("Homicides", "Severe Violent Crimes", "Violent Crimes", "Weapons Offenses", "Property Crimes", "Drug Crimes")
  
  list(df2, df)
  
  
}
