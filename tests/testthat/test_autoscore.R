
df <- autoscore::example_data
acceptable_df <- tibble::data_frame(
  target = c("model",
             "treason",
             "duck"),
  acceptable_response = c("modal, moddel",
                          "treeson",
                          "dock")
)

testthat::expect_error(autoscore::autoscore(df, acceptable_df = "default"))
testthat::expect_s3_class(autoscore::autoscore(df), "data.frame")
testthat::expect_s3_class(autoscore::autoscore(df,
                                               position_rule = 1), "data.frame")
testthat::expect_s3_class(autoscore::autoscore(df,
                                               common_misspell_rule = TRUE), "data.frame")
testthat::expect_s3_class(autoscore::autoscore(df,
                                               acceptable_df = acceptable_df), "data.frame")
testthat::expect_s3_class(autoscore::autoscore(df,
                                               acceptable_df = acceptable_df,
                                               common_misspell_rule = TRUE), "data.frame")
testthat::expect_s3_class(autoscore::autoscore(df,
                                               acceptable_df = acceptable_df,
                                               common_misspell_rule = FALSE), "data.frame")
testthat::expect_s3_class(autoscore::autoscore(df,
                                               homophone_rule = FALSE,
                                               common_misspell_rule = FALSE), "data.frame")
testthat::expect_s3_class(autoscore::autoscore(df,
                                               rootword_rule = FALSE,
                                               double_letter_rule = FALSE), "data.frame")
testthat::expect_s3_class(autoscore::autoscore(df,
                                               suffix_rule = TRUE,
                                               double_letter_rule = FALSE), "data.frame")
testthat::expect_s3_class(autoscore::autoscore(df,
                                               suffix_rule = TRUE,
                                               ed_rule = TRUE,
                                               double_letter_rule = FALSE), "data.frame")
testthat::expect_s3_class(autoscore::autoscore(df,
                                               suffix_rule = TRUE,
                                               s_rule = TRUE,
                                               double_letter_rule = FALSE), "data.frame")
testthat::expect_s3_class(autoscore::autoscore(df,
                                               suffix_rule = TRUE,
                                               ed_rule = FALSE,
                                               ed_add_rule = TRUE,
                                               double_letter_rule = FALSE), "data.frame")
testthat::expect_s3_class(autoscore::autoscore(df,
                                               suffix_rule = TRUE,
                                               s_rule = FALSE,
                                               s_add_rule = TRUE,
                                               double_letter_rule = FALSE), "data.frame")



