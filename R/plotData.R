# Description: Creates plots for data
#
# Author: Cameron Roach
rm(list=ls())

source("./R/calcForecasts.R")

# Some plots
smd %>% 
  #filter(Year == 2015) %>% 
  ggplot(aes(x = DryBulb, y = Demand, colour = DoW)) +
  #geom_point(shape = 21, alpha = 0.3) +
  geom_smooth() +
  facet_wrap(~Zone, scales = "free_y") +
  ggtitle("Demand and dry bulb temperature")

smd %>% 
  filter(Year == 2015) %>% 
  ggplot(aes(x = DewPnt, y = Demand, colour = Weekend)) +
  geom_point(shape = 21, alpha = 0.3) +
  geom_smooth() +
  facet_wrap(~Zone) +
  ggtitle("Demand and dew point temperature")

smd %>% 
  filter(Year == 2015) %>% 
  ggplot(aes(x = DewPnt, y = DryBulb, colour = Weekend)) +
  geom_point(shape = 21, alpha = 0.3) +
  geom_smooth() +
  facet_wrap(~Zone) +
  ggtitle("Dry bulb and dew point temperature")

smd %>% 
  filter(Year == 2015) %>% 
  select(Zone, DewPnt, DryBulb, DryDewDiff) %>% 
  gather(TempType, Temp, -c(DryDewDiff, Zone)) %>% 
  ggplot(aes(x = DryDewDiff, y = Temp, colour=TempType)) +
  geom_point(shape = 21, alpha = 0.1) +
  geom_smooth() +
  facet_wrap(~Zone) +
  ggtitle("Dry bulb and dew point difference correlations")

smd %>% 
  filter(Year == 2015) %>% 
  ggplot(aes(x = DryDewDiff, y = Demand, colour = Weekend)) +
  geom_point(shape = 21, alpha = 0.3) +
  geom_smooth() +
  facet_wrap(~Zone, scale = "free_y") +
  ggtitle("Demand and difference betweeen dry bulb and dew point temperature")

smd %>% 
  filter(Year == 2015,
         Zone == load_zones[1]) %>% 
  ggplot(aes(x=ts, y=Demand)) +
  geom_point() +
  geom_line() #TODO: turn into plotly

smd %>% 
  filter(date(Date) == dmy("1/1/2015")) %>% 
  ggplot(aes(x=ts, y=Demand)) +
  geom_point() +
  geom_line() +
  facet_wrap(~Zone)