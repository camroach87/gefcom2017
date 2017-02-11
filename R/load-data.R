#' Load SMD data
#'
#' Loads data for GEFCom2017-D.
#'
#' @param load_zones Electricity load zones.
#' @param cache_dir Path to the cache directory.
#' @param ignore_cache logical. If TRUE, ignores any cached files and reloads data.
#'
#'
#' @return smd data_frame containing raw data and calendar variables
#' @export
#'
#' @author Cameron Roach
load_smd_data <- function(load_zones, cache_dir = "./cache", ignore_cache = FALSE) {

  root_dir = system.file("extdata", package = "gefcom2017")

  if (file.exists(file.path(cache_dir, "smd_data.Rdata")) &
      !ignore_cache) {
    # load smd data frame from cached file
    load(file.path(root_dir, "cache/smd_data.Rdata"))
  } else {
    # load raw data and then cache smd data frame
    smd <- NULL
    files <- list.files(file.path(root_dir, "smd"))
    for (iF in files) {
      cat("Reading file", iF, "...\n")
      file_name <- file.path(root_dir, "smd", iF)

      for (iS in load_zones) {
        tmp <- read_excel(file_name, sheet = iS) %>%
          mutate(Zone = iS,
                 Date = as.Date(Date)) %>%
          select(Date, Hour, Zone, Demand = DEMAND, DryBulb, DewPnt) %>%
          filter(!is.na(Demand)) # some spreadsheet tabs have trailing blank rows

        smd <- bind_rows(smd, tmp)
      }
    }

    # Add holidays and calendar variables
    smd <- get_calendar_vars(smd, root_dir)

    # Add any remaining variables
    smd <- smd %>%
      mutate(DryDewDiff = DryBulb - DewPnt)

    # cache smd data frame for speedy loading
    dir.create(cache_dir, F, T)
    save(smd, file = file.path(cache_dir, "smd_data.Rdata"))
  }

  return(smd)
}
