# Description: Generates forecasts for GEFCom2017-D
#
# Author: Cameron Roach

rm(list=ls())

require(dplyr)
require(tidyr)
require(readxl)
require(lubridate)
require(ggplot2)
require(plotly)
require(caret)
require(myhelpr)


#### Load data ========================

holidays <- read.csv("./data/holidays/holidays.csv") %>% 
  mutate(Date = mdy(Date))

load_zones_ma <- c("SEMASS", "WCMASS", "NEMASSBOST")
load_zones <- c("ME", "NH", "VT", "CT", "RI", load_zones_ma)


smd <- NULL
files <- list.files("./data/smd")
for (iF in files) {
  cat("Reading file", iF, "...\n")
  file_name <- file.path("./data/smd", iF)
  
  for (iS in load_zones) {
    tmp <- read_excel(file_name, sheet = iS) %>% 
      mutate(Zone = iS) %>% 
      select(Date, Hour, Zone, Demand = DEMAND, DryBulb, DewPnt)
    
    smd <- bind_rows(smd, tmp)
  }
}

# Add extra variables
smd <- smd %>% 
  mutate(Date = if_else(Hour == 24, Date + days(1), Date),
         Hour = if_else(Hour == 24, 0, Hour),
         ts = ymd_h(paste(Date, Hour)),
         Year = year(ts),
         Month = month(ts, label = TRUE),
         DoW = wday(ts, label = TRUE),
         Weekend = ifelse(DoW %in% c("Sat", "Sun"), TRUE, FALSE),
         DryDewDiff = DryBulb - DewPnt)



# TODO: Why are there NAs appearing in ts?
#
# TODO: Use holidays data frame to add dummy variable for holiday in smd data 
# frame
#
# TODO: Add day of week variable
#
# TODO: Check if some holidays have a bigger impact on energy than others -
# check boxplot

