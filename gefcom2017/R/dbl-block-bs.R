#' Double seasonal block bootstrap
#'
#' Generates bootstrapped dates using a double seasonal block bootstrap approach.
#'
#' @param date_series array of dates.
#' @param start_date start date for period we want bootstrap samples for.
#' @param end_date end date for period we want bootstrap samples for.
#' @param n_sims number of simulations. Defaults to 100 simulations.
#' @param avg_block_len average length of blocks. Defaults to 14 days.
#' @param delta_loc amount to randomise current location by when sampling blocks. See details.
#' @param delta_len amount to randomise block length by. See details.
#'
#' delta_loc shifts the current location in the simulated year by a random amount before sampling from a random historical year.
#'
#' @return A data frame with two columns. One for simulation number and another for bootstrapped dates.
#' @export
#'
#' @author Cameron Roach
dbl_block_bs <- function(dates, start_date = today(), end_date = today() + 30,
                         n_sims = 100, avg_block_len = 14, delta_loc = 3,
                         delta_len = 3) {

  dates <- sort(as.Date(unique(dates)))
  first_date <- min(dates)
  final_date <- max(dates)
  years <- unique(year(dates))
  end_date <- as.Date(end_date)
  start_date <- as.Date(start_date)
  bs_length <- end_date - start_date + 1
  date_seq <- seq(start_date, end_date, 1)
  if (start_date >= end_date) stop("Start date greater than or equal to end date.")
  if (bs_length > 365) stop("Start and end dates should not be more than a year apart.")

  bs_sim <- NULL
  for (iS in 1:n_sims) {
    # initialise
    bs_tmp <- NULL
    loc_date <- start_date
    while (loc_date <= end_date) {
      year_sample <- sample(years, 1)
      block_loc <- loc_date + sample(-delta_loc:delta_loc, 1)
      block_length <- avg_block_len + sample(-delta_len:delta_len, 1)

      # update block location with sampled year
      # resample if NA produced (leap years/start of dates cause issues)
      block_loc_bkp <- block_loc
      year(block_loc) <- year_sample
      if (is.na(block_loc) | block_loc < first_date) {
        block_loc <- block_loc_bkp
        next
      }

      bs_dates <- block_loc + 0:(block_length - 1)

      # resample if sampling dates after historical data ends
      if (tail(bs_dates, 1) > final_date) {
        block_loc <- block_loc_bkp
        next
      }
      # update
      bs_tmp <- bind_rows(bs_tmp,
                          data.frame(Simulation = iS,
                                     Date = bs_dates))
      loc_date <- loc_date + block_length
    }
    bs_tmp <- bs_tmp[1:bs_length,]
    bs_sim <- bind_rows(bs_sim, bs_tmp)
  }
  bs_sim$Date_seq <- rep(date_seq, n_sims)
  return(bs_sim)
}
