
df <- autoscore::example_data
acceptable_df <- tibble::data_frame(
  target = c("model",
             "treason",
             "duck"),
  acceptable= c("modal, moddel",
                          "treeson",
                          "dock")
)

testthat::expect_error(autoscore::autoscore(df, acceptable_df = "default"))
testthat::expect_s3_class(autoscore::autoscore(df), "data.frame")
testthat::expect_s3_class(autoscore::autoscore(df,
                                               position_rule = 1), "data.frame")
testthat::expect_s3_class(autoscore::autoscore(df,
                                               acceptable_df = acceptable_df), "data.frame")
testthat::expect_s3_class(autoscore::autoscore(df,
                                               acceptable_df = acceptable_df,
                                               rootword_rule = TRUE), "data.frame")
testthat::expect_s3_class(autoscore::autoscore(df,
                                               rootword_rule = FALSE,
                                               double_letter_rule = FALSE), "data.frame")
testthat::expect_s3_class(autoscore::autoscore(df,
                                               suffix_rule = TRUE,
                                               double_letter_rule = FALSE), "data.frame")
testthat::expect_s3_class(autoscore::autoscore(df,
                                               suffix_rule = TRUE,
                                               tense_rule = TRUE,
                                               double_letter_rule = FALSE), "data.frame")
testthat::expect_s3_class(autoscore::autoscore(df,
                                               suffix_rule = TRUE,
                                               plural_rule = TRUE,
                                               double_letter_rule = FALSE), "data.frame")
testthat::expect_s3_class(autoscore::autoscore(df,
                                               suffix_rule = TRUE,
                                               tense_rule = FALSE,
                                               tense_add_rule = TRUE,
                                               double_letter_rule = FALSE), "data.frame")
testthat::expect_s3_class(autoscore::autoscore(df,
                                               suffix_rule = TRUE,
                                               plural_rule = FALSE,
                                               plural_add_rule = TRUE,
                                               double_letter_rule = FALSE), "data.frame")


