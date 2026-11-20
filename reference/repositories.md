# External code references

Source inspected on 2026-11-15; nothing executed. These are bounded code
annotations, not repository audits or validated epidemiologic definitions.
No data files or saved outputs were opened. Exact variable names below are
observed in source, not independently verified against release dictionaries.

## webbedfeet/USRDS2015

- **Commit:** `bcda102f430f5c0f6af32915f2582ac9448490e8`.
- **License check:** no license file identified in the complete tree at this
  commit; no permission to reuse code verified. Read for ideas; do not copy code.
- **Inspected:** [ingestion](https://github.com/webbedfeet/USRDS2015/blob/bcda102f430f5c0f6af32915f2582ac9448490e8/R/Original/Ingest_into_DB.R),
  [hospital comorbidities](https://github.com/webbedfeet/USRDS2015/blob/bcda102f430f5c0f6af32915f2582ac9448490e8/R/JASN/hospital_comorb.R),
  [event helper](https://github.com/webbedfeet/USRDS2015/blob/bcda102f430f5c0f6af32915f2582ac9448490e8/lib/R/detect_event.R).
- **Context:** R, haven, DBI/SQLite and dplyr; 2015-era SAF processing.
- **Operational choices:** SAS dates converted to character before database
  storage; hospital tables split around 2010. Selected conditions use primary
  diagnoses, while dementia searches multiple diagnosis positions in chunks of
  100,000 rows. Claims are restricted to follow-up and earliest qualifying dates.
- **Useful patterns:** push filters into a database before collection; distinguish
  diagnosis position, claim interval and patient-level index event; explicit
  treatment-history processing rather than assuming a single modality.
- **Limits:** ingestion repeatedly overwrites fixed table names; verify source
  file layout before reusing. Earliest-date ties need an explicit unit rule.
  ICD-9 patterns and midpoint dates are study choices, not general definitions.
  The event helper interprets a preconstructed treatment string, so ordering and
  code meanings must be established upstream. Local paths and writes make these
  scripts unsuitable for execution during a safe source-only review.
- **Additional source:** `R/Original/ToAnalyticData.R` at the same commit
  illustrates patient/medical-evidence joins, reduction of repeated forms,
  treatment-history sequences and competing event dates. General logic was
  inspected; nothing was executed. It aggregates BMI across forms and applies
  normalization rules, so timing and loss of within-person changes need review
  before reuse. Treatment sequences require verified ordering before string
  interpretation. Event ties are resolved by the order of conditional branches.
- **Provenance limitation:** that file also contains an individual-specific
  identifier exception of unverified provenance. Its value is not reproduced,
  associated records were not accessed, and the exception is not a reusable
  population rule.

## cxh1996108/USRDS-Project

- **Commit:** `7dcd688335dd74a12282a00801e0041bec3372f4`.
- **License check:** no license file identified in the complete tree at this
  commit; no permission to reuse code verified. Read for ideas; do not copy code.
- **Inspected:** [USRDS.py, lines 1–180](https://github.com/cxh1996108/USRDS-Project/blob/7dcd688335dd74a12282a00801e0041bec3372f4/USRDS.py#L1-L180).
- **Context:** Python/pandas/PyTorch, recurrent mortality classification from a
  preassembled longitudinal CSV. Upstream SAF construction is not shown.
- **Operational choices:** retain the last 12 records for people with at least
  12 records; encode absence of a death date as alive; construct one sequence per
  person before splitting training and testing sets.
- **Useful patterns:** split on persons rather than individual longitudinal rows;
  preserve time ordering and distinguish padding from exclusion of short histories.
- **Limits:** inspected code does not sort records before `tail(12)`, define a
  prediction horizon or censoring contract, or distinguish unknown death status
  from survival to a fixed endpoint. Non-Yes insurance entries map to zero.
  These are reasons to inspect assumptions before reuse, not evidence of a
  clinically validated prediction tool. No CSV, slides, video or outputs read.

## yuewang0120/Kernel-Estimation-of-Bivariate-Time-varying-Coefficient-Model-for-Longitudinal-Data-with-Terminal-Ev

- **Commit:** `7c0ef7e35775b78306f3ac2760e3b03349f86f4c`.
- **License check:** no license file identified in the complete tree at this
  commit; no permission to reuse code verified. Read for ideas; do not copy code.
- **Inspected:** README, complete `code/functions.R` and `code/pseudo_fit.R`
  at the cited commit; source only, nothing executed.
- **Context:** bivariate time-varying coefficient estimation for longitudinal
  claims approaching a terminal event; R with parallel workers and Rcpp.
- **Operational choices:** the application uses time since entry and time until
  death jointly, transforms daily claims as `log(daily_claim / 1000 + 1)`,
  and contrasts a preconstructed primary-cause indicator. The fitting script
  distinguishes original-data bandwidth from pseudo-data bandwidth. Cross-validation
  splits unique person IDs, keeping repeated records together; variance calculations
  aggregate weighted contributions by person. Adaptive fitting doubles bandwidth
  until the local design has full rank.
- **Useful patterns:** person-level validation folds, explicit two-clock modeling,
  and a separation between estimation, uncertainty and bandwidth selection.
- **Limits:** helpers depend on a global cluster object and internal R QR symbols;
  adaptive uncertainty fitting has no explicit maximum-bandwidth guard. The
  application requests 20 workers and loads/saves fixed paths. The transformed
  daily outcome is not raw-dollar cost, and observed time-to-death is not a
  prospective predictor available before death. Source fields are derived,
  not verified USRDS dictionary names. Numerical correctness and correspondence
  to the manuscript equations were not established by this source inspection.
- **Data provenance:** README describes supplied data as pseudo-data, but its
  generation provenance has not been independently verified; neither the RData
  input nor any saved output was opened. Readable source remains useful without
  loading those artifacts.

## acmilannesta/Adult_readmission

- **Commit:** `4dae56c097258517c95b13907af4fef1db0b7e9e`.
- **License check:** no license file in the tree at this commit. Read for ideas; do not copy code.
- **Inspected:** `cohort medicare index hospital.103117.sas` (complete) and
  `derive new variables.06212018.sas` (searched for USRDS logic); source only.
- **Context:** SAS, 2016 SAF; readmission after first adult kidney transplant, 2005–2013.
- **Operational choices:** Medicare primary means PAYHIST `MPAB` or `MPO` on the
  transplant date and for at least 11/12 of the year before it, measured from the
  later of `FIRST_SE` and transplant date minus 365. `HOSP_to2009` and `HOSP_2010on`
  are stacked; diagnoses come from `HSDIAG1`–`HSDIAG25`; Charlson groups match the
  first 3, 4 and 5 characters of each code. Same-day duplicate claims are dropped and
  nested overlapping stays merged before readmissions are counted; follow-up is censored
  at a second transplant. 2728 variables from the 1995 and 2005 forms (for example
  `HYPER`/`COMO_HTN`, `MDCR`/`MEDCOV_MEDICARE`) are combined into one flag, keeping
  the last form in file order. RXGROUP is grouped as 1–3 HD, 5/7/9 PD.
- **Useful patterns:** proportion-of-time coverage rule; prefix matching on several
  code lengths; one flag across 2728 form versions.
- **Limits:** form selection depends on file order, not a date; overlap repairs
  are made by hand for named patients. Arrays have fixed maximum sizes.
- **Provenance limitation:** the source hard-codes individual identifiers (values not
  reproduced). The repository tree also lists a `.sas7bdat` and CSV files with
  analysis-dataset names; they were not downloaded or opened, and their provenance
  is unknown.

## acmilannesta/dialysis_facility_kidney_tx

- **Commit:** `da97ccb20689f40a5948fd7f8a310bc01dd79603`.
- **License check:** no license file in the tree at this commit. Read for ideas; do not copy code.
- **Inspected:** the SAS files under `Cohort development/` (searched for USRDS logic);
  notebooks not opened.
- **Context:** SAS, 2017 SAF; dialysis facility profit status and waitlisting
  (Gander et al., JAMA Netw Open 2019).
- **Operational choices:** dialysis start is the earliest of `FIRST_SE`, `DIALDAT` and
  `FACSTD`. The facility at waitlisting or transplant is the RXHIST `PROVUSRD` of the
  spell containing the event date; before all spells, or with no RXHIST, the 2728
  `PROVUSRD`. RXDETAIL 1–9 is dialysis; RXGROUP 1–2 in-centre HD, 3 home HD, 5/7/9 PD.
  2728 forms are kept one per patient and `DIALDAT`. `MEDICALCOVERAGE` combinations are
  collapsed as employer > Medicaid > Medicare > other > none.
- **Useful patterns:** facility as a function of the event date with a documented
  fallback; an explicit insurance hierarchy.
- **Limits:** code meanings must be checked against Appendix C for the release;
  local paths throughout.

## pairs-jh/criteria

- **Commit:** `3264681c00f48ea1a1ab0c2636bcb357aedf7d66`.
- **License check:** no license file in the tree at this commit. Read for ideas; do not copy code.
- **Inspected:** `12_benzodiazepines_expR.do` and the source cells (no outputs) of
  `chapter3.ipynb`; log files, spreadsheets and rendered pages not opened.
- **Context:** Stata, 2015–2016 SAFs; potentially inappropriate medications and
  mortality in older incident dialysis patients.
- **Operational choices:** incident in-centre patients 2013–2014 aged 65 and over;
  entry requires day 91 of ESRD inside a PAYHIST `MPAB`/`MPO` spell; Part D
  enrollment is not checked. Drug classes are flagged by substring match on `GNN` in
  yearly PDE files; exposure is time-varying from each fill. Follow-up ends at
  transplant, death or 30 September 2015.
- **Useful patterns:** counting-process rows from fill dates.
- **Limits:** 2013 and 2014 PDE files come from different SAF releases; substring
  matching can catch unintended names; no Part D coverage denominator.

## onc-healthit/2021PCOR-ML-AI

- **Commit:** `9b849ba68558818d57477581253c49b9c66951c7`.
- **License check:** MIT License.
- **Inspected:** README sections on data creation; `create_data_set/` scripts
  `S1b_patients.R`, `S3c_preesrdSrceDataPre2011.R`, `create_claim_table.R`,
  `setfieldtypes.R`, `pre_esrd_pre2011_claim_variables.R`; source only.
- **Context:** R (PostgreSQL) and Python notebooks; ONC/UCSF model of death within
  90 days of dialysis start using pre-ESRD claims. Dates were shifted per patient
  for de-identification.
- **Operational choices:** SAS files converted to CSV with haven. Pre-2011 pre-ESRD
  claims are in `inc2008`–`inc2010`, with the claim type only in `HCFASAF`; the schema
  changes by year; claims before 2015 are tagged ICD-9. CSV dates are read as SAS day
  counts (origin 1960-01-01).
- **Useful patterns:** per-year schema handling; explicit column types.
- **Limits:** `DRG_CD` and `PROVUSRD` are read as numbers, which can drop leading
  zeros. A missing principal diagnosis before 2011 is imputed at random from DRG,
  a study choice. Earlier R search (2026-11-15) did not find this repository.

## Discovery scope

GitHub repository searches on 2026-11-15: `USRDS` and
`"renal" "USRDS" in:readme language:R`. Empty/unrelated results were excluded;
the `jsan4christ/USRDS2015` copy was not counted as a distinct implementation.
This is an initial source set, not an exhaustive search of code mentioning USRDS.
Follow code links in manuscript annotations to expand it without counting forks
as independent evidence.

Additional searches on 2026-11-20: GitHub code search for `USRDS`, `USRDS_ID`,
`PAYHIST`, `RXHIST`, `MEDEVID`, `HCFASAF`, `RXHIST60`, `hosp_2010on` and `FIRST_SE`
in SAS, Stata, Python, notebooks, SQL and SPSS, plus repository searches. Only the
four repositories above had USRDS code beyond those already listed. NIDDK, CDC/NCHS,
figshare and Zenodo searches found no USRDS analysis code.
