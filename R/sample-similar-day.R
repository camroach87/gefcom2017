#' Sample similar days
#'
#' Takes a vector of dates as inputs and randomly samples another similar date
#' from the residual data frame. Similar dates can be defined by day of the week
#' or working/non-working days.
#'
#' TODO: remove DST days from potential sample candidates.
#'
#' TODO: maybe include a window so that samples come from same time of year
#' (i.e. within a few months)
#'
#'
#' @param fcst_dates data frame containing forecasts dates. These are the dates
#'   we wish to find similar dates for.
#' @param resid_dates data frame of residual date info. Must contain Date and
#'   Holiday_flag columns. Only unique values should be included
#'
#' @return The forecast data frame with a new residuals column.
#' @export
#'
#' @author Cameron Roach
sample_similar_day <- function(fcst_dates, resid_dates) {
  root_dir <- system.file("extdata", package = "gefcom2017")
  holidays <- read.csv(file.path(root_dir, "holidays/holidays.csv"),
                       stringsAsFactors = FALSE) %>%
    mutate(Date = mdy(Date))

  fcst_dates = data_frame(Date = fcst_dates) %>%
    left_join(holidays) %>%
    mutate(Holiday = if_else(is.na(Holiday), "NH", Holiday),
           Holiday_flag = if_else(Holiday == "NH", FALSE, TRUE))

  for (iD in 1:length(fcst_dates$Date)) {
    resid_like_days <- resid_dates %>%
      filter(wday(Date) == wday(fcst_dates$Date[iD]),
             Holiday_flag == fcst_dates$Holiday_flag[iD])

    if (iD == 1) {
      resid_date_samples <- sample(resid_like_days$Date, 1)
    } else {
      resid_date_samples <- c(resid_date_samples,
                              sample(resid_like_days$Date, 1))
    }
  }

  fcst_dates <- fcst_dates %>%
    mutate(Resid_date = resid_date_samples) %>%
    select(Date, Resid_date)

  return(fcst_dates)
}
