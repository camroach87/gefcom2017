#' Fit xgboost and vanilla models
#'
#' @param train_df xgb train data frame.
#' @param zones vector of zones to fit models for.
#'
#' @return A list of fitted models.
#' @export
fit_models <- function(train_df, zones) {

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

  for (iZ in zones) {
    cat("Fitting zone", iZ, "...\n")

    # Boosted models
    model_list[[iZ]][["XGB"]] <- train_df %>%
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
    model_list[[iZ]][["Vanilla"]] <- train_df %>%
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
