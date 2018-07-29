
df <- autoscore::example_data
alternate_df <- data_frame(
  original = c("model",
               "treason",
               "duck"),
  alternate = c("modal, moddel",
                "treeson",
                "dock")
)

testthat::expect_error(autoscore::autoscore(df, alternate_df = "default"))
testthat::expect_s3_class(autoscore::autoscore(df), "data.frame")
testthat::expect_s3_class(autoscore::autoscore(df,
                                               position_rule = 1), "data.frame")
testthat::expect_s3_class(autoscore::autoscore(df,
                                               common_misspell_rule = TRUE), "data.frame")
testthat::expect_s3_class(autoscore::autoscore(df,
                                               alternate_df = alternate_df), "data.frame")
testthat::expect_s3_class(autoscore::autoscore(df,
                                               alternate_df = alternate_df,
                                               common_misspell_rule = TRUE), "data.frame")
testthat::expect_s3_class(autoscore::autoscore(df,
                                               alternate_df = alternate_df,
                                               common_misspell_rule = FALSE), "data.frame")
testthat::expect_s3_class(autoscore::autoscore(df,
                                               homophone_rule = FALSE,
                                               common_misspell_rule = FALSE), "data.frame")
