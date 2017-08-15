#' Fit xgboost and vanilla models
#'
#' @return A list of fitted models.
#' @export
fit_models <- function() {
  trend_start <- as.numeric(ymd(vanilla_train_start_date, tz = "UTC"))/3600

  #### Load data ====
  smd <- load_smd_data(load_zones)
  smd <- clean_smd_data(smd)

  # If a holiday falls on a weekend ignore it. Most holidays are observed on
  # next weekday, but a few earlier years apparently didn't have this.
  smd <- smd %>%
    mutate(Holiday_flag = if_else(DoW %in% c("Sat", "Sun"),
                                  FALSE, Holiday_flag))

  # separate data frames for aggregated zones because may change modelling,
  # e.g., remove average of variables and include all individual ones.
  smd_mass <- smd %>%
    filter(Zone %in% load_zones_ma) %>%
    group_by(Date, Hour, Holiday, Holiday_flag, ts, Period, Year, Month, DoW,
             DoY, Weekend) %>%
    summarise(Demand = sum(Demand),
              DryBulb = mean(DryBulb),
              DewPnt = mean(DewPnt),
              DryDewDiff = mean(DryDewDiff)) %>%
    ungroup() %>%
    mutate(Zone = "MASS")

  smd_total <- smd %>%
    group_by(Date, Hour, Holiday, Holiday_flag, ts, Period, Year, Month, DoW,
             DoY, Weekend) %>%
    summarise(Demand = sum(Demand),
              DryBulb = mean(DryBulb),
              DewPnt = mean(DewPnt),
              DryDewDiff = mean(DryDewDiff)) %>%
    ungroup() %>%
    mutate(Zone = "TOTAL")

  smd <- bind_rows(smd, smd_mass, smd_total)
  rm(list = c("smd_mass", "smd_total"))

  # create training data.frames for all models
  xgb_train_df <- smd %>%
    group_by(Zone) %>%
    do(get_lagged_vars(., c("DryBulb", "DewPnt"), lags = 1:72)) %>%
    ungroup() %>%
    filter(Date >= xgb_train_start_date) %>%
    mutate(Trend = as.numeric(ts)/3600,
           Trend = Trend - trend_start + 1)

  # split into training and test dataframes.
  xgb_test_df <- filter(xgb_train_df, Date > xgb_train_end_date)
  xgb_train_df <- filter(xgb_train_df, Date <= xgb_train_end_date)

  vanilla_train_df <- smd %>%
    filter(Date >= vanilla_train_start_date,
           Date <= vanilla_train_end_date) %>%
    mutate(Trend = as.numeric(ts)/3600,
           Trend = Trend - trend_start + 1)


  #### fit zones ====
  xgb_ctrl <- trainControl(method = "repeatedcv",
                           number = 5,
                           allowParallel = TRUE,
                           returnData = FALSE,
                           trim = TRUE,
                           returnResamp = "none",
                           savePredictions = "none")

  #L1 and L2 regularization - no elastic net
  xgb_grid_linear <- data.frame(nrounds = 200,
                                alpha = c(rep(0, 7), exp(3:8)),
                                lambda = c(0, exp(3:8), rep(0, 6)),
                                eta = 0.1)


  model_list <- NULL

  for (iZ in all_zones) {
    cat("Fitting zone", iZ, "...\n")

    # Boosted models
    model_list[[iZ]][["XGB"]] <- xgb_train_df %>%
      filter(Zone == iZ) %>%
      select(Demand, Hour, DoY, DoW, Holiday_flag, Trend,
             starts_with("DryBulb"), starts_with("DewPnt")) %>%
      train(Demand ~ . ,
            data = .,
            method="xgbLinear",
            trControl = xgb_ctrl,
            tuneGrid = xgb_grid_linear,
            nthread = 1)

    # Tao's vanilla model
    model_list[[iZ]][["Vanilla"]] <- vanilla_train_df %>%
      filter(Zone == iZ) %>%
      train(Demand ~ DoW*Period +
              poly(DryBulb, 3, raw = TRUE)*Month +
              poly(DryBulb, 3, raw = TRUE)*Period +
              Trend,
            data = .,
            method = "lm",
            trControl = xgb_ctrl)

    model_list[[iZ]] <- trim_model_fat(model_list[[iZ]])
  }


  return(model_list)
}
