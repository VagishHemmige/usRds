# Amount columns returned by the four cost extractors, with the kind of
# amount each one holds. prorate_costs_by_day() and
# adjust_costs_for_inflation() both read this list, so a column added to an
# extractor needs adding here too (#31).
#
# Sources: 2025 Researcher's Guide, Section 5 (Medicare Claims), "Medicare
# Payment Variables" and "REV_CH"; 2025 Appendix B, tables PS_CLM_2023,
# PS_LINE_2023, IP_CLM_2023 and OP_DET_2023.
.usrds_cost_columns <- data.frame(
  column = c(
    # get_PS_CLM_costs()
    "CLM_PMT_AMT",
    "CARR_CLM_PRMRY_PYR_PD_AMT",
    "NCH_CLM_PRVDR_PMT_AMT",
    "NCH_CLM_BENE_PMT_AMT",
    "NCH_CARR_SBMT_CHRG_AMT",
    "NCH_CARR_ALOW_CHRG_AMT",
    "CARR_CLM_CASH_DDCTBL_APPLY_AMT",
    # get_IN_CLM_costs()
    "CLM_TOT",
    "CLM_AMT",
    # get_PS_REV_costs()
    "SBMTCH",
    "ALOWCH",
    "PMTAMT",
    # get_IN_REV_costs()
    "REV_CH",
    "REVPMT"
  ),
  measure = c(
    "payment",
    "payment",
    "payment",
    "payment",
    "charge",
    "charge",
    "deductible",
    "charge",
    "payment",
    "charge",
    "charge",
    "payment",
    "charge",
    "payment"
  ),
  extractor = c(
    rep("get_PS_CLM_costs", 7),
    rep("get_IN_CLM_costs", 2),
    rep("get_PS_REV_costs", 3),
    rep("get_IN_REV_costs", 2)
  )
)

# The amount columns a function should process: the extractor columns plus
# the same columns already carrying `suffix` (for example "_ADJUSTED" when
# prorating, so the two steps work in either order).
.usrds_cost_column_names <- function(suffix) {
  base <- .usrds_cost_columns$column
  c(base, paste0(base, suffix))
}
