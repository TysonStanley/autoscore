#' autoscore
#'
#' Takes a data frame with target words and response words and calculates the number of matches based on a number of rules.
#'
#' @param .data The data.frame (or tbl_df) to be used to autoscore
#' @param alternate_df A user-provided data.frame of original and alternate spellings for words in the target/response lists (this is in addition to built-in homophone list that can be seen with \code{data(homophones)})
#' @param position_rule the amount a word can vary from the correct position in the phrase and still be correct (default = 99)
#' @param homophone_rule should homophones be used? (default = TRUE)
#' @param stemmed_rule should the words be stemmed (all suffix characters removed)? (default = TRUE); if TRUE, plurals_rule and pasttense_rule are FALSE
#' @param plurals_rule should the plural suffix (-s, -es) be removed? (default = TRUE)
#' @param pasttense_rule should the past tense suffix (-d, -ed) be removed? (default = TRUE)
#' @param a_the_rule should "a" and "the" be considered the same? (default = TRUE)
#' @param firstpart_rule should a word that contains the target word (either at the beginning or end of the response word) be considered correct (default = FALSE because does "partial" matching which can bring in some unexpected results)
#' @param common_misspell_rule should a large common misspellings list be used to correct spelling? default is TRUE
#' @param output the output type for the autoscore table; current options are "text" (provides a cleaned data set) and "none" (which provides all data); others to follow soon
#'
#' @import dplyr
#' @import tibble
#' @importFrom stats setNames
#'
#' @export
autoscore <- function(.data,
                      alternate_df = NULL,
                      position_rule = NULL,
                      homophone_rule = NULL,
                      stemmed_rule = NULL,
                      plurals_rule = NULL,
                      pasttense_rule = NULL,
                      a_the_rule = NULL,
                      firstpart_rule = NULL,
                      common_misspell_rule = NULL,
                      output = "text") {

  error_check_alternate_df(alternate_df)
  error_check_position(position_rule)

  counts <- split_clean(.data) %>%
    match_position_basic(alternate_df = alternate_df,
                         homophone_rule = homophone_rule,
                         plurals_rule = plurals_rule,
                         pasttense_rule = pasttense_rule,
                         a_the_rule = a_the_rule,
                         firstpart_rule = firstpart_rule,
                         stemmed_rule = stemmed_rule,
                         common_misspell_rule = common_misspell_rule) %>%
    count_matches(position_rule = position_rule)

  if (output == "none"){
    counts
  } else {
    format_output(counts, output = output, .data)
  }
}
