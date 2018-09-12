#' autoscore
#'
#' Takes a data frame with target words and response words and calculates the number of matches based on a number of rules.
#'
#' @param .data The data.frame (or tbl_df) to be used to autoscore
#' @param acceptable_df A user-provided data.frame of original and alternate spellings for words in the target/response lists (this is the \code{acceptable_spell_rule} and is in addition to built-in homophone list that can be seen with \code{data(homophones)})
#' @param position_rule the amount a word can vary from the correct position in the phrase and be correct (default = 99)
#' @param homophone_rule should homophones be used? (default = TRUE)
#' @param suffix_rule should the words be stemmed (all suffix characters removed)? (default = FALSE); if TRUE, s_rule and ed_rule are FALSE
#' @param s_rule if target or response added or subtracted -s and -es at the end of the word,  count as correct (default = TRUE)
#' @param s_add_rule only if response has an additional -s or -es (not missing either at the end of the word) to be counted right. Differs from \code{s_rule} since this can only be added to the end of the response word, not missing from it.
#' @param ed_rule if target or response added or subtracted -d and -ed at the end of the word,  count as correct (default = TRUE)
#' @param ed_add_rule only if response has an additional -d or -ed (not missing either at the end of the word) to be counted right. Differs from \code{ed_rule} since this can only be added to the end of the response word, not missing from it.
#' @param a_the_rule should "a" and "the" be considered the same? (default = TRUE)
#' @param rootword_rule should a word that contains the target word (either at the beginning or end of the response word) be considered correct (default = FALSE because does "partial" matching which can bring in some unexpected results)
#' @param common_misspell_rule should a large common misspellings list be used to correct spelling? default is TRUE
#' @param double_letter_rule should double letters within a word (the t in 'attack') be considered the same as if there is only one of that latter ('atack'); some of these will be in the common_misspell_rule; default = FALSE
#' @param output the output type for the autoscore table; current options are "text" (provides a cleaned data set) and "none" (which provides all data); others to follow soon
#'
#' @import dplyr
#' @import tibble
#' @importFrom stats setNames
#' @importFrom stats na.omit
#'
#' @export
autoscore <- function(.data,
                      acceptable_df = NULL,
                      position_rule = 99,
                      homophone_rule = TRUE,
                      suffix_rule = FALSE,
                      s_rule = TRUE,
                      s_add_rule = TRUE,
                      ed_rule = TRUE,
                      ed_add_rule = TRUE,
                      a_the_rule = TRUE,
                      rootword_rule = FALSE,
                      common_misspell_rule = TRUE,
                      double_letter_rule = FALSE,
                      output = "text") {

  error_check_rules(homophone_rule, suffix_rule, s_rule, ed_rule,
                    a_the_rule, rootword_rule, common_misspell_rule,
                    double_letter_rule)
  error_check_alternate_df(acceptable_df)
  error_check_position(position_rule)

  counts <- split_clean(.data) %>%
    match_position_basic(alternate_df = acceptable_df,
                         homophone_rule = homophone_rule,
                         s_rule = s_rule,
                         s_add_rule = s_add_rule,
                         ed_rule = ed_rule,
                         ed_add_rule = ed_add_rule,
                         a_the_rule = a_the_rule,
                         rootword_rule = rootword_rule,
                         suffix_rule = suffix_rule,
                         common_misspell_rule = common_misspell_rule,
                         double_letter_rule = double_letter_rule) %>%
    count_matches(position_rule = position_rule)

  if (output == "none"){
    counts
  } else {
    format_output(counts, output = output, .data)
  }
}
