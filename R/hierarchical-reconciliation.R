#' Hierarchical reconciliation by OLS
#'
#' @param x vector of time-series forecasts for a given time t.
#' @param S summing matrix.
#'
#' @export
h_rec <- function(x, S) {
  S %*% solve(t(S) %*% S) %*% t(S) %*% x
}

#' Hierarchical reconciliation by WLS
#'
#' @param x vector of time-series forecasts for a given time t.
#' @param S summing matrix.
#' @param W weight matrix.
#'
#' @export
h_rec_w <- function(x, S, W) {
  S %*% solve(t(S) %*% W %*% S) %*% t(S) %*% W %*% x
}

#' Format reconciled dataframes
#'
#' This function is used after reconciliation to convert data to the correct format.
#' Used by hts_reconciliation function.
#'
#' @param hts_raw the raw time-series data.
#' @param hts_rec the reconciled data frame.
#' @param variable_cols variable column. Columns that provide a unique identifier for each time-series forecast. Inherited from hts_reconciliation().
#' @param pred_col_name the name assigned to the prediction column. Defaults to "Prediction".
#'
#' @export
format_rec_df <- function(hts_raw, hts_rec, variable_cols, pred_col_name = "Prediction") {
  hts_rec <- bind_cols(hts_raw[, variable_cols], as.data.frame(hts_rec)) %>%
    gather(Zone, Prediction_rec, -one_of(variable_cols))
  names(hts_rec) <- c(variable_cols, "Zone", pred_col_name)
  return(hts_rec)
}

#' Hierarchical time-series reconciliation
#'
#' Function to reconcile time-series forecasts. Returns reconciled forecasts
#' using four methods: optimal (summing matrix), mean, median and residual
#' variance.
#'
#' @param fcsts forecast data frame.
#' @param S summing matrix.
#' @param variable_cols variable column. Columns that provide a unique
#'   identifier for each time-series forecast.
#' @param zone_cols zones of the hierarchy. Need to be in the same order as for
#'   the summing matrix.
#'
#' @export
hts_reconciliation <- function(
  fcsts, S, W_mean, W_median, W_res_var,
  prediction_col = "Prediction",
  variable_cols = c("Simulation", "ts", "Date", "Hour"),
  zone_cols = c("TOTAL", "ME", "NH", "VT", "CT", "RI", "MASS", "SEMASS",
                "WCMASS", "NEMASSBOST")
) {
  hts_raw <- fcsts %>%
    select(one_of(variable_cols), Zone, Prediction = get(prediction_col)) %>%
    spread(Zone, Prediction) %>%
    select(one_of(c(variable_cols, zone_cols)))

  hts_rec_sum <- t(apply(as.matrix(hts_raw[,zone_cols]), 1, h_rec, S))
  hts_rec_mean <- t(apply(as.matrix(hts_raw[,zone_cols]), 1, h_rec_w, S, W_mean))
  hts_rec_median <- t(apply(as.matrix(hts_raw[,zone_cols]), 1, h_rec_w, S, W_median))
  hts_rec_res_var <- t(apply(as.matrix(hts_raw[,zone_cols]), 1, h_rec_w, S, W_res_var))

  colnames(hts_rec_sum) <- colnames(hts_rec_mean) <- colnames(hts_rec_median) <-
    colnames(hts_rec_res_var) <- zone_cols

  hts_rec_sum <- format_rec_df(hts_raw, hts_rec_sum, variable_cols, "Prediction_rec")
  hts_rec_mean <- format_rec_df(hts_raw, hts_rec_mean, variable_cols, "Prediction_rec_mean")
  hts_rec_median <- format_rec_df(hts_raw, hts_rec_median, variable_cols, "Prediction_rec_median")
  hts_rec_res_var <- format_rec_df(hts_raw, hts_rec_res_var, variable_cols, "Prediction_rec_res_var")

  return(list(summing = hts_rec_sum,
              mean = hts_rec_mean,
              median = hts_rec_median,
              residual_var = hts_rec_res_var))
}
