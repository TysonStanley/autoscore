## Utilities for the package

## Read in and select the appropriate columns for the analysis
select_cols <- function(d){
  d <- d %>%
    dplyr::select(contains("[I|i][D|d]"), contains("[T|t]arget"), contains("[R|r]esponse"), contains("[H|h]uman")) %>%
    dplyr::rename_all(tolower)

  if (ncols(d) > 4){
    stop("More than 4 columns were selected containing 'id', 'target', 'response', or 'human'", call. = FALSE)
  } else if (ncols(d) < 3){
    stop(paste0("Less than 3 columns were selected containing 'id', 'target', 'response', or 'human'\n",
                   " - One column should be named 'id', another named 'target', another named 'response', and",
                   "optionally one named 'human'. Check your CSV to upload again."), call. = FALSE)
  }

  d
}

format_output <- function(final_table) {



}





#' if helper operator
#'
#' @name %||%
#' @rdname if_operator
#' @export
`%||%` <- function(lhs, rhs) {
  if (!is.null(lhs)) {
    lhs
  } else {
    rhs
  }
}


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
  furniture_conflicts <- confs$`package:autoscore`

  ## Find which packages have those functions that are conflicted
  if (length(furniture_conflicts) != 0){
    other_conflicts <- list()
    for (i in furniture_conflicts){
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
