#' Output quantile forecasts to excel
#'
#' @param x quantile forecasts
#' @param file excel file name.
#'
#' @return Saves an excel file with quantile forecasts for each zone.
#' @export
#'
#' @examples
save_results <- function(x, file) {

  sheet_order <- c("CT", "ME", "NEMASSBOST", "NH", "RI", "SEMASS", "VT",
                   "WCMASS", "MASS", "TOTAL")

  excel_output <- NULL
  for (iS in sheet_order) {
    excel_output[[iS]] <- x %>%
      filter(Zone == iS) %>%
      select(Date, Hour, Q10, Q20, Q30, Q40, Q50, Q60, Q70, Q80, Q90) %>%
      mutate(Date = format(Date, "%e/%m/%Y"))
  }

  dir.create("./output", F, T)
  WriteXLS(excel_output,
           ExcelFileName = file)
}
