<!-- README.md is generated from README.Rmd. Please edit that file -->
autoscore
=========

The goal of autoscore is to score the accuracy of speech perception
(often in several situations such as noise, dysarthria, hearing loss,
etc.). It uses a flexible number of rules that help decide if a response
set of words match a target set of words. Each rule can be applied or
removed in each situation to best meet the needs of the reseearcher.

The rules are:

1.  `position_rule` = how close the word has to be in the order of the
    target (e.g., `c("one", "two") with c("three", "one", "two")` has
    “one” match one position off of where it should be and same with
    “two”)
2.  `homophone_rule` = should we use homophone list (`TRUE` or `FALSE`)
3.  `stemmed_rule` = should we stem all words (i.e., remove all
    suffixes); default is `TRUE`
4.  `pasttense_rule` = -d and -ed removed (is not applied when
    `stemmed_rule` is applied); default is `TRUE`
5.  `a_the_rule` = a and the are the same
6.  `plural_rule` = remove plurals (is not applied when `stemmed_rule`
    is applied); default is `TRUE`
7.  `firstpart_rule` = embedded at beginning of word or at the end of
    the word (“bat” :: “batman”); uses a partial matching heuristic
8.  `alternate_spell_rule` = user provided alternate spellings of words
    in the target

Design
------

The API of the `R` package is simple. A single call to `autoscore()`
with the formatted data will run everything for you. This function is a
composite of several sub-functions that do various jobs:

-   `select_cols()` – The first function which takes the data and gets
    it in the right format for analysis.
-   `split_clean()` – Using the cleaned data from `select_cols()`, this
    uses `stringr` to turn the phrases into individual words.
-   `homophones_fun()` – If homophones are used (according to the
    `homophone_rule`), this function finds and normalizes all homophones
    as found in the `data(homophones)` found in this package.
-   `match_position_basic()` – This function is the workhorse of the
    package. It takes the cleaned (and possibly homophone normalized)
    data and does three main things: 1) applies all the rules except for
    the `position_rule`, 2) finds the matches between the responses and
    the targets, and 3) reports how far away the matches are from each
    other.
-   `count_matches()` – Finally, this function takes the information
    from `match_position_basic()` and counts the number of matches based
    on the `position_rule`.

Use of the Online Tool
----------------------

The online tool will be developed shortly…

Use of the R Package
--------------------

An example of the use of `autoscore` is below. We will use the example
data set provided in the package.

``` r
library(tidyverse)
#> ── Attaching packages ────────────────────────────────────────────────────────────────────────────────────────────────────── tidyverse 1.2.1.9000 ──
#> ✔ ggplot2 2.2.1.9000      ✔ purrr   0.2.5      
#> ✔ tibble  1.4.2.9004      ✔ dplyr   0.7.99.9000
#> ✔ tidyr   0.8.1           ✔ stringr 1.3.1      
#> ✔ readr   1.2.0           ✔ forcats 0.3.0
#> ── Conflicts ────────────────────────────────────────────────────────────────────────────────────────────────────────────── tidyverse_conflicts() ──
#> ✖ dplyr::filter() masks stats::filter()
#> ✖ dplyr::lag()    masks stats::lag()
library(autoscore)
#> ── autoscore 0.1.1 ─────────────────────────────────────────────────────────────────────────────────────────────── learn more at tysonbarrett.com ──
#> ✔ autoscore attached
#> ✔ No potential conflicts found

data("example_data")
example_data
#> # A tibble: 40 x 4
#>       Id Target                    Response                    human
#>    <dbl> <chr>                     <chr>                       <dbl>
#>  1     5 mate denotes a judgement  made the dinner in it           1
#>  2     5 its harmful note abounds  it's not for the bounce         1
#>  3     5 butcher in the middle     the shirt in the middle         3
#>  4     5 rampant boasting captain  rubbed against the captain      1
#>  5     5 avoid or beat command     advert the beat commend         1
#>  6     5 rocking modern poster     wrecking minor poacher          0
#>  7     5 resting older earring     resting alert hearing           1
#>  8     5 indeed a tax ascent       indeed the dash was sent        2
#>  9     5 pain can follow agents    thank for guidance              0
#> 10     5 remove and name for stake remember the name for steak     3
#> # ... with 30 more rows
```

``` r
example_data %>%
  autoscore() %>%   ## using all the defaults
  as.tibble()       ## to shorted output
#> Note: Homophones in data(homophones) were used.
#> # A tibble: 40 x 6
#>       id target                 response                 human robot equal
#>    <dbl> <fct>                  <fct>                    <dbl> <int> <lgl>
#>  1     5 mate denotes a judgem… made the dinner in it        1     1 TRUE 
#>  2     5 its harmful note abou… it's not for the bounce      1     1 TRUE 
#>  3     5 butcher in the middle  the shirt in the middle      3     4 FALSE
#>  4     5 rampant boasting capt… rubbed against the capt…     1     1 TRUE 
#>  5     5 avoid or beat command  advert the beat commend      1     1 TRUE 
#>  6     5 rocking modern poster  wrecking minor poacher       0     0 TRUE 
#>  7     5 resting older earring  resting alert hearing        1     1 TRUE 
#>  8     5 indeed a tax ascent    indeed the dash was sent     2     2 TRUE 
#>  9     5 pain can follow agents thank for guidance           0     0 TRUE 
#> 10     5 remove and name for s… remember the name for s…     3     3 TRUE 
#> # ... with 30 more rows
```

``` r
devtools::session_info()
#> Session info -------------------------------------------------------------
#>  setting  value                       
#>  version  R version 3.5.0 (2018-04-23)
#>  system   x86_64, darwin15.6.0        
#>  ui       X11                         
#>  language (EN)                        
#>  collate  en_US.UTF-8                 
#>  tz       America/Denver              
#>  date     2018-07-27
```
