#' Load SMD data
#'
#' Cleans smd data for GEFCOM-D. Removes DST hours and adjusts DoY values in
#' leap years.
#'
#' The DoY adjustment for leap years sets 29th Feb to have the same DoY as 28th
#' Feb (59) and subtracts 1 from DoY for all days after 29th Feb. This results
#' in both leap years and non-leap years having DoY values of 1,2,...,365.
#'
#' @param smd smd data frame containing columns DoY, Year and ts.
#'
#' @return smd data_frame containing raw data and calendar variables
#' @export
#'
#' @author Cameron Roach
clean_smd_data <- function(smd) {
  root_dir <- system.file("extdata", package = "gefcom2017")

  dst_times <- read.csv(file.path(root_dir, "dst_ts.csv")) %>%
    mutate(dst_start = ymd_hms(dst_start),
           dst_end = ymd_hms(dst_end))

  # Remove DST hours
  smd <- smd %>%
    filter(!(ts %in% dst_times$dst_start)) %>%
    filter(!(ts %in% dst_times$dst_end))

  # Shift DoY for leap years. Feb 29 has DoY == 60
  smd <- smd %>%
    mutate(DoY = if_else(leap_year(Year) & DoY >= 60,
                         DoY - 1, DoY))

  return(smd)
}
