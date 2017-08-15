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
#'
#' @examples
get_rmse <- function(x) {
  x = data_frame(Unreconciled = rmse(x$Demand, x$Prediction),
                 Summing = rmse(x$Demand, x$Prediction_rec),
                 Mean = rmse(x$Demand, x$Prediction_rec_mean),
                 #Median = rmse(x$Demand, x$Prediction_rec_median),
                 `Residual variance` = rmse(x$Demand, x$Prediction_rec_res_var))

  return(x)
}
