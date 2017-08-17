#' Load SMD data
#'
#' Cleans smd data for GEFCOM-D. Removes DST hours and adjusts DoY values in
#' leap years.
#'
#' The DoY adjustment for leap years sets 29th Feb to have the same DoY as 28th
#' Feb (59) and subtracts 1 from DoY for all days after 29th Feb. This results
#' in both leap years and non-leap years having DoY values of 1,2,...,365.
#'
#' @param smd smd data frame containing columns DoY, Year and ts.
#'
#' @return smd data_frame containing raw data and calendar variables
#' @export
#'
#' @author Cameron Roach
clean_smd_data <- function(smd) {
  root_dir <- system.file("extdata", package = "gefcom2017")

  dst_times <- read.csv(file.path(root_dir, "dst_ts.csv")) %>%
    mutate(dst_start = ymd_hms(dst_start),
           dst_end = ymd_hms(dst_end))

  # Remove DST hours
  smd <- smd %>%
    filter(!(ts %in% dst_times$dst_start)) %>%
    filter(!(ts %in% dst_times$dst_end))

  # Shift DoY for leap years. Feb 29 has DoY == 60
  smd <- smd %>%
    mutate(DoY = if_else(leap_year(Year) & DoY >= 60,
                         DoY - 1, DoY))

  return(smd)
}


#' Get train and test data frames
#'
#' @param train_start_date start date for model training data.
#' @param train_end_date end date for model training data.
#' @param test_start_date start date for model testing data.
#' @param test_end_date end date for model testing data.
#' @param trend_start numeric value indicating trend start.
#'
#' @return List containing train and test data frames.
#' @export
get_train_test_df <- function(train_start_date, train_end_date,
                              test_start_date, test_end_date, trend_start) {
  load_zones_ma <- c("SEMASS", "WCMASS", "NEMASSBOST")
  load_zones <- c("ME", "NH", "VT", "CT", "RI", load_zones_ma)
  
  #### Load data ====
  data <- load_smd_data(load_zones)
  data <- clean_smd_data(data)
  
  # If a holiday falls on a weekend ignore it. Most holidays are observed on
  # next weekday, but a few earlier years apparently didn't have this.
  data <- data %>%
    mutate(Holiday_flag = if_else(DoW %in% c("Sat", "Sun"),
                                  FALSE, Holiday_flag))
  
  # separate data frames for aggregated zones because may change modelling,
  # e.g., remove average of variables and include all individual ones.
  data_mass <- data %>%
    filter(Zone %in% load_zones_ma) %>%
    group_by(Date, Hour, Holiday, Holiday_flag, ts, Period, Year, Month, DoW,
             DoY, Weekend) %>%
    summarise(Demand = sum(Demand),
              DryBulb = mean(DryBulb),
              DewPnt = mean(DewPnt),
              DryDewDiff = mean(DryDewDiff)) %>%
    ungroup() %>%
    mutate(Zone = "MASS")
  
  data_total <- data %>%
    group_by(Date, Hour, Holiday, Holiday_flag, ts, Period, Year, Month, DoW,
             DoY, Weekend) %>%
    summarise(Demand = sum(Demand),
              DryBulb = mean(DryBulb),
              DewPnt = mean(DewPnt),
              DryDewDiff = mean(DryDewDiff)) %>%
    ungroup() %>%
    mutate(Zone = "TOTAL")
  
  data <- bind_rows(data, data_mass, data_total)
  rm(list = c("data_mass", "data_total"))
  
  # create training data.frames for all models
  train_df <- data %>%
    group_by(Zone) %>%
    do(get_lagged_vars(., c("DryBulb", "DewPnt"), lags = 1:72)) %>%
    ungroup() %>%
    filter(Date >= train_start_date) %>%
    mutate(Trend = as.numeric(ts)/3600,
           Trend = Trend - trend_start + 1)
  
  # split into training and test data frames.
  test_df <- filter(train_df, Date >= test_start_date, Date <= test_end_date)
  train_df <- filter(train_df, Date <= train_end_date)
  
  return(list(train_df = train_df,
              test_df = test_df))
}
