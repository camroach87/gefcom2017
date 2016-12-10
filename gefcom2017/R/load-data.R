#' Load SMD data
#'
#' Loads data for GEFCom2017-D.
#'
#' @param load_zones Electricity load zones.
#' @param root_dir Path to the root directory.
#'
#'
#' @return smd data_frame containing raw data and calendar variables
#' @export
#'
#' @author Cameron Roach
load_smd_data <- function(load_zones, root_dir = ".") {
  if (file.exists(file.path(root_dir, "cache/smd_data.Rdata"))) {
    # load smd data frame from cached file
    load(file.path(root_dir, "cache/smd_data.Rdata"))
  } else {
    # load raw data and then cache smd data frame
    holidays <- read.csv(file.path(root_dir, "data/holidays/holidays.csv"),
                         stringsAsFactors = FALSE) %>%
      mutate(Date = mdy(Date, tz="UTC"))


    smd <- NULL
    files <- list.files(file.path(root_dir, "data/smd"))
    for (iF in files) {
      cat("Reading file", iF, "...\n")
      file_name <- file.path(root_dir, "data/smd", iF)

      for (iS in load_zones) {
        tmp <- read_excel(file_name, sheet = iS) %>%
          mutate(Zone = iS) %>%
          select(Date, Hour, Zone, Demand = DEMAND, DryBulb, DewPnt) %>%
          filter(!is.na(Demand)) # some spreadsheet tabs have trailing blank rows

        smd <- bind_rows(smd, tmp)
      }
    }

    # cache smd data frame for speedy loading
    dir.create(file.path(root_dir, "cache"),
               showWarnings = FALSE)
    save(smd, file = file.path(root_dir, "cache/smd_data.Rdata"))
  }

  return(smd)
}
