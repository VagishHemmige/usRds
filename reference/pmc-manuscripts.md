# USRDS manuscript collection

**100 unique manuscripts: complete main-prose reads and original annotations, 2026-11-15.**
This is the assembled collection across 17 companion batch PRs, not a claim that
all branches have merged or that independent review is complete. Main-prose reading
does not establish comprehensive table, figure-image, equation or supplement review.
Individual notes record those limits and selected additional inspections.

Each batch owns different files. This catalog is maintained in the foundation PR
[#56](https://github.com/VagishHemmige/usRds/pull/56); coding/review pointers and package-build exclusion are in
[#61](https://github.com/VagishHemmige/usRds/pull/61). Merge those together before the other
batches. Relative links to companion files resolve once those branches are assembled;
until then, use the batch PR links below. No merges were performed by this task.

## Batch map

| Batch | Manuscripts | PR |
|---|---:|---|
| [Batch 01](manuscript-batches/batch-01.md) | 5 | [#56](https://github.com/VagishHemmige/usRds/pull/56) |
| [Batch 02](manuscript-batches/batch-02.md) | 6 | [#57](https://github.com/VagishHemmige/usRds/pull/57) |
| [Batch 03](manuscript-batches/batch-03.md) | 6 | [#58](https://github.com/VagishHemmige/usRds/pull/58) |
| [Batch 04](manuscript-batches/batch-04.md) | 6 | [#59](https://github.com/VagishHemmige/usRds/pull/59) |
| [Batch 05](manuscript-batches/batch-05.md) | 6 | [#62](https://github.com/VagishHemmige/usRds/pull/62) |
| [Batch 06](manuscript-batches/batch-06.md) | 6 | [#63](https://github.com/VagishHemmige/usRds/pull/63) |
| [Batch 07](manuscript-batches/batch-07.md) | 6 | [#64](https://github.com/VagishHemmige/usRds/pull/64) |
| [Batch 08](manuscript-batches/batch-08.md) | 6 | [#67](https://github.com/VagishHemmige/usRds/pull/67) |
| [Batch 09](manuscript-batches/batch-09.md) | 6 | [#68](https://github.com/VagishHemmige/usRds/pull/68) |
| [Batch 10](manuscript-batches/batch-10.md) | 6 | [#69](https://github.com/VagishHemmige/usRds/pull/69) |
| [Batch 11](manuscript-batches/batch-11.md) | 6 | [#70](https://github.com/VagishHemmige/usRds/pull/70) |
| [Batch 12](manuscript-batches/batch-12.md) | 6 | [#71](https://github.com/VagishHemmige/usRds/pull/71) |
| [Batch 13](manuscript-batches/batch-13.md) | 6 | [#72](https://github.com/VagishHemmige/usRds/pull/72) |
| [Batch 14](manuscript-batches/batch-14.md) | 6 | [#73](https://github.com/VagishHemmige/usRds/pull/73) |
| [Batch 15](manuscript-batches/batch-15.md) | 6 | [#74](https://github.com/VagishHemmige/usRds/pull/74) |
| [Batch 16](manuscript-batches/batch-16.md) | 6 | [#75](https://github.com/VagishHemmige/usRds/pull/75) |
| [Batch 17](manuscript-batches/batch-17.md) | 5 | [#76](https://github.com/VagishHemmige/usRds/pull/76) |

## Selection and provenance

Europe PMC search on 2026-11-15:

```text
(ABSTRACT:USRDS OR ABSTRACT:"United States Renal Data System" OR ABSTRACT:"US Renal Data System") AND IN_PMC:y
```

Endpoint: `https://www.ebi.ac.uk/europepmc/webservices/rest/search`, JSON, `resultType=core`, `pageSize=200`; subsequent page uses the returned cursor. The initial query reported 769 hits. Selection is purposive for data construction, validation, claims, coverage, costs, drug exposures, transplantation, geography and longitudinal methods; it is not a systematic review. Search relevance ordering can change.

Exclude incidental USRDS mentions, reviews, editorials and conference abstracts from the target. Substitute a substantively relevant original study when full text cannot be obtained after reasonable attempts; record the actual selected papers rather than padding the count with unread entries. Different source roles (direct analysis, linkage, validation, methods application) are stated in each note.

Full-text routes include the NCBI PMC and Europe PMC article links in each batch. NCBI BioC XML was used for most main-text reads:

```text
https://www.ncbi.nlm.nih.gov/research/bionlp/RESTful/pmcoa.cgi/BioC_xml/{PMCID}/unicode
```

The initial retrieval pass encountered HTTP 429 responses, timeouts and responses without article XML. These are route-specific failures, not proof that a manuscript is unavailable. No unread candidate is represented as a completed annotation. Full-text article copies are not stored here.

## How to use the notes

Use [README.md](README.md) for the annotation scheme. Verify consequential scientific choices against the original source and the appropriate USRDS release. The notes do not validate package functions or establish package defaults. A study may omit exact file names, code lists, payment fields or temporal rules; these omissions remain explicit instead of being filled with guessed mappings.

## Complete manuscript index

Year is Europe PMC `pubYear`. MT means complete main prose; MT+T records additional
table/caption inspection as qualified in the note. These labels describe reading,
not methodological endorsement. Different articles may share study populations.

| Batch | Manuscript | Year | Annotation | Europe PMC |
|---|---|---|---|---|
| 01  [Accurate Medication Adherence Measurement Using Administrative Data for Frequently Hospitalized Patients.](https://pmc.ncbi.nlm.nih.gov/articles/PMC8554601/) | 2021 | [PMC8554601 — MT+T](manuscripts/PMC8554601.md) | [Full text](https://europepmc.org/articles/PMC8554601) |
| 01  [Validation of Antineutrophil Cytoplasmic Antibody-Associated Vasculitis as the Cause of End-Stage Renal Disease in the US Renal Data System.](https://pmc.ncbi.nlm.nih.gov/articles/PMC8754012/) | 2022 | [PMC8754012 — MT](manuscripts/PMC8754012.md) | [Full text](https://europepmc.org/articles/PMC8754012) |
| 01  [Data concordance between ESRD Medical Evidence Report and Medicare claims: is there any improvement?](https://pmc.ncbi.nlm.nih.gov/articles/PMC6065459/) | 2018 | [PMC6065459 — MT](manuscripts/PMC6065459.md) | [Full text](https://europepmc.org/articles/PMC6065459) |
| 01  [Kidney Failure Attributed to Immunoglobulin A Nephropathy: A USRDS Retrospective Cohort Study of Epidemiology, Treatment Modalities, and Economic Burden.](https://pmc.ncbi.nlm.nih.gov/articles/PMC10818081/) | 2024 | [PMC10818081 — MT](manuscripts/PMC10818081.md) | [Full text](https://europepmc.org/articles/PMC10818081) |
| 01  [Medications associated with restless legs syndrome: a case-control study in the US Renal Data System (USRDS).](https://pmc.ncbi.nlm.nih.gov/articles/PMC4172448/) | 2014 | [PMC4172448 — MT](manuscripts/PMC4172448.md) | [Full text](https://europepmc.org/articles/PMC4172448) |
| 02  [Kidney failure outcomes in children and young adults with sickle cell disease in the United States Renal Data System.](https://pmc.ncbi.nlm.nih.gov/articles/PMC10752499/) | 2024 | [PMC10752499 — MT](manuscripts/PMC10752499.md) | [Full text](https://europepmc.org/articles/PMC10752499) |
| 02  [Rurality of patient residence and access to transplantation among children with kidney failure in the United States.](https://pmc.ncbi.nlm.nih.gov/articles/PMC10899312/) | 2024 | [PMC10899312 — MT](manuscripts/PMC10899312.md) | [Full text](https://europepmc.org/articles/PMC10899312) |
| 02  [Transplantation and Mortality in Women After Delivering on Hemodialysis.](https://pmc.ncbi.nlm.nih.gov/articles/PMC12989834/) | 2026 | [PMC12989834 — MT](manuscripts/PMC12989834.md) | [Full text](https://europepmc.org/articles/PMC12989834) |
| 02  [Kidney Failure in Persons With Cystic Fibrosis.](https://pmc.ncbi.nlm.nih.gov/articles/PMC13068536/) | 2026 | [PMC13068536 — MT](manuscripts/PMC13068536.md) | [Full text](https://europepmc.org/articles/PMC13068536) |
| 02  [Claims-Based Phenotyping of Acute Kidney Transplant Rejection in a National Medicare Cohort.](https://pmc.ncbi.nlm.nih.gov/articles/PMC13677584/) | 2026 | [PMC13677584 — MT](manuscripts/PMC13677584.md) | [Full text](https://europepmc.org/articles/PMC13677584) |
| 02  [Primary care use and kidney transplant outcomes among patients on hemodialysis - a cohort study.](https://pmc.ncbi.nlm.nih.gov/articles/PMC13715090/) | 2026 | [PMC13715090 — MT](manuscripts/PMC13715090.md) | [Full text](https://europepmc.org/articles/PMC13715090) |
| 03  [Sleep apnea in end-stage renal disease patients: Impact on cardiovascular and neurological outcomes.](https://pmc.ncbi.nlm.nih.gov/articles/PMC10947737/) | 2024 | [PMC10947737 — MT](manuscripts/PMC10947737.md) | [Full text](https://europepmc.org/articles/PMC10947737) |
| 03  [Nationwide trends and outcomes of percutaneous coronary intervention for stable ischemic heart disease in end-stage kidney disease: a longitudinal study.](https://pmc.ncbi.nlm.nih.gov/articles/PMC11729801/) | 2024 | [PMC11729801 — MT](manuscripts/PMC11729801.md) | [Full text](https://europepmc.org/articles/PMC11729801) |
| 03  [Efficacy of Implantable Cardioverter-defibrillators for Secondary Prevention of Sudden Cardiac Death in Patients with End-stage Renal Disease.](https://pmc.ncbi.nlm.nih.gov/articles/PMC7452739/) | 2020 | [PMC7452739 — MT](manuscripts/PMC7452739.md) | [Full text](https://europepmc.org/articles/PMC7452739) |
| 03  [Kidney transplant program waitlisting rate as a metric to assess transplant access.](https://pmc.ncbi.nlm.nih.gov/articles/PMC7980228/) | 2021 | [PMC7980228 — MT](manuscripts/PMC7980228.md) | [Full text](https://europepmc.org/articles/PMC7980228) |
| 03  [Development of a feasible and portable electronic flag for near-real-time identification of renal replacement therapy in the Veterans Health Administration.](https://pmc.ncbi.nlm.nih.gov/articles/PMC12571676/) | 2025 | [PMC12571676 — MT](manuscripts/PMC12571676.md) | [Full text](https://europepmc.org/articles/PMC12571676) |
| 03  [Prevalence of potentially inappropriately prescribed medications among older adults receiving peritoneal dialysis.](https://pmc.ncbi.nlm.nih.gov/articles/PMC11998892/) | 2025 | [PMC11998892 — MT](manuscripts/PMC11998892.md) | [Full text](https://europepmc.org/articles/PMC11998892) |
| 04  [Incidence, risk factors and distribution of syphilis in the end-stage renal disease population in the USA.](https://pmc.ncbi.nlm.nih.gov/articles/PMC7467576/) | 2020 | [PMC7467576 — MT](manuscripts/PMC7467576.md) | [Full text](https://europepmc.org/articles/PMC7467576) |
| 04  [Costs in the Year Following Deceased Donor Kidney Transplantation: Relationships With Renal Function and Graft Failure.](https://pmc.ncbi.nlm.nih.gov/articles/PMC9184448/) | 2022 | [PMC9184448 — MT](manuscripts/PMC9184448.md) | [Full text](https://europepmc.org/articles/PMC9184448) |
| 04  [Validation of Systemic Lupus Erythematosus Diagnosis as the Primary Cause of Renal Failure in the US Renal Data System.](https://pmc.ncbi.nlm.nih.gov/articles/PMC5219868/) | 2017 | [PMC5219868 — MT](manuscripts/PMC5219868.md) | [Full text](https://europepmc.org/articles/PMC5219868) |
| 04  [Prognostic Value of Hospital Frailty Risk Score and Clinical Outcomes in Critical Limb-Threatening Ischemia and End-Stage Kidney Disease.](https://pmc.ncbi.nlm.nih.gov/articles/PMC11935674/) | 2024 | [PMC11935674 — MT](manuscripts/PMC11935674.md) | [Full text](https://europepmc.org/articles/PMC11935674) |
| 04  [Association Between Time Spent With Low Posttransplant Glomerular Filtration Rate and Access to Relisting and Retransplantation.](https://pmc.ncbi.nlm.nih.gov/articles/PMC13096997/) | 2026 | [PMC13096997 — MT](manuscripts/PMC13096997.md) | [Full text](https://europepmc.org/articles/PMC13096997) |
| 04  [Mortality in Living Kidney Donors With ESRD: A Propensity Score Analysis Using the United States Renal Data System.](https://pmc.ncbi.nlm.nih.gov/articles/PMC6127411/) | 2018 | [PMC6127411 — MT](manuscripts/PMC6127411.md) | [Full text](https://europepmc.org/articles/PMC6127411) |
| 05  [Kidney transplant access for children and young adults with congenital anomalies of the kidney and urinary tract.](https://pmc.ncbi.nlm.nih.gov/articles/PMC10185613/) | 2023 | [PMC10185613 — MT](manuscripts/PMC10185613.md) | [Full text](https://europepmc.org/articles/PMC10185613) |
| 05  [Sex Differences in Cardiovascular Outcomes in Patients With Kidney Failure.](https://pmc.ncbi.nlm.nih.gov/articles/PMC11179932/) | 2024 | [PMC11179932 — MT](manuscripts/PMC11179932.md) | [Full text](https://europepmc.org/articles/PMC11179932) |
| 05  [Repeat Transplantation Rate of Patients Receiving Dialysis After Allograft Nephrectomy.](https://pmc.ncbi.nlm.nih.gov/articles/PMC12768901/) | 2026 | [PMC12768901 — MT](manuscripts/PMC12768901.md) | [Full text](https://europepmc.org/articles/PMC12768901) |
| 05  [Assessing Predictors of Early and Late Hospital Readmission After Kidney Transplantation.](https://pmc.ncbi.nlm.nih.gov/articles/PMC6708631/) | 2019 | [PMC6708631 — MT](manuscripts/PMC6708631.md) | [Full text](https://europepmc.org/articles/PMC6708631) |
| 05  [Predictors of kidney function recovery among incident ESRD patients.](https://pmc.ncbi.nlm.nih.gov/articles/PMC8059163/) | 2021 | [PMC8059163 — MT](manuscripts/PMC8059163.md) | [Full text](https://europepmc.org/articles/PMC8059163) |
| 05  [New-Onset Gout as an Independent Risk Factor for Returning to Dialysis After Kidney Transplantation.](https://pmc.ncbi.nlm.nih.gov/articles/PMC7673774/) | 2020 | [PMC7673774 — MT](manuscripts/PMC7673774.md) | [Full text](https://europepmc.org/articles/PMC7673774) |
| 06  [The Marginal Cost of Frailty Among Medicare Patients on Hemodialysis.](https://pmc.ncbi.nlm.nih.gov/articles/PMC7056859/) | 2020 | [PMC7056859 — MT](manuscripts/PMC7056859.md) | [Full text](https://europepmc.org/articles/PMC7056859) |
| 06  [Kidney Failure and ESRD in the Atherosclerosis Risk in Communities (ARIC) Study: Comparing Ascertainment of Treated and Untreated Kidney Failure in a Cohort Study.](https://pmc.ncbi.nlm.nih.gov/articles/PMC4516566/) | 2015 | [PMC4516566 — MT](manuscripts/PMC4516566.md) | [Full text](https://europepmc.org/articles/PMC4516566) |
| 06  [Confounders of mortality and hospitalization rate calculations for profit and nonprofit dialysis facilities: analytic augmentation.](https://pmc.ncbi.nlm.nih.gov/articles/PMC4113666/) | 2014 | [PMC4113666 — MT](manuscripts/PMC4113666.md) | [Full text](https://europepmc.org/articles/PMC4113666) |
| 06  [Mortality Trends After Transfer From Peritoneal Dialysis to Hemodialysis.](https://pmc.ncbi.nlm.nih.gov/articles/PMC9091783/) | 2022 | [PMC9091783 — MT](manuscripts/PMC9091783.md) | [Full text](https://europepmc.org/articles/PMC9091783) |
| 06  [Early steps to kidney transplantation among persons with HIV and end-stage renal disease in ESRD network 6.](https://pmc.ncbi.nlm.nih.gov/articles/PMC8825692/) | 2022 | [PMC8825692 — MT](manuscripts/PMC8825692.md) | [Full text](https://europepmc.org/articles/PMC8825692) |
| 06  [Medication Burden and Prescribing Patterns in Patients on Hemodialysis in the USA, 2013-2017.](https://pmc.ncbi.nlm.nih.gov/articles/PMC8979193/) | 2021 | [PMC8979193 — MT](manuscripts/PMC8979193.md) | [Full text](https://europepmc.org/articles/PMC8979193) |
| 07  [Parathyroidectomy Versus Cinacalcet for the Treatment of Secondary Hyperparathyroidism in Hemodialysis Patients.](https://pmc.ncbi.nlm.nih.gov/articles/PMC8885484/) | 2022 | [PMC8885484 — MT](manuscripts/PMC8885484.md) | [Full text](https://europepmc.org/articles/PMC8885484) |
| 07  [Association of Potentially Inappropriate Medication Classes with Mortality Risk Among Older Adults Initiating Hemodialysis.](https://pmc.ncbi.nlm.nih.gov/articles/PMC10441684/) | 2023 | [PMC10441684 — MT](manuscripts/PMC10441684.md) | [Full text](https://europepmc.org/articles/PMC10441684) |
| 07  [Hydralazine-Isosorbide Dinitrate Use in Patients With End-Stage Kidney Disease on Dialysis.](https://pmc.ncbi.nlm.nih.gov/articles/PMC9171697/) | 2022 | [PMC9171697 — MT](manuscripts/PMC9171697.md) | [Full text](https://europepmc.org/articles/PMC9171697) |
| 07  [Renal deposits of complement factors as predictors of end-stage renal disease and death in patients with lupus nephritis.](https://pmc.ncbi.nlm.nih.gov/articles/PMC7733722/) | 2020 | [PMC7733722 — MT](manuscripts/PMC7733722.md) | [Full text](https://europepmc.org/articles/PMC7733722) |
| 07  [Foot and Ankle Care by Podiatrists and Amputations in Patients With Diabetes and Kidney Failure.](https://pmc.ncbi.nlm.nih.gov/articles/PMC10907919/) | 2024 | [PMC10907919 — MT](manuscripts/PMC10907919.md) | [Full text](https://europepmc.org/articles/PMC10907919) |
| 07  [Association of renal transplantation with reduced risk of myocardial infarction and ischemic stroke in ANCA-associated vasculitis: An observational cohort study.](https://pmc.ncbi.nlm.nih.gov/articles/PMC8784187/) | 2021 | [PMC8784187 — MT](manuscripts/PMC8784187.md) | [Full text](https://europepmc.org/articles/PMC8784187) |
| 08  [Racial Disparities in Arteriovenous Fistula Use Among Hemodialysis Patients: The Role of Surgeon Supply.](https://pmc.ncbi.nlm.nih.gov/articles/PMC9263254/) | 2022 | [PMC9263254 — MT](manuscripts/PMC9263254.md) | [Full text](https://europepmc.org/articles/PMC9263254) |
| 08  [Dialysis Preparedness and Access to the Transplant Waitlist: Evidence From a National United States Cohort Study.](https://pmc.ncbi.nlm.nih.gov/articles/PMC12231010/) | 2025 | [PMC12231010 — MT](manuscripts/PMC12231010.md) | [Full text](https://europepmc.org/articles/PMC12231010) |
| 08  [Neighborhood Disadvantage and Dementia Risk Among Older Patients With Kidney Failure: Differences by Race/Ethnicity and Urbanicity.](https://pmc.ncbi.nlm.nih.gov/articles/PMC13625871/) | 2026 | [PMC13625871 — MT](manuscripts/PMC13625871.md) | [Full text](https://europepmc.org/articles/PMC13625871) |
| 08  [Explaining trends and variation in timing of dialysis initiation in the United States.](https://pmc.ncbi.nlm.nih.gov/articles/PMC5440142/) | 2017 | [PMC5440142 — MT](manuscripts/PMC5440142.md) | [Full text](https://europepmc.org/articles/PMC5440142) |
| 08  [Contemporary Practice of Anemia Treatment Among Dialysis Patients in the United States.](https://pmc.ncbi.nlm.nih.gov/articles/PMC10719594/) | 2023 | [PMC10719594 — MT](manuscripts/PMC10719594.md) | [Full text](https://europepmc.org/articles/PMC10719594) |
| 08  [Setting reasonable goals for kidney transplant referral among dialysis facilities.](https://pmc.ncbi.nlm.nih.gov/articles/PMC11270779/) | 2024 | [PMC11270779 — MT](manuscripts/PMC11270779.md) | [Full text](https://europepmc.org/articles/PMC11270779) |
| 09  [Left Atrial Appendage Occlusion vs Anticoagulants in Dialysis With Atrial Fibrillation.](https://pmc.ncbi.nlm.nih.gov/articles/PMC12421340/) | 2025 | [PMC12421340 — MT](manuscripts/PMC12421340.md) | [Full text](https://europepmc.org/articles/PMC12421340) |
| 09  [Safety and effectiveness of apixaban versus warfarin for acute venous thromboembolism in patients with end-stage kidney disease: A national cohort study.](https://pmc.ncbi.nlm.nih.gov/articles/PMC9804323/) | 2022 | [PMC9804323 — MT](manuscripts/PMC9804323.md) | [Full text](https://europepmc.org/articles/PMC9804323) |
| 09  [Gabapentin Utilization and Adverse Effects Among US Hemodialysis Patients Diagnosed With Pruritus or Neuropathic Pain.](https://pmc.ncbi.nlm.nih.gov/articles/PMC13098409/) | 2026 | [PMC13098409 — MT](manuscripts/PMC13098409.md) | [Full text](https://europepmc.org/articles/PMC13098409) |
| 09  [The Association of Dialysis Facility Payer Mix With Access to Kidney Transplantation.](https://pmc.ncbi.nlm.nih.gov/articles/PMC10336615/) | 2023 | [PMC10336615 — MT](manuscripts/PMC10336615.md) | [Full text](https://europepmc.org/articles/PMC10336615) |
| 09  [Emergency department visits and hospitalizations among hemodialysis patients by day of the week and dialysis schedule in the United States.](https://pmc.ncbi.nlm.nih.gov/articles/PMC6695146/) | 2019 | [PMC6695146 — MT](manuscripts/PMC6695146.md) | [Full text](https://europepmc.org/articles/PMC6695146) |
| 09  [Transfers to Hemodialysis Among US Patients Initiating Renal Replacement Therapy With Peritoneal Dialysis.](https://pmc.ncbi.nlm.nih.gov/articles/PMC6815249/) | 2019 | [PMC6815249 — MT](manuscripts/PMC6815249.md) | [Full text](https://europepmc.org/articles/PMC6815249) |
| 10  [Effects of short-term ambient PM<sub>2.5</sub> exposure on cardiovascular disease incidence and mortality among U.S. hemodialysis patients: a retrospective cohort study.](https://pmc.ncbi.nlm.nih.gov/articles/PMC8917758/) | 2022 | [PMC8917758 — MT](manuscripts/PMC8917758.md) | [Full text](https://europepmc.org/articles/PMC8917758) |
| 10  [Hemodialysis Vascular Access and Risk of Major Bleeding, Thrombosis, and Cardiovascular Events: A Cohort Study.](https://pmc.ncbi.nlm.nih.gov/articles/PMC9189779/) | 2022 | [PMC9189779 — MT](manuscripts/PMC9189779.md) | [Full text](https://europepmc.org/articles/PMC9189779) |
| 10  [Higher Pretransplantation Hemoglobin A1c Is Associated With Greater Risk of Posttransplant Diabetes Mellitus.](https://pmc.ncbi.nlm.nih.gov/articles/PMC5733678/) | 2017 | [PMC5733678 — MT](manuscripts/PMC5733678.md) | [Full text](https://europepmc.org/articles/PMC5733678) |
| 10  [Increasing rates of parathyroidectomy to treat secondary hyperparathyroidism in dialysis patients with Medicare coverage.](https://pmc.ncbi.nlm.nih.gov/articles/PMC9233023/) | 2022 | [PMC9233023 — MT](manuscripts/PMC9233023.md) | [Full text](https://europepmc.org/articles/PMC9233023) |
| 10  [Gender Disparities in Kidney Transplantation Referral Vary by Age and Race: A Multiregional Cohort Study in the Southeast United States.](https://pmc.ncbi.nlm.nih.gov/articles/PMC9174037/) | 2022 | [PMC9174037 — MT](manuscripts/PMC9174037.md) | [Full text](https://europepmc.org/articles/PMC9174037) |
| 10  [Plasma Biomarkers and Incident CKD Among Individuals Without Diabetes.](https://pmc.ncbi.nlm.nih.gov/articles/PMC10568645/) | 2023 | [PMC10568645 — MT](manuscripts/PMC10568645.md) | [Full text](https://europepmc.org/articles/PMC10568645) |
| 11  [Trends, Social Context, and Transplant Implications of Obesity Among Incident Dialysis Patients in the United States.](https://pmc.ncbi.nlm.nih.gov/articles/PMC9613499/) | 2022 | [PMC9613499 — MT](manuscripts/PMC9613499.md) | [Full text](https://europepmc.org/articles/PMC9613499) |
| 11  [Hemodialysis Access Type and Access Patency Loss: An Observational Cohort Study.](https://pmc.ncbi.nlm.nih.gov/articles/PMC9829958/) | 2023 | [PMC9829958 — MT](manuscripts/PMC9829958.md) | [Full text](https://europepmc.org/articles/PMC9829958) |
| 11  [The Lifetime Health Burden of Delayed Graft Function in Kidney Transplant Recipients in the United States.](https://pmc.ncbi.nlm.nih.gov/articles/PMC6124921/) | 2018 | [PMC6124921 — MT](manuscripts/PMC6124921.md) | [Full text](https://europepmc.org/articles/PMC6124921) |
| 11  [Racial disparities in end-stage renal disease in a high-risk population: the Southern Community Cohort Study.](https://pmc.ncbi.nlm.nih.gov/articles/PMC6686512/) | 2019 | [PMC6686512 — MT](manuscripts/PMC6686512.md) | [Full text](https://europepmc.org/articles/PMC6686512) |
| 11  [The Magnitude of the Health and Economic Impact of Increased Organ Donation on Patients With End-Stage Renal Disease.](https://pmc.ncbi.nlm.nih.gov/articles/PMC8655828/) | 2021 | [PMC8655828 — MT](manuscripts/PMC8655828.md) | [Full text](https://europepmc.org/articles/PMC8655828) |
| 11  [Attribution of cause of end-stage renal disease among patients with systemic lupus erythematosus: the Georgia Lupus Registry.](https://pmc.ncbi.nlm.nih.gov/articles/PMC4731835/) | 2016 | [PMC4731835 — MT](manuscripts/PMC4731835.md) | [Full text](https://europepmc.org/articles/PMC4731835) |
| 12  [Comparative effectiveness of home dialysis therapies: a matched cohort study.](https://pmc.ncbi.nlm.nih.gov/articles/PMC4802626/) | 2016 | [PMC4802626 — MT](manuscripts/PMC4802626.md) | [Full text](https://europepmc.org/articles/PMC4802626) |
| 12  [Ambient Air Pollution and Mortality among Older Patients Initiating Maintenance Dialysis.](https://pmc.ncbi.nlm.nih.gov/articles/PMC8102374/) | 2021 | [PMC8102374 — MT](manuscripts/PMC8102374.md) | [Full text](https://europepmc.org/articles/PMC8102374) |
| 12  [Calcimimetic Prescriptions in Fee-for-Service Medicare Beneficiaries Undergoing Dialysis.](https://pmc.ncbi.nlm.nih.gov/articles/PMC12008760/) | 2025 | [PMC12008760 — MT](manuscripts/PMC12008760.md) | [Full text](https://europepmc.org/articles/PMC12008760) |
| 12  [High rates of cancer screening among dialysis patients seen in primary care a cohort study.](https://pmc.ncbi.nlm.nih.gov/articles/PMC5984226/) | 2018 | [PMC5984226 — MT](manuscripts/PMC5984226.md) | [Full text](https://europepmc.org/articles/PMC5984226) |
| 12  [A clinical score to predict recovery in end-stage kidney disease due to acute kidney injury.](https://pmc.ncbi.nlm.nih.gov/articles/PMC11079670/) | 2024 | [PMC11079670 — MT](manuscripts/PMC11079670.md) | [Full text](https://europepmc.org/articles/PMC11079670) |
| 12  [Nationwide Trends in Stroke Among Patients Undergoing Hemodialysis by Sex and Race: An Analysis From the US Renal Database.](https://pmc.ncbi.nlm.nih.gov/articles/PMC12132868/) | 2025 | [PMC12132868 — MT](manuscripts/PMC12132868.md) | [Full text](https://europepmc.org/articles/PMC12132868) |
| 13  [Atopic Dermatitis and the Risk of Infection in End-Stage Renal Disease.](https://pmc.ncbi.nlm.nih.gov/articles/PMC10744789/) | 2023 | [PMC10744789 — MT](manuscripts/PMC10744789.md) | [Full text](https://europepmc.org/articles/PMC10744789) |
| 13  [Cost-Effectiveness of Acceptable-Quality Deceased Donor Kidneys for Transplant in Older Candidates.](https://pmc.ncbi.nlm.nih.gov/articles/PMC12848627/) | 2026 | [PMC12848627 — MT](manuscripts/PMC12848627.md) | [Full text](https://europepmc.org/articles/PMC12848627) |
| 13  [Prescribing Patterns of Hydroxychloroquine and Glucocorticoids Among Lupus Patients After New-Onset End-Stage Renal Disease.](https://pmc.ncbi.nlm.nih.gov/articles/PMC9205678/) | 2022 | [PMC9205678 — MT](manuscripts/PMC9205678.md) | [Full text](https://europepmc.org/articles/PMC9205678) |
| 13  [Erythropoietin treatment and the risk of hip fractures in hemodialysis patients.](https://pmc.ncbi.nlm.nih.gov/articles/PMC8360057/) | 2021 | [PMC8360057 — MT](manuscripts/PMC8360057.md) | [Full text](https://europepmc.org/articles/PMC8360057) |
| 13  [The Assessment of Infection Risk in Patients with Vitiligo Undergoing Dialysis for End-Stage Renal Disease: A Retrospective Cohort Study.](https://pmc.ncbi.nlm.nih.gov/articles/PMC10821439/) | 2024 | [PMC10821439 — MT](manuscripts/PMC10821439.md) | [Full text](https://europepmc.org/articles/PMC10821439) |
| 13  [Disentangling Dialysis Facility and Transplant Center Factors on Evaluation Start Following Referral for Kidney Transplantation: A Regional Study in the United States.](https://pmc.ncbi.nlm.nih.gov/articles/PMC11930794/) | 2025 | [PMC11930794 — MT](manuscripts/PMC11930794.md) | [Full text](https://europepmc.org/articles/PMC11930794) |
| 14  [Health care resource utilization and costs of major bleeding in patients with and without dialysis-dependent end-stage kidney disease: a retrospective study.](https://pmc.ncbi.nlm.nih.gov/articles/PMC13098619/) | 2026 | [PMC13098619 — MT](manuscripts/PMC13098619.md) | [Full text](https://europepmc.org/articles/PMC13098619) |
| 14  [Kidney Replacement Therapy Sequences: Racial/Ethnic Disparities in End-Stage Kidney Disease Patients' 10-Year Treatment Histories.](https://pmc.ncbi.nlm.nih.gov/articles/PMC12775809/) | 2026 | [PMC12775809 — MT](manuscripts/PMC12775809.md) | [Full text](https://europepmc.org/articles/PMC12775809) |
| 14  [Impact of valve position and prosthesis type on outcomes of valve replacement in end-stage renal disease patients with infective endocarditis.](https://pmc.ncbi.nlm.nih.gov/articles/PMC13477041/) | 2026 | [PMC13477041 — MT](manuscripts/PMC13477041.md) | [Full text](https://europepmc.org/articles/PMC13477041) |
| 14  [High mortality rates after distal femur fractures in patients with end-stage renal disease.](https://pmc.ncbi.nlm.nih.gov/articles/PMC12316354/) | 2025 | [PMC12316354 — MT](manuscripts/PMC12316354.md) | [Full text](https://europepmc.org/articles/PMC12316354) |
| 14  [Geographic Dialysis Facility Density and Early Dialysis Initiation.](https://pmc.ncbi.nlm.nih.gov/articles/PMC10765261/) | 2024 | [PMC10765261 — MT](manuscripts/PMC10765261.md) | [Full text](https://europepmc.org/articles/PMC10765261) |
| 14  [Target Trial of Glucagon-Like Peptide-1 Agonists versus Dipeptidyl Peptidase-4 Inhibitors and Mortality in Hemodialysis.](https://pmc.ncbi.nlm.nih.gov/articles/PMC13315691/) | 2026 | [PMC13315691 — MT](manuscripts/PMC13315691.md) | [Full text](https://europepmc.org/articles/PMC13315691) |
| 15  [Estimating Short-Term and Long-Term Survival for Patients With Kidney Failure Using a Mixture Survival Model.](https://pmc.ncbi.nlm.nih.gov/articles/PMC12874817/) | 2026 | [PMC12874817 — MT](manuscripts/PMC12874817.md) | [Full text](https://europepmc.org/articles/PMC12874817) |
| 15  [Mortality risk in patients with autosomal dominant polycystic kidney disease.](https://pmc.ncbi.nlm.nih.gov/articles/PMC10870477/) | 2024 | [PMC10870477 — MT](manuscripts/PMC10870477.md) | [Full text](https://europepmc.org/articles/PMC10870477) |
| 15  [Pregnancies in Women With Kidney Failure on Home Dialysis in the United States.](https://pmc.ncbi.nlm.nih.gov/articles/PMC11101807/) | 2024 | [PMC11101807 — MT](manuscripts/PMC11101807.md) | [Full text](https://europepmc.org/articles/PMC11101807) |
| 15  [Association of Therapeutic Plasma Exchange-Treated Thrombotic Thrombocytopenic Purpura with Improved Mortality Outcome in End-Stage Renal Disease.](https://pmc.ncbi.nlm.nih.gov/articles/PMC12385575/) | 2025 | [PMC12385575 — MT](manuscripts/PMC12385575.md) | [Full text](https://europepmc.org/articles/PMC12385575) |
| 15  [Associations between abrupt transition, dialysis-requiring AKI, and early mortality in ESKD among U.S. veterans.](https://pmc.ncbi.nlm.nih.gov/articles/PMC10647139/) | 2023 | [PMC10647139 — MT](manuscripts/PMC10647139.md) | [Full text](https://europepmc.org/articles/PMC10647139) |
| 15  [Differences in Telemedicine Use Between Rural and Urban Medicare Beneficiaries With Kidney Failure.](https://pmc.ncbi.nlm.nih.gov/articles/PMC13092677/) | 2026 | [PMC13092677 — MT](manuscripts/PMC13092677.md) | [Full text](https://europepmc.org/articles/PMC13092677) |
| 16  [Primary Care Use and Clinical Outcomes in a Prevalent Cohort of Patients Receiving Hemodialysis.](https://pmc.ncbi.nlm.nih.gov/articles/PMC13019550/) | 2026 | [PMC13019550 — MT](manuscripts/PMC13019550.md) | [Full text](https://europepmc.org/articles/PMC13019550) |
| 16  [Kidney Failure Attributed to Focal Segmental Glomerulosclerosis: A USRDS Retrospective Cohort Study of Epidemiology, Treatment Modalities, and Economic Burden.](https://pmc.ncbi.nlm.nih.gov/articles/PMC10831785/) | 2024 | [PMC10831785 — MT](manuscripts/PMC10831785.md) | [Full text](https://europepmc.org/articles/PMC10831785) |
| 16  [Pre-dialysis care and access type are associated with transplant referral, evaluation, and waitlisting.](https://pmc.ncbi.nlm.nih.gov/articles/PMC13260918/) | 2026 | [PMC13260918 — MT](manuscripts/PMC13260918.md) | [Full text](https://europepmc.org/articles/PMC13260918) |
| 16  [P2Y12 Inhibitors Refill Gap Predicts Death in Medicare Beneficiaries on Chronic Dialysis.](https://pmc.ncbi.nlm.nih.gov/articles/PMC11284433/) | 2024 | [PMC11284433 — MT](manuscripts/PMC11284433.md) | [Full text](https://europepmc.org/articles/PMC11284433) |
| 16  [Sex/Gender Disparities in Preemptive Referrals for Kidney Transplantation.](https://pmc.ncbi.nlm.nih.gov/articles/PMC11284440/) | 2024 | [PMC11284440 — MT](manuscripts/PMC11284440.md) | [Full text](https://europepmc.org/articles/PMC11284440) |
| 16  [A Multilevel Spatial Survival Analysis of Patients in Texas with End-Stage Renal Disease.](https://pmc.ncbi.nlm.nih.gov/articles/PMC12691873/) | 2025 | [PMC12691873 — MT](manuscripts/PMC12691873.md) | [Full text](https://europepmc.org/articles/PMC12691873) |
| 17  [Sex/Gender-Based Disparities in Early Transplant Access by Attributed Cause of Kidney Disease-Evidence from a Multiregional Cohort in the Southeast United States.](https://pmc.ncbi.nlm.nih.gov/articles/PMC10719652/) | 2023 | [PMC10719652 — MT](manuscripts/PMC10719652.md) | [Full text](https://europepmc.org/articles/PMC10719652) |
| 17  [Pressure Ulcer Diagnosis Is Associated with Increased Mortality in Patients with End-Stage Renal Disease: A Retrospective Study.](https://pmc.ncbi.nlm.nih.gov/articles/PMC10456114/) | 2023 | [PMC10456114 — MT](manuscripts/PMC10456114.md) | [Full text](https://europepmc.org/articles/PMC10456114) |
| 17  [Elevated Ambient Temperature Associated With Increased Cardiovascular Disease-Risk Among Patients on Hemodialysis.](https://pmc.ncbi.nlm.nih.gov/articles/PMC11489478/) | 2024 | [PMC11489478 — MT](manuscripts/PMC11489478.md) | [Full text](https://europepmc.org/articles/PMC11489478) |
| 17  [Divergent Trends by Patient Age in Racial Disparities in Kidney Transplant Access.](https://pmc.ncbi.nlm.nih.gov/articles/PMC12348215/) | 2025 | [PMC12348215 — MT](manuscripts/PMC12348215.md) | [Full text](https://europepmc.org/articles/PMC12348215) |
| 17  [Regional Variation in Early Kidney Transplant Access Across Dialysis Facilities in 4 US Regions.](https://pmc.ncbi.nlm.nih.gov/articles/PMC12828506/) | 2026 | [PMC12828506 — MT](manuscripts/PMC12828506.md) | [Full text](https://europepmc.org/articles/PMC12828506) |
