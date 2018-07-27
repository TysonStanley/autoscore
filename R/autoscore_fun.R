#' autoscore
#'
#' Function stuff
#'
#' @param .data The data.frame (or tbl_df) to be used to autoscore
#' @param ... the list of rules to apply
#' @param output the output type for the autoscore table; current options are "text" ...
#'
#' @import dplyr
#' @import purrr
#' @import stringr
#' @import tidyr
#' @import tibble
#'
#' @export
autoscore <- function(.data, ..., output = "text") {

  rules <- list(...)

  counts <- split_clean(.data) %>%
    match_position_basic() %>%
    count_matches(rules = rules)

  if (output == "none"){
    counts
  } else {
    format_output(counts, output = output, .data)
  }
}
