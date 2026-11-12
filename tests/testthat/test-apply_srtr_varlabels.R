test_that("apply_srtr_varlabels() labels variables from the sRtr dictionary", {
  skip_if_not_installed("sRtr")
  df <- data.frame(can_abo = "A", OTHER = 1)

  result <- apply_srtr_varlabels(df, dataset_key = "CAND_KIPA")

  expect_equal(labelled::var_label(result$can_abo), "Patient/s Blood Type")
  expect_null(labelled::var_label(result$OTHER))
})

test_that("apply_srtr_varlabels() explains how to get sRtr when it is missing", {
  local_mocked_bindings(.srtr_available = function() FALSE)

  expect_error(
    apply_srtr_varlabels(data.frame(CAN_ABO = "A"), dataset_key = "CAND_KIPA"),
    class = "usRds_error_missing_srtr"
  )
})
