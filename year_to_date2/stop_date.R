
get_stopDate <- function() {
  
  # Quick query to get most recent date in crime table
  ref_time <- Sys.time() - 20*60*60*24
  ref_time <- gsub(" ", "T", ref_time)
  ref_time <- paste("'",ref_time,"'", sep = "")
  url <- "https://data.cityofchicago.org/resource/6zsd-86xi.json?$select=fbi_code,max(date)&$group=fbi_code&$where=date>=%s"
  url <- sprintf(url, ref_time)
  x <- fromJSON(url)
  
  stop_date <- max(x$max_date)
  
  stop_date
}

get_years <- function(x) (x[1]:x[2])
quotes <- function(x) paste("'",x,"'",sep ="")