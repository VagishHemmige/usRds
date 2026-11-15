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

## Discovery scope

GitHub repository searches on 2026-11-15: `USRDS` and
`"renal" "USRDS" in:readme language:R`. Empty/unrelated results were excluded;
the `jsan4christ/USRDS2015` copy was not counted as a distinct implementation.
This is an initial source set, not an exhaustive search of code mentioning USRDS.
Follow code links in manuscript annotations to expand it without counting forks
as independent evidence.
