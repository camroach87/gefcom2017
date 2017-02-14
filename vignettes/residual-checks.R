p_date <- dmy("1/3/2016")
resid_df %>%
  filter(Zone == "TOTAL",
         DoW %in% c("Mon", "Tues", "Wed", "Thurs", "Fri")) %>%
  filter(between(Date, p_date, p_date + days(7))) %>%
  select(ts, Residual) %>%
  ggplot(aes(x = ts, y = Residual)) +
  geom_line()


resid_df %>%
  filter(Zone == "TOTAL") %>%
  #mutate(Sim_demand_test = Prediction + lag(Residual, 168)) %>%
  mutate(Sim_demand_test = Prediction + lag(Residual, 168)) %>%
  filter(between(Date, p_date, p_date + days(7))) %>%
  select(ts, Demand, Sim_demand_test) %>%
  gather(var, val, -ts) %>%
  ggplot(aes(x = ts, y = val, colour = var)) +
  geom_line()


resid_df %>%
  filter(Zone == "TOTAL") %>%
  #mutate(Sim_demand_test = Prediction + lag(Residual, 168)) %>%
  mutate(Sim_demand_test = Prediction + lag(Residual, 336)) %>%
  group_by(DoW, Hour) %>%
  summarise(Demand = mean(Demand, na.rm = TRUE),
            Sim_demand_test = mean(Sim_demand_test, na.rm = TRUE)) %>%
  select(DoW, Hour, Demand, Sim_demand_test) %>%
  gather(var, val, -c(DoW, Hour)) %>%
  ggplot(aes(x = Hour, y = val, colour = var)) +
  facet_wrap(~DoW) +
  geom_line()



resid_df %>%
  filter(Zone == "TOTAL") %>%
  ggplot(aes(x = factor(Hour), y = Residual)) +
  geom_boxplot() +
  facet_wrap(~DoW)
resid_df %>%
  filter(Zone == "TOTAL") %>%
  ggplot(aes(x = Hour, y = Residual)) +
  geom_smooth() +
  facet_wrap(~DoW)


resid_df %>%
  filter(Zone == "TOTAL") %>%
  ggplot(aes(x = Hour, y = Residual)) +
  geom_smooth() +
  facet_grid(DoW~Holiday_flag)



resid_df %>%
mutate(Season = season(ts, shoulder = TRUE)) %>%
filter(Zone == "TOTAL") %>%
ggplot(aes(x = Hour, y = Residual)) +
geom_smooth() +
facet_grid(Season~DoW)

resid_df %>%
  mutate(WorkingDay = ifelse(DoW %in% c("Sat", "Sun") | Holiday_flag == TRUE,
                             "Working day", "Non-working day"),
         Season = season(ts, shoulder = TRUE)) %>%
  filter(Zone == "TOTAL") %>%
  ggplot(aes(x = Hour, y = Residual)) +
  geom_smooth() +
  facet_grid(Season~WorkingDay)

weekday_residuals <- resid_df %>%
  filter(Zone == "ME",
         DoW %in% c("Mon", "Tues", "Wed", "Thurs", "Fri")) %>%
  .$Residual
acf(weekday_residuals)

weekend_residuals <- resid_df %>%
  filter(Zone == "ME",
         DoW %in% c("Sat", "Sun")) %>%
  .$Residual
acf(weekend_residuals, lag.max = 100)
