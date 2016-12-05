#' Load SMD data
#' 
#' Loads data for GEFCom2017-D.
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
    
    # Add extra variables
    # Note that factors are not ordered as this can adversely impact model fitting time in caret.
    smd <- smd %>% 
      mutate(Date = if_else(Hour == 24, Date + days(1), Date),
             Period = factor(smd$Hour, levels = 1:24, ordered = FALSE),
             Hour = if_else(Hour == 24, 0, Hour),
             ts = ymd_h(paste(Date, Hour)),
             Year = year(ts),
             Month = factor(month(ts, label = TRUE), ordered = FALSE),
             DoW = factor(wday(ts, label = TRUE), ordered = FALSE),
             DoY = yday(ts),
             Weekend = ifelse(DoW %in% c("Sat", "Sun"), TRUE, FALSE),
             DryDewDiff = DryBulb - DewPnt)
    
    # Add holidays
    smd <- left_join(smd, holidays) %>% 
      mutate(Holiday = if_else(is.na(Holiday), "NH", Holiday),
             Holiday_flag = if_else(Holiday == "NH", FALSE, TRUE))
    
    # cache smd data frame for speedy loading
    dir.create(file.path(root_dir, "cache"),
               showWarnings = FALSE)
    save(smd, file = file.path(root_dir, "cache/smd_data.Rdata"))
  }
  
  return(smd)
}