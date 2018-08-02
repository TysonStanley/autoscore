<!-- README.md is generated from README.Rmd. Please edit that file -->
    ## Loading autoscore

    ## ── autoscore 0.1.7 ─────────────────────────────────────────────────────────────────────────────────────────────── learn more at tysonbarrett.com ──
    ## ✔ autoscore attached
    ## ✔ No potential conflicts found

[![Travis-CI Build
Status](https://travis-ci.org/TysonStanley/autoscore_package.svg?branch=master)](https://travis-ci.org/TysonStanley/autoscore_package)
![](https://img.shields.io/badge/lifecycle-maturing-blue.svg)

`autoscore` <img src="man/figures/autoscore_logo.png" align="right" width="30%" height="30%" />
===============================================================================================

-   `R Package: 0.1.7`
-   `Shiny App: temporary location at https://tysonstanley.shinyapps.io/autoscore/`

The purpose of `autoscore` is to automatically score word identification
in speech perception research, such as studies involving listener
understanding of speech in background noise or disordered speech. The
program uses a flexible number of rules that determine whether a
response set of words (i.e., listener transcriptions) match a target set
of words (i.e., speech corpus). At the most basic level, Autoscore
counts words in the listener transcript as correct if they match the
words in the target phrase exactly (regardless of word order), or match
a homophone or common misspelling of the target word. Individual rules
can be applied or removed, depending on the needs of researcher and the
scoring rules of the research lab. Examples of rules available in
Autoscore include the ability to count as correct substitutions of
articles (A for The) or differences in plural or tense (adding -s or -ed
to a word). Additional rules can be added by the researcher as needed.

The rule options are categorized into either spelling rules or grammar
rules.

#### Spelling Rules

1.  `homophone_rule` = response word counted correct if it is a
    homophone of the target word; default is to use this rule
    (`default = TRUE`)
2.  `common_misspell_rule` = use a default list of [common
    misspellings](https://en.wikipedia.org/wiki/Wikipedia:Lists_of_common_misspellings/For_machines)
    to be scored as correct; `default = TRUE`
3.  `acceptable_spell_rule` = use a researcher uploaded acceptable
    spelling list to be scored as correct; this rule is triggered when
    the researcher provides a data file
4.  `stemmed_rule` = stem all words (i.e., remove all suffixes);
    `default is TRUE`
5.  `rootword_rule` = response word counted correct if the target word
    (e.g., bat, day) is embedded at either the beginning (e.g., batman)
    or end (e.g., monday) of the word; uses a partial matching
    heuristic; `default is FALSE`
6.  `double_letter_rule` = should double letters within words be
    considered the same as if there was only one? E.g., “attack” is a
    match with “atack”; `default = TRUE`

#### Grammar Rules

1.  `pasttense_rule` = response word counted correct if it differs from
    the target word only by tense; `default is TRUE`
2.  `a_the_rule` = substitutions between “a” and “the” to be scored as
    correct; `default is TRUE`
3.  `plural_rule` = response word counted correct if it differs from the
    target word only by plurality; `default is TRUE`

Design
------

The API of the `R` package is simple. A single call to `autoscore()`
with the formatted data will run everything for you. This function is a
composite of several sub-functions that do various jobs:

-   `select_cols()` – The first function which takes the data and gets
    it in the right format for analysis.
-   `split_clean()` – Using the cleaned data from `select_cols()`, this
    uses `stringr` to turn the phrases into individual words.
-   `alternate_fun()` – If a data.frame of alternate spellings is
    provided, this function will find and normalize all alternate
    spellings to match the original spelling as defined by the
    researcher.
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

Visit <https://tysonstanley.shinyapps.io/autoscore/> to use the online
tool. Instructions for its use are found there.

<img src="man/figures/online_autoscore_snapshot.png" align="center" width="70%" height="70%" />

Use of the R Package
--------------------

To install the package use the developmental version as it is not yet on
CRAN.

``` r
devtools::install_github("tysonstanley/autoscore_package")
```

An example of the use of `autoscore` is below. We will use the example
data set provided in the package.

``` r
library(tidyverse)
#> ── Attaching packages ────────────────────────────────────────────────────────────────────────────────────────────────────── tidyverse 1.2.1.9000 ──
#> ✔ ggplot2 2.2.1.9000      ✔ purrr   0.2.5      
#> ✔ tibble  1.4.2.9005      ✔ dplyr   0.7.99.9000
#> ✔ tidyr   0.8.1           ✔ stringr 1.3.1      
#> ✔ readr   1.2.0           ✔ forcats 0.3.0
#> ── Conflicts ────────────────────────────────────────────────────────────────────────────────────────────────────────────── tidyverse_conflicts() ──
#> ✖ dplyr::filter() masks stats::filter()
#> ✖ dplyr::lag()    masks stats::lag()
library(autoscore)

data("example_data")
example_data
#> # A tibble: 40 x 4
#>       Id Target                      Response                    human
#>    <dbl> <chr>                       <chr>                       <dbl>
#>  1     1 mate denotes a judgement    made the dinner in it           1
#>  2     1 rampant boasting captain    rubbed against the captain      1
#>  3     1 resting older earring       resting alert hearing           1
#>  4     1 bolder ground from justice  boulder down from dresses       2
#>  5     1 remove and name for stake   remember the name for steak     3
#>  6     1 done with finest handle     dinner finished handle          1
#>  7     1 support with dock and cheer she put the duck in chair       1
#>  8     1 or spent sincere aside      earth bent spent her aside      2
#>  9     1 account for who could knock i can for hookah knock          2
#> 10     1 connect the beer device     connected beard kindle bus      1
#> # ... with 30 more rows
```

First, let’s use all the defaults and look at the first 10 rows of the
output.

``` r
example_data %>%
  autoscore() %>%   ## using all the defaults
  as.tibble()       ## to shorted output
#> # A tibble: 40 x 6
#>       id target                response              human autoscore equal
#>    <dbl> <fct>                 <fct>                 <dbl>     <int> <lgl>
#>  1     1 mate denotes a judge… made the dinner in it     1         1 TRUE 
#>  2     1 rampant boasting cap… rubbed against the c…     1         1 TRUE 
#>  3     1 resting older earring resting alert hearing     1         1 TRUE 
#>  4     1 bolder ground from j… boulder down from dr…     2         2 TRUE 
#>  5     1 remove and name for … remember the name fo…     3         3 TRUE 
#>  6     1 done with finest han… dinner finished hand…     1         1 TRUE 
#>  7     1 support with dock an… she put the duck in …     1         0 FALSE
#>  8     1 or spent sincere asi… earth bent spent her…     2         2 TRUE 
#>  9     1 account for who coul… i can for hookah kno…     2         2 TRUE 
#> 10     1 connect the beer dev… connected beard kind…     1         1 TRUE 
#> # ... with 30 more rows
```

Next, let’s change some of the rules.

``` r
example_data %>%
  autoscore(position_rule = 2, stemmed_rule = FALSE, plurals_rule = FALSE) %>%
  as.tibble()
#> # A tibble: 40 x 6
#>       id target                response              human autoscore equal
#>    <dbl> <fct>                 <fct>                 <dbl>     <int> <lgl>
#>  1     1 mate denotes a judge… made the dinner in it     1         1 TRUE 
#>  2     1 rampant boasting cap… rubbed against the c…     1         1 TRUE 
#>  3     1 resting older earring resting alert hearing     1         1 TRUE 
#>  4     1 bolder ground from j… boulder down from dr…     2         2 TRUE 
#>  5     1 remove and name for … remember the name fo…     3         3 TRUE 
#>  6     1 done with finest han… dinner finished hand…     1         1 TRUE 
#>  7     1 support with dock an… she put the duck in …     1         0 FALSE
#>  8     1 or spent sincere asi… earth bent spent her…     2         2 TRUE 
#>  9     1 account for who coul… i can for hookah kno…     2         2 TRUE 
#> 10     1 connect the beer dev… connected beard kind…     1         1 TRUE 
#> # ... with 30 more rows
```

We can also change the output type to “none” to get all the data from
the computation.

``` r
example_data %>%
  autoscore(output = "none")
#> # A tibble: 40 x 12
#>       id target response human homophone_target homophone_respo…
#>    <dbl> <list> <list>   <dbl> <list>           <list>          
#>  1     1 <chr … <chr [5…     1 <chr [4]>        <chr [5]>       
#>  2     1 <chr … <chr [4…     1 <chr [3]>        <chr [4]>       
#>  3     1 <chr … <chr [3…     1 <chr [3]>        <chr [3]>       
#>  4     1 <chr … <chr [4…     2 <chr [4]>        <chr [4]>       
#>  5     1 <chr … <chr [5…     3 <chr [5]>        <chr [5]>       
#>  6     1 <chr … <chr [3…     1 <chr [4]>        <chr [3]>       
#>  7     1 <chr … <chr [6…     1 <chr [5]>        <chr [6]>       
#>  8     1 <chr … <chr [5…     2 <chr [4]>        <chr [5]>       
#>  9     1 <chr … <chr [5…     2 <chr [5]>        <chr [5]>       
#> 10     1 <chr … <chr [4…     1 <chr [4]>        <chr [4]>       
#> # ... with 30 more rows, and 6 more variables: diff_target_pre <list>,
#> #   diff_response_pre <list>, diff_target <list>, diff_response <list>,
#> #   count_target <int>, count_response <int>
```

To use the acceptable spelling rule, let’s create a small `data.frame`
that we can provide `autoscore()`. In the data frame below, the target
spellings are the generally accepted spellings that are in the target
list of words while the acceptable\_response spellings are those that
should also be counted as correct.

``` r
acceptable_df <- data_frame(
  target = c("model",
             "treason",
             "duck"),
  acceptable_response = c("modal, moddel",
                          "treeson",
                          "dock")
)
acceptable_df
#> # A tibble: 3 x 2
#>   target  acceptable_response
#>   <chr>   <chr>              
#> 1 model   modal, moddel      
#> 2 treason treeson            
#> 3 duck    dock
```

Using this, we can provide it to the `autoscore()` function with the
`acceptable_df` argument.

``` r
example_data %>%
  autoscore::autoscore(acceptable_df = acceptable_df) %>%
  as.tibble()
#> # A tibble: 40 x 6
#>       id target                response              human autoscore equal
#>    <dbl> <fct>                 <fct>                 <dbl>     <int> <lgl>
#>  1     1 mate denotes a judge… made the dinner in it     1         1 TRUE 
#>  2     1 rampant boasting cap… rubbed against the c…     1         1 TRUE 
#>  3     1 resting older earring resting alert hearing     1         1 TRUE 
#>  4     1 bolder ground from j… boulder down from dr…     2         2 TRUE 
#>  5     1 remove and name for … remember the name fo…     3         3 TRUE 
#>  6     1 done with finest han… dinner finished hand…     1         1 TRUE 
#>  7     1 support with dock an… she put the duck in …     1         1 TRUE 
#>  8     1 or spent sincere asi… earth bent spent her…     2         2 TRUE 
#>  9     1 account for who coul… i can for hookah kno…     2         2 TRUE 
#> 10     1 connect the beer dev… connected beard kind…     1         1 TRUE 
#> # ... with 30 more rows
```

We can also say `common_misspell_rule = TRUE` in conjunction with
`acceptable_df = acceptable_df` if we want to use the list of 4,268
common misspellings in addition to the user provided list.

``` r
example_data %>%
  autoscore::autoscore(acceptable_df = acceptable_df,
                       common_misspell_rule = TRUE) %>%
  as.tibble()
#> # A tibble: 40 x 6
#>       id target                response              human autoscore equal
#>    <dbl> <fct>                 <fct>                 <dbl>     <int> <lgl>
#>  1     1 mate denotes a judge… made the dinner in it     1         1 TRUE 
#>  2     1 rampant boasting cap… rubbed against the c…     1         1 TRUE 
#>  3     1 resting older earring resting alert hearing     1         1 TRUE 
#>  4     1 bolder ground from j… boulder down from dr…     2         2 TRUE 
#>  5     1 remove and name for … remember the name fo…     3         3 TRUE 
#>  6     1 done with finest han… dinner finished hand…     1         1 TRUE 
#>  7     1 support with dock an… she put the duck in …     1         1 TRUE 
#>  8     1 or spent sincere asi… earth bent spent her…     2         2 TRUE 
#>  9     1 account for who coul… i can for hookah kno…     2         2 TRUE 
#> 10     1 connect the beer dev… connected beard kind…     1         1 TRUE 
#> # ... with 30 more rows
```

If the researcher doesn’t have a list of words, we can just use the
common misspell rule.

``` r
example_data %>%
  autoscore::autoscore(common_misspell_rule = TRUE) %>%
  as.tibble()
#> # A tibble: 40 x 6
#>       id target                response              human autoscore equal
#>    <dbl> <fct>                 <fct>                 <dbl>     <int> <lgl>
#>  1     1 mate denotes a judge… made the dinner in it     1         1 TRUE 
#>  2     1 rampant boasting cap… rubbed against the c…     1         1 TRUE 
#>  3     1 resting older earring resting alert hearing     1         1 TRUE 
#>  4     1 bolder ground from j… boulder down from dr…     2         2 TRUE 
#>  5     1 remove and name for … remember the name fo…     3         3 TRUE 
#>  6     1 done with finest han… dinner finished hand…     1         1 TRUE 
#>  7     1 support with dock an… she put the duck in …     1         0 FALSE
#>  8     1 or spent sincere asi… earth bent spent her…     2         2 TRUE 
#>  9     1 account for who coul… i can for hookah kno…     2         2 TRUE 
#> 10     1 connect the beer dev… connected beard kind…     1         1 TRUE 
#> # ... with 30 more rows
```

In each of these examples, it is clear that the human and “autoscore”
agree the majority of the time. The times that they disagree, it is
usually predictably a human error or a subjective judgement that the
researcher will have to consider (for example by including alternate
spellings of words as we just demonstrated).

### Learn More

Publications are forthcoming. For more information, contact Tyson S.
Barrett (<t.barrett@aggiemail.usu.edu>).
