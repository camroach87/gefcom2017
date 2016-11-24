# Description: Generates forecasts for GEFCom2017-D
#
# Author: Cameron Roach

rm(list=ls())

require(dplyr)
require(tidyr)
require(readxl)
require(lubridate)
require(ggplot2)
require(caret)

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
  mutate(Hour = if_else(Hour == 24, 0, Hour),
         ts = ymd_h(paste(Date, Hour)),
         Year = year(ts))



# TODO: Why are there NAs appearing in ts?
#
# TODO: Use holidays data frame to add dummy variable for holiday in smd data 
# frame
#
# TODO: Check if some holidays have a bigger impact on energy than others -
# check boxplot


# Some plots
smd %>% 
  filter(Year == 2015) %>% 
  ggplot(aes(x = DryBulb, y = Demand)) +
  geom_point() +
  geom_smooth() +
  facet_wrap(~Zone) +
  ggtitle("Demand and dry bulb temperature")

smd %>% 
  filter(Year == 2015) %>% 
  ggplot(aes(x = DewPnt, y = Demand)) +
  geom_point() +
  geom_smooth() +
  facet_wrap(~Zone) +
  ggtitle("Demand and dew point temperature")

smd %>% 
  filter(Year == 2015) %>% 
  ggplot(aes(x = DewPnt, y = DryBulb)) +
  geom_point() +
  geom_smooth() +
  facet_wrap(~Zone) +
  ggtitle("Dry bulb and dew point temperature")
