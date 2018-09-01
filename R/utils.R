## Utilities for the package

## Read in and select the appropriate columns for the analysis
select_cols <- function(d){
  d <- d %>%
    dplyr::rename_all(tolower) %>%
    dplyr::select(contains("id"), contains("target"), contains("response"), contains("human"))

  if (ncol(d) > 4){
    stop("More than 4 columns were selected containing 'id', 'target', 'response', or 'human'", call. = FALSE)}
  else if (ncol(d) < 3){
    stop(paste0("Less than 3 columns were selected containing 'id', 'target', 'response', or 'human'\n",
                   " - One column should be named 'id', another named 'target', another named 'response', and",
                   "optionally one named 'human'. Check your CSV to upload again."), call. = FALSE)}
  d
}

split_clean <- function(d){
  select_cols(d) %>%
    dplyr::mutate(target = stringr::str_to_lower(target),
                  response = stringr::str_to_lower(response)) %>%
    dplyr::mutate(target = stringr::str_split(target, pattern = " "),
                  response = stringr::str_split(response, pattern = " "))
}

combine_alts <- function(alternate_df, common_misspell_rule){
  if (!is.null(alternate_df)){
    ## user provided list
    alternate_df <- alternate_df %>%
      dplyr::rename_all(tolower) %>%
      dplyr::rename("original" = "target",
                    "alternate" = "acceptable_response")

    if (isTRUE(common_misspell_rule)){
      #message("Note: List of common misspellings in data(alternate_df_default) were used.")
      ## list of 4268 common misspellings
      alternate_df <- dplyr::bind_rows(alternate_df, autoscore::alternate_df_default)
    }
  } else {

    if (isTRUE(common_misspell_rule)){
      #message("Note: List of common misspellings in data(alternate_df_default) were used.")
      ## list of 4268 common misspellings
      alternate_df <- autoscore::alternate_df_default
    }
  }
  alternate_df
}

alternate_fun <- function(d, alternate_df, common_misspell_rule){

  common_misspell_rule <- common_misspell_rule %||% TRUE

  if (is.null(alternate_df) & !isTRUE(common_misspell_rule)){
    return(d)

  } else {

    alternate_df <- combine_alts(alternate_df, common_misspell_rule)
    alternate_df <- alternate_df %>%
      dplyr::mutate(rowname = row_number(original)) %>%
      dplyr::mutate(alternate_string = stringr::str_split(alternate, pattern = ", "))

    .a = alternate_df %>% tidyr::unnest(.) %>% distinct(.)

    d %>%
      dplyr::mutate(target = purrr::map(target, ~{

        names(.x) = .x

        replace = .a %>%
          dplyr::filter(alternate_string %in% .x)

        what_to_replace = .a %>%
          dplyr::mutate(in_it = alternate_string %in% .x) %>%
          dplyr::filter(in_it) %>%
          dplyr::pull(alternate_string)

        replace$what_to_replace = what_to_replace

        .x[replace$what_to_replace] = replace$original
        .x

      })) %>%
      dplyr::mutate(response = purrr::map(response, ~{

        names(.x) = .x

        replace = .a %>%
          dplyr::filter(alternate_string %in% .x)

        what_to_replace = .a %>%
          dplyr::mutate(in_it = alternate_string %in% .x) %>%
          dplyr::filter(in_it) %>%
          dplyr::pull(alternate_string)

        replace$what_to_replace = what_to_replace

        .x[replace$what_to_replace] = replace$original
        .x

      }))
  }
}

homophones_fun <- function(d){

  ## grabs the list of homophones
  homophones <- autoscore::homophones %>%
    dplyr::mutate(homophone_string = stringr::str_split(homophone, pattern = ", "))

  .h = homophones %>% tidyr::unnest(.)

  ## Applies the homophones
  d %>%
    dplyr::mutate(homophone_target = purrr::map(target, ~{

      names(.x) = .x

      replace = .h %>%
        dplyr::filter(homophone_string %in% .x)

      what_to_replace = .h %>%
        dplyr::mutate(in_it = homophone_string %in% .x) %>%
        dplyr::filter(in_it) %>%
        dplyr::pull(homophone_string)

      replace$what_to_replace = what_to_replace

      replace = replace %>%
        dplyr::mutate(replacement = stringr::str_replace(homophone, pattern = ", .*$", replacement = ""))

      .x[replace$what_to_replace] = replace$replacement
      .x

    })) %>%
    dplyr::mutate(homophone_response = purrr::map(response, ~{

      names(.x) = .x

      replace = .h %>%
        dplyr::filter(homophone_string %in% .x)

      what_to_replace = .h %>%
        dplyr::mutate(in_it = homophone_string %in% .x) %>%
        dplyr::filter(in_it) %>%
        dplyr::pull(homophone_string)

      replace$what_to_replace = what_to_replace

      replace = replace %>%
        dplyr::mutate(replacement = stringr::str_replace(homophone, pattern = ", .*$", replacement = ""))

      .x[replace$what_to_replace] = replace$replacement
      .x

    }))

}


