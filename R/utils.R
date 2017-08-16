#' Trims models
#'
#' Trims the fat - remove list elements that are large and not needed.
#'
#' Note: use length(serialize(x, NULL)) as a proxy for size. Better than object.size().
#'
#' @param x model
trim_model_fat <- function(x) {
  x[["XGB"]]$trainingData <- NULL
  x[["Vanilla"]]$trainingData <- NULL
  x[["Vanilla"]]$finalModel$model <- NULL
  x[["Vanilla"]]$finalModel$qr$qr <- NULL
  #x[["Vanilla"]]$finalModel$terms <- NULL

  # Delete terms environment because it contains variable dat which is huge.
  # Can't delete terms as it is needed for prediction.
  e <- attr(x[["Vanilla"]]$finalModel$terms, ".Environment") # empty the env associated with local function
  parent.env(e) <- .GlobalEnv # set parent env to .GlobalEnv so serialization doesn’t include contents
  rm(list=ls(envir=e), envir=e) # remove all objects from this environment

  return(x)
}



#' Calculate RMSE
#'
#' @param x data frame with Demand and Prediction columns
#'
#' @return data frame with RMSE values
#' @export
get_rmse <- function(x) {
  x = data_frame(Unreconciled = rmse(x$Demand, x$Prediction),
                 Summing = rmse(x$Demand, x$Prediction_rec),
                 Mean = rmse(x$Demand, x$Prediction_rec_mean),
                 #Median = rmse(x$Demand, x$Prediction_rec_median),
                 `Residual variance` = rmse(x$Demand, x$Prediction_rec_res_var))

  return(x)
}



#' Get quantiles
#'
#' @param x a data frame containing simulated demand.
#' @param prediction_col string for prediction column name.
#'
#' @return A data frame containing quantile forecasts.
#' @export
get_quantiles <- function(x, prediction_col) {
  x <- x %>%
    dplyr::group_by(Zone, ts, Date, Hour) %>%
    dplyr::summarise(Q0 = quantile(!!prediction_col, 0),
                     Q10 = quantile(!!prediction_col, 0.1),
                     Q20 = quantile(!!prediction_col, 0.2),
                     Q30 = quantile(!!prediction_col, 0.3),
                     Q40 = quantile(!!prediction_col, 0.4),
                     Q50 = quantile(!!prediction_col, 0.5),
                     Q60 = quantile(!!prediction_col, 0.6),
                     Q70 = quantile(!!prediction_col, 0.7),
                     Q80 = quantile(!!prediction_col, 0.8),
                     Q90 = quantile(!!prediction_col, 0.9),
                     Q100 = quantile(!!prediction_col, 1)) %>%
    dplyr::ungroup()

  return(x)
}
