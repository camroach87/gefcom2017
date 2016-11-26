#' Load SMD data
#' 
#' Loadas data for GEFCom2017-D
#' 
#' @param root_dir Path to the root directory.
#' @param load_zones Electricity load zones.
#'
#' 
#' @return smd data_frame containing raw data and calendar variables
#' @export
#' 
#' @examples
#' 
#' @author Cameron Roach
load_smd_data <- function(root_dir = ".", load_zones) {
  # TODO: Why are there NAs appearing in ts?
  #
  # TODO: Use holidays data frame to add dummy variable for holiday in smd data 
  # frame
  
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
        select(Date, Hour, Zone, Demand = DEMAND, DryBulb, DewPnt)
      
      smd <- bind_rows(smd, tmp)
    }
  }
  
  # Add extra variables
  smd <- smd %>% 
    mutate(Date = if_else(Hour == 24, Date + days(1), Date),
           Hour = if_else(Hour == 24, 0, Hour),
           ts = ymd_h(paste(Date, Hour)),
           Year = year(ts),
           Month = month(ts, label = TRUE),
           DoW = wday(ts, label = TRUE),
           Weekend = ifelse(DoW %in% c("Sat", "Sun"), TRUE, FALSE),
           DryDewDiff = DryBulb - DewPnt)
  
  # Add holidays
  smd <- full_join(smd, holidays) %>% 
    mutate(Holiday = if_else(is.na(Holiday), "NH", Holiday),
           Holiday_flag = if_else(Holiday == "NH", FALSE, TRUE))
  
  return(smd)
}