match_fun <- function(x, y, rootword_rule) {

  ## depending on rootword_rule should pmatch or match be used
  switch(rootword_rule,
         firstpart = pmatch(x, y),
         no_firstpart = match(x, y))

}


## Main work horse function
match_position_basic <- function(d, alternate_df, homophone_rule, pasttense_rule,
                                 plurals_rule, a_the_rule, rootword_rule, suffix_rule,
                                 common_misspell_rule, double_letter_rule){

  if (isTRUE(suffix_rule)){
    pasttense_rule <- FALSE
    plurals_rule   <- FALSE
  }

  if (isTRUE(rootword_rule)){
    rootword_rule <- "firstpart"
  } else {
    rootword_rule <- "no_firstpart"
  }

  ## alternate_spell_rule
  d <- alternate_fun(d, alternate_df, common_misspell_rule)

  ## homophone_rule
  if (isTRUE(homophone_rule)){
    #message("Note: Homophones in data(homophones) were used.")
    d <- homophones_fun(d)

    d <- d %>%
      dplyr::mutate(homophone_target = purrr::map(homophone_target, ~{
        stringr::str_replace_all(.x, pattern = "[[:punct:]]", replacement = "") %>%
          double_letter_fun(double_letter_rule) %>%
          a_the_fun(a_the_rule) %>%
          suffix_fun(suffix_rule)

      })) %>%
      dplyr::mutate(homophone_response = purrr::map(homophone_response, ~{
        stringr::str_replace_all(.x, pattern = "[[:punct:]]", replacement = "") %>%
          double_letter_fun(double_letter_rule) %>%
          a_the_fun(a_the_rule) %>%
          suffix_fun(suffix_rule)

      })) %>%
      dplyr::mutate(diff_target_pre = purrr::map2(homophone_target, homophone_response, ~{
        pasttense_plurals_fun(.x, .y, pasttense_rule, plurals_rule, rootword_rule)

      })) %>%
      dplyr::mutate(diff_response_pre = purrr::map2(homophone_response, homophone_target, ~{
        pasttense_plurals_fun(.x, .y, pasttense_rule, plurals_rule, rootword_rule)

      }))

  } else {

    d <- d %>%
      dplyr::mutate(target = purrr::map(target, ~{
        stringr::str_replace_all(.x, pattern = "[[:punct:]]", replacement = "") %>%
          double_letter_fun(double_letter_rule) %>%
          a_the_fun(a_the_rule) %>%
          suffix_fun(suffix_rule)

      })) %>%
      dplyr::mutate(response = purrr::map(response, ~{
        stringr::str_replace_all(.x, pattern = "[[:punct:]]", replacement = "") %>%
          double_letter_fun(double_letter_rule) %>%
          a_the_fun(a_the_rule) %>%
          suffix_fun(suffix_rule)

      })) %>%
      dplyr::mutate(diff_target_pre = purrr::map2(target, response, ~{
        pasttense_plurals_fun(.x, .y, pasttense_rule, plurals_rule, rootword_rule)

      })) %>%
      dplyr::mutate(diff_response_pre = purrr::map2(response, target, ~{
        pasttense_plurals_fun(.x, .y, pasttense_rule, plurals_rule, rootword_rule)

      }))
  }

  d %>%
    dplyr::mutate(diff_target = purrr::map(diff_target_pre, ~.x - 1:length(.x))) %>%
    dplyr::mutate(diff_response = purrr::map(diff_response_pre, ~.x - 1:length(.x)))
}




suffix_fun <- function(chr, use = TRUE){
  if (isTRUE(use)){
    tm::stemDocument(chr)
  } else {
    chr
  }
}

pasttense_plurals_fun <- function(x, y, pasttense_rule, plurals_rule, rootword_rule){
  if (isTRUE(pasttense_rule) & isTRUE(plurals_rule)){
    ed1 <- match_fun(paste0(x, "ed"), y, rootword_rule)
    ed2 <- match_fun(paste0(x, "d"), y, rootword_rule)
    ed3 <- match_fun(x, paste0(y, "ed"), rootword_rule)
    ed4 <- match_fun(x, paste0(y, "d"), rootword_rule)
    es1 <- match_fun(paste0(x, "es"), y, rootword_rule)
    es2 <- match_fun(paste0(x, "s"), y, rootword_rule)
    es3 <- match_fun(x, paste0(y, "es"), rootword_rule)
    es4 <- match_fun(x, paste0(y, "s"), rootword_rule)
    reg <- match_fun(x, y, rootword_rule)
    na.omit(c(ed1, ed2, ed3, ed4, es1, es2, es3, es4, reg)) %>% unique %>% as.numeric
  } else if (isTRUE(plurals_rule)) {
    es1 <- match_fun(paste0(x, "es"), y, rootword_rule)
    es2 <- match_fun(paste0(x, "s"), y, rootword_rule)
    es3 <- match_fun(x, paste0(y, "es"), rootword_rule)
    es4 <- match_fun(x, paste0(y, "s"), rootword_rule)
    reg <- match_fun(x, y, rootword_rule)
    na.omit(c(es1, es2, es3, es4, reg)) %>% unique %>% as.numeric
  } else if (isTRUE(pasttense_rule)) {
    ed1 <- match_fun(paste0(x, "ed"), y, rootword_rule)
    ed2 <- match_fun(paste0(x, "d"), y, rootword_rule)
    ed3 <- match_fun(x, paste0(y, "ed"), rootword_rule)
    ed4 <- match_fun(x, paste0(y, "d"), rootword_rule)
    reg <- match_fun(x, y, rootword_rule)
    na.omit(c(ed1, ed2, ed3, ed4, reg)) %>% unique %>% as.numeric
  } else {
    match(x, y)
  }
}


