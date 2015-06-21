# Create new 'ca_pops' that uses linear interpolation to get CA populations between 2000 & 2010. 

setwd("~/portal_apps/by_ca_year")

ca_pops_original <- read.csv("ca_pops_original.csv", stringsAsFactors = FALSE)

for (i in 1:9) {
  
  x <- floor(ca_pops$X2000 * ((10 - i) / 10 ) + ca_pops$X2010 * (i / 10)) 
  ca_pops <- cbind(ca_pops, x)
}

names(ca_pops) <- c("CommunityArea", "ca_num", "pop_2000", "pop_2010", "pop_2001", "pop_2002", 
                    "pop_2003","pop_2004" , "pop_2005", "pop_2006", "pop_2007", "pop_2008", "pop_2009")

write.csv(ca_pops, "ca_pops.csv")
