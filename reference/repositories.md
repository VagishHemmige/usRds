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
- **Inspected:** [cohort file, complete](https://github.com/acmilannesta/Adult_readmission/blob/4dae56c097258517c95b13907af4fef1db0b7e9e/cohort%20medicare%20index%20hospital.103117.sas); [derived-variables file](https://github.com/acmilannesta/Adult_readmission/blob/4dae56c097258517c95b13907af4fef1db0b7e9e/derive%20new%20variables.06212018.sas),
  lines 150–205 and 430–490 only. Source only.
- **Context:** SAS, 2016 SAF; readmission after first adult kidney transplant, 2005–2013.
- **Operational choices:**
  - Medicare primary is PAYHIST `MPAB` or `MPO` on the transplant date
    ([L23–28](https://github.com/acmilannesta/Adult_readmission/blob/4dae56c097258517c95b13907af4fef1db0b7e9e/cohort%20medicare%20index%20hospital.103117.sas#L23-L28)) and for at least 11/12 of the year before it, measured from
    the later of `FIRST_SE` and transplant date minus 365 ([L67–166](https://github.com/acmilannesta/Adult_readmission/blob/4dae56c097258517c95b13907af4fef1db0b7e9e/cohort%20medicare%20index%20hospital.103117.sas#L67-L166)).
  - `HOSP_to2009` and `HOSP_2010on` are stacked ([L45–65](https://github.com/acmilannesta/Adult_readmission/blob/4dae56c097258517c95b13907af4fef1db0b7e9e/cohort%20medicare%20index%20hospital.103117.sas#L45-L65)).
  - Charlson groups match the first 3, 4 and 5 characters of `HSDIAG1`–`HSDIAG25`
    ([L545–654](https://github.com/acmilannesta/Adult_readmission/blob/4dae56c097258517c95b13907af4fef1db0b7e9e/cohort%20medicare%20index%20hospital.103117.sas#L545-L654)).
  - Same-day duplicate claims are dropped and nested overlapping stays merged before
    counting ([L192–290](https://github.com/acmilannesta/Adult_readmission/blob/4dae56c097258517c95b13907af4fef1db0b7e9e/cohort%20medicare%20index%20hospital.103117.sas#L192-L290)); readmission counts are censored at a second
    transplant within a year ([L367–388](https://github.com/acmilannesta/Adult_readmission/blob/4dae56c097258517c95b13907af4fef1db0b7e9e/cohort%20medicare%20index%20hospital.103117.sas#L367-L388)).
  - 2728 variables from the 1995 and 2005 forms (for example `HYPER`/`COMO_HTN`,
    `MDCR`/`MEDCOV_MEDICARE`) are combined into one flag, keeping the last record per
    patient in file order ([L724–806](https://github.com/acmilannesta/Adult_readmission/blob/4dae56c097258517c95b13907af4fef1db0b7e9e/cohort%20medicare%20index%20hospital.103117.sas#L724-L806)).
  - RXGROUP is grouped as 1–3 HD and 5/7/9 PD ([L433–446](https://github.com/acmilannesta/Adult_readmission/blob/4dae56c097258517c95b13907af4fef1db0b7e9e/derive%20new%20variables.06212018.sas#L433-L446)).
- **Useful patterns:** proportion-of-time coverage rule; prefix matching on several
  code lengths; one flag across 2728 form versions.
- **Limits:** form selection depends on file order, not a date; overlap repairs
  are made by hand for named patients; arrays have fixed maximum sizes.
- **Provenance limitation:** the source hard-codes individual identifiers (values not
  reproduced). The repository tree also lists a `.sas7bdat` and CSV files with
  analysis-dataset names; they were not downloaded or opened, and their provenance
  is unknown.

## acmilannesta/dialysis_facility_kidney_tx

- **Commit:** `da97ccb20689f40a5948fd7f8a310bc01dd79603`.
- **License check:** no license file in the tree at this commit. Read for ideas; do not copy code.
- **Inspected:** [source-data step](https://github.com/acmilannesta/dialysis_facility_kidney_tx/blob/da97ccb20689f40a5948fd7f8a310bc01dd79603/Cohort%20development/Source%20Data%202017_profitstatus_Jason_10152019.sas), lines 1–190; [Step 1](https://github.com/acmilannesta/dialysis_facility_kidney_tx/blob/da97ccb20689f40a5948fd7f8a310bc01dd79603/Cohort%20development/DF_profitStatus_WL_v5_Step1_JG_Mark_Jason_10152019.sas), lines 90–150;
  [Step 2](https://github.com/acmilannesta/dialysis_facility_kidney_tx/blob/da97ccb20689f40a5948fd7f8a310bc01dd79603/Cohort%20development/DF_profitStatus_WL_v5_Step2_JG_Mark_Jason_10152019.sas), lines 60–260. Notebooks not opened.
- **Context:** SAS, 2017 SAF; dialysis facility profit status and waitlisting
  (Gander et al., JAMA Netw Open 2019).
- **Operational choices:**
  - Dialysis start is the earliest of `FIRST_SE`, `DIALDAT` and `FACSTD`
    ([L181](https://github.com/acmilannesta/dialysis_facility_kidney_tx/blob/da97ccb20689f40a5948fd7f8a310bc01dd79603/Cohort%20development/Source%20Data%202017_profitstatus_Jason_10152019.sas#L181)). 2728 forms are kept one per patient and `DIALDAT`
    ([L56–67](https://github.com/acmilannesta/dialysis_facility_kidney_tx/blob/da97ccb20689f40a5948fd7f8a310bc01dd79603/Cohort%20development/Source%20Data%202017_profitstatus_Jason_10152019.sas#L56-L67)).
  - RXDETAIL 1–9 is dialysis; RXGROUP 1–2 in-centre HD, 3 home HD, 5/7/9 PD
    ([L88–120](https://github.com/acmilannesta/dialysis_facility_kidney_tx/blob/da97ccb20689f40a5948fd7f8a310bc01dd79603/Cohort%20development/DF_profitStatus_WL_v5_Step2_JG_Mark_Jason_10152019.sas#L88-L120)).
  - Facility at the event ([L150–256](https://github.com/acmilannesta/dialysis_facility_kidney_tx/blob/da97ccb20689f40a5948fd7f8a310bc01dd79603/Cohort%20development/DF_profitStatus_WL_v5_Step2_JG_Mark_Jason_10152019.sas#L150-L256)). The event date is the earlier of
    waitlisting and transplant. The facility is the RXHIST `PROVUSRD` of a spell that
    contains the event date strictly (`BEGDATE < event < ENDDATE`, so an event on a
    spell's first or last day does not match; the author's comment flags this line).
    If the event falls after dialysis start but before the first spell, the 2728
    `PROVUSRD` is used. All other patients, including events in gaps between spells or
    after the last spell, get the facility of their last RXHIST record, whatever its
    dates. Patients without an event get their last record. A missing facility then
    falls back to the 2728 `PROVUSRD`.
  - `MEDICALCOVERAGE` combinations are collapsed as employer > Medicaid > Medicare >
    other > none ([L124–150](https://github.com/acmilannesta/dialysis_facility_kidney_tx/blob/da97ccb20689f40a5948fd7f8a310bc01dd79603/Cohort%20development/DF_profitStatus_WL_v5_Step1_JG_Mark_Jason_10152019.sas#L124-L150)).
- **Useful patterns:** an explicit insurance hierarchy; the facility question
  ("which facility on this date") made explicit.
- **Limits:** the strict boundaries and the last-record fallback are study-specific
  and can assign a facility whose spell does not contain the event; not a reusable
  rule as written. Code meanings must be checked against Appendix C; local paths throughout.

## pairs-jh/criteria

- **Commit:** `3264681c00f48ea1a1ab0c2636bcb357aedf7d66`.
- **License check:** no license file in the tree at this commit. Read for ideas; do not copy code.
- **Inspected:** [`12_benzodiazepines_expR.do`](https://github.com/pairs-jh/criteria/blob/3264681c00f48ea1a1ab0c2636bcb357aedf7d66/12_benzodiazepines_expR.do) (complete)
  and the source text of [`chapter3.ipynb`](https://github.com/pairs-jh/criteria/blob/3264681c00f48ea1a1ab0c2636bcb357aedf7d66/chapter3.ipynb) cells 21 and 24–27
  (0-based; code shown in markdown cells), without outputs. Log files, spreadsheets
  and rendered pages not opened.
- **Context:** Stata, 2015–2016 SAFs; potentially inappropriate medications and
  mortality in older incident dialysis patients.
- **Operational choices:**
  - PAYHIST spells with `MPAB`/`MPO`, first spell starting 2013–2014 (cell 21).
  - Incident in-centre patients 2013–2014, aged 65 and over; follow-up ends at
    transplant, death or 30 September 2015 (cell 24).
  - Entry requires day 91 of ESRD inside a PAYHIST spell (cell 26). Part D enrollment
    is not checked.
  - Drug classes flagged by substring match on `GNN` in yearly PDE files
    ([L5–41](https://github.com/pairs-jh/criteria/blob/3264681c00f48ea1a1ab0c2636bcb357aedf7d66/12_benzodiazepines_expR.do#L5-L41)); exposure is time-varying from each
    fill, with counting-process rows (cells 25–27).
- **Useful patterns:** counting-process rows from fill dates.
- **Limits:** 2013 and 2014 PDE files come from different SAF releases
  ([L5–7](https://github.com/pairs-jh/criteria/blob/3264681c00f48ea1a1ab0c2636bcb357aedf7d66/12_benzodiazepines_expR.do#L5-L7)); substring matching can catch
  unintended names; no Part D coverage denominator.

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