a_the_fun <- function(chr, use = TRUE){
  if (isTRUE(use)){
    stringr::str_replace(chr, pattern = "^a$", replacement = "the")
  } else {
    chr
  }
}

double_letter_fun <- function(chr, use = FALSE){
  if (isTRUE(use)){
    stringr::str_replace_all(chr, pattern = "([[:alpha:]])\\1+", replacement = "\\1")
  } else {
    chr
  }
}


count_matches <- function(d, position_rule) {

  position_rule <- position_rule %||% 99

  d %>%
    dplyr::mutate(count_target = purrr::map(diff_target,
                                            ~ifelse(abs(.x) <= position_rule, 1, NA)) %>%
                    purrr::map(~.x[complete.cases(.x)]) %>%
                    purrr::map(~length(.x)) %>% unlist) %>%
    dplyr::mutate(count_response = purrr::map(diff_response,
                                              ~ifelse(abs(.x) <= position_rule, 1, NA)) %>%
                    purrr::map(~.x[complete.cases(.x)]) %>%
                    purrr::map(~length(.x)) %>% unlist)
}


format_output <- function(final_table, output, original_data) {

  original_data <- original_data %>%
    dplyr::rename_all(tolower)

  if (isTRUE("human" %in% names(final_table))){

    orig_d2 <- original_data %>%
      dplyr::select(-id, -target, -response, -human)

    ft <- final_table %>%
      dplyr::select(human, count_target) %>%
      dplyr::mutate(equal = human == count_target)
    ft <- cbind(original_data$id, original_data$target, original_data$response,
                ft, orig_d2) %>%
      stats::setNames(c("id", "target", "response", "human", "autoscore", "equal",
                        names(orig_d2)))
  } else {

    orig_d2 <- original_data %>%
      dplyr::select(-id, -target, -response)

    ft <- final_table %>%
      dplyr::select(count_target)
    ft <- cbind(original_data$id, original_data$target, original_data$response,
                ft, orig_d2) %>%
      stats::setNames(c("id", "target", "response", "autoscore",
                        names(orig_d2)))
  }

  if (output == "text"){
    ft
  }
}

error_check_alternate_df <- function(alternate_df){
  if (!is.null(alternate_df)){
    stopifnot(is.data.frame(alternate_df))
  }
}

error_check_position <- function(position_rule){
  if (!is.null(position_rule)){
    stopifnot(is.numeric(position_rule) & position_rule > 0)
  }
}

error_check_rules <- function(...){
  rules <- list(...)

  for (i in seq_along(rules)){
    if (!is.logical(rules[[i]])){
      stop(paste(names(rules)[i], "must be either TRUE or FALSE"), call. = FALSE)
    }
  }
}


## Infix operator (null-default)
`%||%` <- purrr::`%||%`


#' re-export magrittr pipe operator
#'
#' @importFrom magrittr %>%
#' @name %>%
#' @rdname pipe
#' @export
NULL

## From tidyverse package
text_col <- function(x) {
  # If RStudio not available, messages already printed in black
  if (!rstudioapi::isAvailable()) {
    return(x)
  }

  if (!rstudioapi::hasFun("getThemeInfo")) {
    return(x)
  }

  theme <- rstudioapi::getThemeInfo()

  if (isTRUE(theme$dark)) crayon::white(x) else crayon::black(x)

}

autoscore_version <- function(x) {
  version <- as.character(unclass(utils::packageVersion(x))[[1]])
  crayon::italic(paste0(version, collapse = "."))
}

search_conflicts <- function(path = search()){

  ## Search for conflicts
  confs <- conflicts(path,TRUE)
  ## Grab those with the autoscore package
  autoscore_conflicts <- confs$`package:autoscore`

  ## Find which packages have those functions that are conflicted
  if (length(autoscore_conflicts) != 0){
    other_conflicts <- list()
    for (i in autoscore_conflicts){
      other_conflicts[[i]] <- lapply(confs, function(x) any(grepl(i, x))) %>%
        do.call("rbind", .) %>%
        data.frame %>%
        setNames(c("conflicted")) %>%
        tibble::rownames_to_column() %>%
        .[.$conflicted == TRUE &
            .$rowname != "package:autoscore",]
    }
  } else {
    other_conflicts <- data.frame()
  }
  other_conflicts
}
