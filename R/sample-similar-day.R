#' Sample similar days
#'
#' Takes a date as an input and randomly samples another similar date. Similar
#' dates can be defined by day of the week or working/non-working days. A window
#' that indicates how many months eitherside of the current date can be used for
#' sampling can also be specified.
#'
#' TODO: filter for adjacent (+-3) months when selecting residuals - get them from roughly the same time of year
#' TODO: split up for holidays and non-holidays
#'
#' TODO: change this so that forecast data frame isn't input. Can just return a
#' vector of residuals that gets added to data frame.
#'
#'
#' @param x_resid data frame containing residuals.
#' @param x_fcst data frame containing forecasts and dates.
#'
#' @return The forecast data frame with a new residuals column.
#' @export
#'
#' @author Cameron Roach
sample_similar_day <- function(x_resid, x_fcst) {
  x_resid <- x_resid %>%
    filter(Zone == x_fcst$Zone[1]) %>%
    select(Residual, Date, Period, DoW)

  n_periods <- length(unique(x_resid$Period))

  # remove DST days
  complete_days <- x_resid %>%
    count(Date) %>%
    filter(n == n_periods)
  x_resid <- filter(x_resid, Date %in% complete_days$Date) %>%
    arrange(Date, Period)

  output_df <- NULL
  for (iD in levels(x_fcst$DoW)) {
    tmp_fcst <- x_fcst %>%
      filter(DoW == iD)

    fcst_dates <- tmp_fcst %>%
      distinct(Date) %>%
      .$Date

    resid_dates <- x_resid %>%
      filter(DoW == iD) %>%
      distinct(Date) %>%
      .$Date %>%
      sample(length(fcst_dates))

    date_lkp <- data.frame(
      Date = fcst_dates,
      Date_resid = resid_dates
    )

    tmp_fcst <- inner_join(tmp_fcst, date_lkp, by = "Date")
    output_df <- bind_rows(output_df, tmp_fcst)
  }

  # Do a join between x_fcst and x_resid on resid_date
  output_df <- inner_join(output_df,
                          select(x_resid, Date, Period, Residual),
                          by = c("Date_resid" = "Date", "Period"))

  return(output_df)
}
