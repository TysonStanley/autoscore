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

homophones_fun <- function(d){

  homophones <- autoscore::homophones %>%
    dplyr::mutate(homophone_string = stringr::str_split(homophone, pattern = ", "))

  d %>%
    dplyr::mutate(homophone_target = purrr::map(target, ~{
      .h = homophones %>% tidyr::unnest(.)
      replace = .h %>%
        dplyr::filter(homophone_string %in% .x) %>%
        dplyr::pull(rowname)
      any_phones = homophones %>%
        .[replace, ]

      if (length(any_phones) > 0){
        replace_it = any_phones %>%
          dplyr::mutate(replacement = str_replace(homophone, pattern = ", .*$", replacement = "")) %>%
          dplyr::pull(replacement)

        .x[.x %in% (.h %>% dplyr::pull(homophone_string))] = replace_it
        .x
      } else {
        .x
      }

    })) %>%
    dplyr::mutate(homophone_response = purrr::map(response, ~{
      .h = homophones %>% tidyr::unnest(.)
      replace = .h %>%
        dplyr::filter(homophone_string %in% .x) %>%
        dplyr::pull(rowname)
      any_phones = homophones %>%
        .[replace, ]

      if (length(any_phones) > 0){
        replace_it = any_phones %>%
          dplyr::mutate(replacement = str_replace(homophone, pattern = ", .*$", replacement = "")) %>%
          dplyr::pull(replacement)

        .x[.x %in% (.h %>% dplyr::pull(homophone_string))] = replace_it
        .x
      } else {
        .x
      }
    }))

}

match_position_basic <- function(d, rules = NULL){

  homophone_rule <- rules[["homophone_rule"]] %||% TRUE

  if (isTRUE(homophone_rule)){
    message("Note: Homophones in data(homophones) were used.")
    d <- homophones_fun(d)

    d %>%
      dplyr::mutate(homophone_target = purrr::map(homophone_target, ~{
        stringr::str_replace(.x, pattern = "[[:punct:]]", replacement = "") %>%
          stringr::str_replace(pattern = "s$", replacement = "") %>%
          stringr::str_replace(pattern = "^a$", replacement = "the") %>%
          stringr::str_replace(pattern = "ed$", replacement = "")

      })) %>%
      dplyr::mutate(homophone_response = purrr::map(homophone_response, ~{
        stringr::str_replace(.x, pattern = "[[:punct:]]", replacement = "") %>%
          stringr::str_replace(pattern = "s$", replacement = "") %>%
          stringr::str_replace(pattern = "^a$", replacement = "the") %>%
          stringr::str_replace(pattern = "ed$", replacement = "")
      })) %>%
      dplyr::mutate(pos_target = purrr::map2(homophone_target, homophone_response, ~{
        which(.x %in% .y)
      }),
      pos_response = purrr::map2(homophone_response, homophone_target, ~{
        which(.x %in% .y)
      })) %>%
      dplyr::mutate(pos_target_word = purrr::map2(homophone_target, pos_target, ~.x[.y]),
                    pos_response_word = purrr::map2(homophone_response, pos_response, ~.x[.y])) %>%
      dplyr::mutate(diff_target = purrr::map2(pos_target_word, pos_response_word, ~{
        pmatch(.x, .y)
      })) %>%
      dplyr::mutate(diff_response = purrr::map2(pos_response_word, pos_target_word, ~{
        pmatch(.x, .y)
      })) %>%
      dplyr::mutate(diff_target = purrr::map(diff_target, ~.x - 1:length(.x))) %>%
      dplyr::mutate(diff_response = purrr::map(diff_response, ~.x - 1:length(.x)))

  } else {

    d %>%
      dplyr::mutate(target = purrr::map(target, ~{
        stringr::str_replace(.x, pattern = "[[:punct:]]", replacement = "") %>%
          stringr::str_replace(pattern = "s$", replacement = "") %>%
          stringr::str_replace(pattern = "^a$", replacement = "the") %>%
          stringr::str_replace(pattern = "ed$", replacement = "")

      })) %>%
      dplyr::mutate(response = purrr::map(response, ~{
        stringr::str_replace(.x, pattern = "[[:punct:]]", replacement = "") %>%
          stringr::str_replace(pattern = "s$", replacement = "") %>%
          stringr::str_replace(pattern = "^a$", replacement = "the") %>%
          stringr::str_replace(pattern = "ed$", replacement = "")
      })) %>%
      dplyr::mutate(pos_target = purrr::map2(target, response, ~{
        which(.x %in% .y)
      }),
      pos_response = purrr::map2(response, target, ~{
        which(.x %in% .y)
      })) %>%
      dplyr::mutate(pos_target_word = purrr::map2(target, pos_target, ~.x[.y]),
                    pos_response_word = purrr::map2(response, pos_response, ~.x[.y])) %>%
      dplyr::mutate(diff_target = purrr::map2(pos_target_word, pos_response_word, ~{
        pmatch(.x, .y)
      })) %>%
      dplyr::mutate(diff_response = purrr::map2(pos_response_word, pos_target_word, ~{
        pmatch(.x, .y)
      })) %>%
      dplyr::mutate(diff_target = purrr::map(diff_target, ~.x - 1:length(.x))) %>%
      dplyr::mutate(diff_response = purrr::map(diff_response, ~.x - 1:length(.x)))
  }

}

count_matches <- function(d, rules = NULL) {

  position_rule <- rules[["position_rule"]] %||% 1

  d %>%
    dplyr::mutate(match_target = purrr::map(diff_target, ~ifelse(abs(.x) <= position_rule, .x, NA))) %>%
    dplyr::mutate(match_response = purrr::map(diff_response, ~ifelse(abs(.x) <= position_rule, .x, NA))) %>%
    dplyr::mutate(match_target = purrr::map(match_target, ~.x[complete.cases(.x)])) %>%
    dplyr::mutate(match_response = purrr::map(match_response, ~.x[complete.cases(.x)])) %>%
    dplyr::mutate(count_target = purrr::map(match_target, ~length(.x)) %>% unlist,
                  count_response = purrr::map(match_target, ~length(.x)) %>% unlist)
}


format_output <- function(final_table, output, original_data) {

  original_data <- original_data %>%
    dplyr::rename_all(tolower)

  if (isTRUE("human" %in% names(final_table))){
    ft <- final_table %>%
      select(human, count_response) %>%
      mutate(equal = human == count_response)
    ft <- cbind(original_data$id, original_data$target, original_data$response,
                ft) %>%
      setNames(c("id", "target", "response", "human", "robot", "equal"))
  } else {
    ft <- final_table %>%
      select(count_response)
    ft <- cbind(original_data$id, original_data$target, original_data$response,
                ft) %>%
      setNames(c("id", "target", "response", "robot"))
  }

  if (output == "text"){
    ft
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
