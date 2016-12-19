#' Block bootstrap
#'
#' Generates bootstrapped residuals using a block bootstrapping approach. Works
#' in a different fashion to \code{dbl_block_bs} as it must apply the
#' bootstrapped residuals to forecast data frame. Runs several checks to remove
#' incomplete days from historical residuals.
#'
#' TODO: change this so that forecast data frame isn't input. Can just return a
#' vector of residuals that gets added to data frame.
#'
#'
#' @param x_resid data frame containing residuals.
#' @param x_fcst data frame containing forecasts and dates.
#' @param block_length numeric. Length of bootstrap blocks.
#'
#' @return The forecast data frame with a new residuals column.
#' @export
#'
#' @author Cameron Roach
resid_block_bs <- function(x_resid, x_fcst, block_length = 4) {
  x_resid <- x_resid %>%
    filter(Zone == x_fcst$Zone[1]) %>%
    select(Residual, Date, Period)

  n_periods <- length(unique(x_resid$Period))

  # remove DST days
  complete_days <- x_resid %>%
    count(Date) %>%
    filter(n == n_periods)
  x_resid <- filter(x_resid, Date %in% complete_days$Date) %>%
    arrange(Date, Period)

  # remove final incomplete block
  final_block_mod <- dim(x_resid)[1] %% (block_length * n_periods)
  if (final_block_mod != 0) {
    x_resid <- x_resid[-c(dim(x_resid)[1]:(dim(x_resid)[1] - final_block_mod + 1)),]
  }

  # Assign block numbers to historical residuals. Using an index based on ordered
  # rows rather than dates because some dates have been filtered out due to DST.
  block_idx <- 1
  iB <- 1
  x_resid$Block <- NA
  while (block_idx < dim(x_resid)[1]) {
    block_idx_vec <- block_idx + 0:(block_length * n_periods - 1)
    x_resid$Block[block_idx_vec] <- iB
    iB <- iB + 1
    block_idx <- block_idx + block_length * n_periods
  }
  n_resid_blocks <-max(x_resid$Block)

  # Sample blocks from historical residual dataframe and fill in fcst_df residual column
  fcst_n_days <- as.numeric(max(x_fcst$Date) - min(x_fcst$Date)) + 1
  fcst_n_blocks <- ceiling(fcst_n_days/block_length)
  x_fcst$Residual <- NA
  for (iB in 1:fcst_n_blocks) {
    bs_sample <- sample(1:n_resid_blocks, 1)
    bs_resid <- x_resid$Residual[x_resid$Block == bs_sample]
    row_idx <- ((iB - 1) * block_length * n_periods + 1):(iB * block_length * n_periods)

    if (max(row_idx) <= dim(x_fcst)[1]) {
      x_fcst[row_idx, "Residual"] <- bs_resid
    } else {
      row_idx <- row_idx[row_idx <= dim(x_fcst)[1]]
      bs_resid <- bs_resid[1:length(row_idx)]

      x_fcst[row_idx, "Residual"] <- bs_resid
    }
  }
  return(x_fcst)
}
