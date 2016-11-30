#' Pinball loss function
#' 
#' Calculates the pinball loss score for a given quantile.
#' 
#' @param tau integer 1, 2, ... 99. Quantile to calculate pinball loss score
#'   for.
#' @param y numeric. Observed value.
#' @param q numeric. Predicted value for quantile tau.
#'   
#' @return Pinball loss score.
#' @export
#' 
#' @examples
pinball_loss <- function(tau, y, q) {
  pl_df <- data.frame(tau = tau,
                      y = y,
                      q = q)
  
  pl_df <- pl_df %>% 
    mutate(L = ifelse(y>=q,
                      tau/100 * (y-q),
                      (1-tau/100) * (q-y)))
  
  return(pl_df)
}