# Put some scalars and table names in global.R

ca_names <- c("CA Number", "Community Area", "Total", "Population", "Rate per 100K")
district_names <- c("District", "Total", "Population", "Rate per 100K")
arrest_names <- c("Arrest Made", "No Arrest Made")

crime_types <- c("Homicides", "Violent Crimes: Def 1", "Violent Crimes: Def 2", "Drugs", "Property", "Weapons")
crime_codes <- c("'01A'", "'01A','02','03','04A','04B'", "'01A','02','03','04A','04B','08A','08B'", 
               "'18'", "'05','06','07','09'", "'15'")
names(crime_codes) <- crime_types

source("by_region_year.R")
source("plot_fun.R")
