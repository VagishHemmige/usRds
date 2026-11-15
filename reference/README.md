# Reference material

Background on USRDS files, collection eras, scientific methods, research
literature and external analysis code. This README is the single guide to
finding, maintaining and citing that background during coding and review.

| File | Purpose |
|---|---|
| [Manuscript catalog](pmc-manuscripts.md) | Collection being developed toward 100 PMC manuscripts; explicit reading status and individual annotations |
| [Code repositories](repositories.md) | Commit-specific source inspection, useful patterns and limitations |
| [Official sources](web-sources.md) | Researcher's Guides, appendices and ADR methods; editions and access limitations |

## Use during development and review

Start with the relevant topic, then read the underlying sources. For a scientific
choice, distinguish the source that **defines** a variable or method from a
paper that **uses** a convention and from external code that merely implements
one. Published use does not validate a method or make it a package default.
Check the applicable data release; publication year is not data vintage.

Keep package behavior, defects, proposed fixes, test results and implementation
decisions outside this folder, beside the implementation, in existing
documentation, or in authorized issues/PRs. Reference entries describe the data
and methods, not package functions or issue status. Link rather than duplicate.
Scientific uncertainty remains uncertainty until resolved against a source or
by an explicit methodological decision.

For citations in code, use defining sources in roxygen `@references` (DOI where
available). Explain a convention as a convention beside the choice; identify
the paper by PMCID/DOI or the repository by owner/name and commit. Reference
files may move, so avoid making their current filename the only citation.
Do not add citations to existing code without checking the claimed connection.

## Manuscript selection and annotation

The catalog records a purposive methods collection, not a systematic review or
a claim to cover all USRDS studies. Include original analyses of USRDS data,
external linkages and methods papers using USRDS. Exclude incidental citations,
editorials, reviews and conference abstracts from the 100-manuscript count.
Keep search date/query, candidate disposition and access attempts reproducible.
Use both NCBI PMC and Europe PMC; an API failure is not proof that the article
is unavailable. Use an authorized connected browser when available and useful.

Each entry uses its PMCID as the heading and records:

- Citation, DOI, publication year, source role, study period and cutoff. The
  catalog uses Europe PMC `pubYear`, which can differ from first-online year.
- Population and unit: person, transplant, claim, encounter, facility or interval.
- Files and fields: only exact names stated in the paper or independently
  checked in a named edition of a dictionary. Never infer exact variable names.
- Data needs: eligibility, linkage, lookback, index dates, recurrence, exposures,
  endpoints, follow-up and censoring; monetary perspective/index where relevant.
- Data pitfalls: ascertainment limits, missingness, era changes, ambiguous
  definitions and source disagreements, with locators.
- Reading status/date and explicitly unread material.

Source-basis tags: `[reported §section/table]`, `[dictionary: edition, locator]`,
`[inference]`, `[unclear §section]`, and `[external: source]`. Inferences describe
needed record families or consequences, never invented file/field names.

Reading statuses: `Screened` (abstract and/or targeted passages); `MT`
(complete main text); `MT+T` (also tables and figure captions); `MT+T+S`
(also relevant supplements). Record partial reads precisely. Downloaded is not
read; full-text availability and reading status are separate fields. XML text
does not establish inspection of figure images or equations rendered only as
images. Do not mark supplements read merely because the main text cites them.

Use one annotation file per manuscript, linked from the catalog. Update the
index after checking the final annotations. This avoids shared-table collisions
and allows corrections without reworking unrelated papers.

## Code annotations and safety

Record repository, exact commit, inspected files/line ranges, language, data
role, operational choices, useful patterns and limitations. Distinguish source
inspection from execution. External code is neither a scientific authority nor
permission to use its data. Inspect source only; do not open data, saved outputs,
rendered notebooks or artifacts with uncertain provenance. If source itself
contains a possibly real identifier, do not reproduce its value or inspect
associated patient records. General source logic can still be assessed; isolate
individual-specific exceptions and disclose their unverified provenance.

No restricted patient data belong here. Store links and original concise
annotations, not copies of manuscripts, dictionaries or third-party code.
Check licensing before reusing code. Package-build exclusion is proposed separately in `.Rbuildignore`; check the
actual configuration before assuming this directory is excluded. Build exclusion
alone makes no claim about website publication or privacy.
