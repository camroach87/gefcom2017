#' Get lagged variables
#'
#' Calculates lagged temperature variables for GEFCOM smd data.
#'
#' @param x cleaned data frame. Should be the output from \code{clean_smd_data()} function.
#' @param variables character vector. Vector of variable names that should be lagged.
#' @param lags numeric vector. Vector of lags to calculate. Hourly values.
#'
#' @return A data frame containing lagged variables.
#' @export
#'
#' @author Cameron Roach
get_lagged_vars <- function(x, variables, lags = 1) {
  for (iV in variables) {
    for (iL in lags) {
      lag_name <- paste0(iV, "_lag", iL)
      x[[lag_name]] <- lag(x[[iV]], iL)
    }
  }
  return(x)
}
