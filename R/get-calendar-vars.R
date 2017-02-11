#' Get calendar variables
#'
#' Gets calendar variables such as holiday, hour, day of year, etc.
#'
#' @param x data frame containing date and hour data.
#'
#' @return A data frame containing calendar variables.
#' @export
#'
#' @author Cameron Roach
get_calendar_vars <- function(x, root_dir = ".") {
  root_dir <- system.file("extdata", package = "gefcom2017")

  holidays <- read.csv(file.path(root_dir, "holidays/holidays.csv"),
                       stringsAsFactors = FALSE) %>%
    mutate(Date = mdy(Date))

  x$Holiday <- NULL #just in case it is in passed data frame
  x <- left_join(x, holidays, by = "Date") %>%
    mutate(Holiday = if_else(is.na(Holiday), "NH", Holiday),
           Holiday_flag = if_else(Holiday == "NH", FALSE, TRUE),
           ts = ymd_h(paste(Date, Hour - 1)), # hour beginning for lubridate
           Period = factor(Hour, levels = 1:24, ordered = FALSE),
           Year = year(ts),
           Month = factor(month(ts, label = TRUE), ordered = FALSE),
           DoW = factor(wday(ts, label = TRUE), ordered = FALSE),
           DoY = yday(ts),
           Weekend = ifelse(DoW %in% c("Sat", "Sun"), TRUE, FALSE))

  return(x)
}
