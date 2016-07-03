# Create new 'ca_pops' that uses linear interpolation to get CA populations between 2000 & 2010. 

setwd("U:/portal_apps/welgus-apps/by_region_year")

ca_pops_original <- read.csv("ca_pops_original.csv", stringsAsFactors = FALSE)
district_pops_original <- read.csv("district_pops_original.csv", stringsAsFactors = FALSE)
for (i in 1:9) {
  
  x <- floor(ca_pops_original$pop_2000 * ((10 - i) / 10 ) + ca_pops_original$pop_2010 * (i / 10)) 
  y <- floor(district_pops_original$pop_2000 * ((10 - i) / 10) + district_pops_original$pop_2010 * (i / 10))
  ca_pops_original <- cbind(ca_pops_original, x)
  district_pops_original <- cbind(district_pops_original, y)
}

names(ca_pops_original)       <- c("CommunityArea", "ca_num", "pop_2000", "pop_2010", "pop_2001", "pop_2002", 
                                    "pop_2003","pop_2004" , "pop_2005", "pop_2006", "pop_2007", "pop_2008", "pop_2009")
names(district_pops_original) <- c("district", "pop_2000", "pop_2010", "pop_2001", "pop_2002", 
                                   "pop_2003","pop_2004" , "pop_2005", "pop_2006", "pop_2007", "pop_2008", "pop_2009")

# Correct district-pops. Merge 19 and 23, 12 and 13, 2 and 21
district_pops_original[district_pops_original$district == 19, 2:12] <- district_pops_original[district_pops_original$district == 19, 2:12] + 
                                                                       district_pops_original[district_pops_original$district == 23, 2:12]
district_pops_original[district_pops_original$district == 12, 2:12] <- district_pops_original[district_pops_original$district == 12, 2:12] + 
                                                                       district_pops_original[district_pops_original$district == 13, 2:12]
district_pops_original[district_pops_original$district == 2, 2:12]  <- district_pops_original[district_pops_original$district == 2,  2:12] + 
                                                                       district_pops_original[district_pops_original$district == 21, 2:12]

district_pops_original <- dplyr::filter(district_pops_original, !district %in% c(23, 13, 21))



write.csv(ca_pops_original, "ca_pops.csv", row.names = FALSE)
write.csv(district_pops_original, "district_pops.csv", row.names = FALSE)