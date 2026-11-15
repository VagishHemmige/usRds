# Methodological distinctions from the literature

Initial synthesis of inspected sources, 2026-11-15. These are distinctions to
preserve when interpreting analyses, not approved package defaults. The linked
papers are primary sources; individual reading limits are in the manuscript
annotations delivered across the companion batches (including #62 and #63).
Until those PRs land, their annotations are available on the PR branches. Unless specified there, tables, figures as images, supplements and
exact mappings to release dictionaries remain unverified.

## Registry inclusion, claims observation and validation

Registry membership, insurance entitlement, primary-payer intervals and available
claims are separate concepts. A payer value at index does not establish a complete
lookback or uninterrupted observation. Papers impose different eligibility windows;
retain those differences rather than calling them all “Medicare patients.”

The [ARIC linkage study, PMC4516566](https://pmc.ncbi.nlm.nih.gov/articles/PMC4516566/)
compares treated kidney failure identified through USRDS with a broader definition
including untreated failure. Early deaths and delayed registration explain some
missed registry cases (Results: validation; Discussion). This does not mean every
absence from USRDS is untreated failure or that the broader phenotype is always
preferable.

[PMC6065459](https://pmc.ncbi.nlm.nih.gov/articles/PMC6065459/) compares comorbidity
sources without a clinical gold standard; agreement is not accuracy. In contrast,
[PMC8754012](https://pmc.ncbi.nlm.nih.gov/articles/PMC8754012/) and
[PMC5219868](https://pmc.ncbi.nlm.nih.gov/articles/PMC5219868/) use external clinical
records to assess vasculitis and lupus attribution. Preserve reference standards,
selection/verification pathways, missing-cause handling and sensitivity versus
positive predictive value. An attributed primary cause is not every instance of
that disease among registry members.

## Claim, episode, patient and event date

A claim line, a hospitalization and a person are different units. Exact diagnosis
positions, repeated-claim rules, confirmation intervals and episode deduplication
must come from the chosen phenotype and underlying file layout.

[PMC12768901](https://pmc.ncbi.nlm.nih.gov/articles/PMC12768901/) explicitly assigns
diagnoses/procedures to CLM_FROM, acknowledging that claims span CLM_FROM–CLM_THRU
(Methods). That is an event-date approximation, not confirmation that a procedure
occurred on the first service day. [PMC7673774](https://pmc.ncbi.nlm.nih.gov/articles/PMC7673774/)
requires two gout claims but assigns onset to the first; its main text does not
specify a bounded confirmation interval. Future confirmation and onset assignment
need separate representation.

[PMC6708631](https://pmc.ncbi.nlm.nih.gov/articles/PMC6708631/) and
[PMC11179932](https://pmc.ncbi.nlm.nih.gov/articles/PMC11179932/) analyze recurrent
admissions/events. Their counting-process models are examples of preserving event
order and person-time, not a reason to treat every claim as a separate encounter.

## Time origins, changing states and competing events

Transplant date, hospital discharge, infection diagnosis, graft failure and modality
transfer answer different questions. Preserve event-specific origins and the
historical state used for each measurement.

[PMC9091783](https://pmc.ncbi.nlm.nih.gov/articles/PMC9091783/) begins follow-up on
the first HD day after PD, including transfers lasting only one day. Requiring
30/90 days on the new modality would change its early-mortality question. It also
continues follow-up after return to PD; do not silently censor at the next modality
change. [PMC8059163](https://pmc.ncbi.nlm.nih.gov/articles/PMC8059163/) requires a
recovery code plus sustained survival without dialysis/transplant; recovery is not
mere absence of claims or withdrawal from dialysis.

The preemptive-event value of 0.5 days in
[PMC10899312](https://pmc.ncbi.nlm.nih.gov/articles/PMC10899312/) is an explicit
analytical convention, not a source date. Death may be a competing event, a
censoring event or a component of a composite; specify this separately for each
endpoint. Survival beyond an eligibility window changes the target population.

## Medication exposure and medication-based phenotypes

[PMC8554601](https://pmc.ncbi.nlm.nih.gov/articles/PMC8554601/) handles refill
overlaps, strength changes and inpatient periods separately. Inpatient adherence
and carried-forward supply are assumptions. [PMC8979193](https://pmc.ncbi.nlm.nih.gov/articles/PMC8979193/)
counts any dispensing/administration during a year; that is not concurrent daily
medication burden. [PMC11998892](https://pmc.ncbi.nlm.nih.gov/articles/PMC11998892/)
uses point-in-time exposure and externally versioned dose criteria.

[PMC8825692](https://pmc.ncbi.nlm.nih.gov/articles/PMC8825692/) identifies HIV using
antiretroviral prescriptions or attributed HIV nephropathy. Its limitations include
unobserved fills and alternative indications such as hepatitis B treatment or
PrEP. A medication indication cannot be assumed from a drug name alone.

## Costs, time windows and inflation

Keep payer payments, charges and broader societal costs distinct. A paper's use
of “cost” does not identify a SAF payment column, resolve claim/revenue overlap,
or establish the correct adjustment field. Verify those against the release.

[PMC7056859](https://pmc.ncbi.nlm.nih.gov/articles/PMC7056859/) allocates claims by
service-begin date, annualizes using Medicare-primary days and uses a fixed 3%
annual adjustment to 2017 dollars (Costs). These choices differ from daily claim
proration, observed full-year totals and a medical CPI series. Its main cohort
allows different combinations of A/B/D claims; all-three-part claims are a
sensitivity analysis.

[PMC10818081](https://pmc.ncbi.nlm.nih.gov/articles/PMC10818081/) distinguishes a
coverage-or-earlier-death cohort from full-year survivors and reports person-month
costs. [PMC9184448](https://pmc.ncbi.nlm.nih.gov/articles/PMC9184448/) starts costs
after transplant discharge and constructs a time-since-transplant-weighted control
curve around graft failure. That curve is not individual risk-set matching. Neither
paper's main text establishes all payment-field, inflation-index and proration
details needed to reproduce its estimates.

## Geography, linkage and external measurements

Preserve geography type, crosswalk vintage, residence date and denominator.
A fixed ACS period linked to changing addresses does not provide annual income.
Referral and evaluation may require external registry data; they cannot be inferred
from waitlisting alone. Imputed referral dates in
[PMC8825692](https://pmc.ncbi.nlm.nih.gov/articles/PMC8825692/) must remain distinguishable
from observed dates. The prospectively measured Fried frailty phenotype in
[PMC7056859](https://pmc.ncbi.nlm.nih.gov/articles/PMC7056859/) is not a claims-based
frailty score.

## Turning a source into a reproducible method

Before reproducing a convention, establish the applicable release; exact source
fields and units; eligibility and observation intervals; person/episode keys;
missingness rules; time origins and endpoint boundaries; and any external data or
measurement requirements. If a paper omits a detail or contains inconsistent
counts, retain that uncertainty rather than completing the method by guesswork.
Consult [official sources](web-sources.md) for definitions and
[external code annotations](repositories.md) for implementation ideas.
