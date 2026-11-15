# Whole-package review protocol

Use this protocol only for an explicitly commissioned deep review of
usRds. Its presence does not start an audit.
[REVIEWING.md](https://vagishhemmige.github.io/usRds/REVIEWING.md)
defines shared review standards and remains the guide for routine PR
reviews. Read
[AGENTS.md](https://vagishhemmige.github.io/usRds/AGENTS.md) and
applicable subdirectory guidance. This protocol does not grant
implementation, posting, approval, merge or automation permissions.

Adapted from the whole-package protocols in [sRtr at
2d0b878](https://github.com/VagishHemmige/sRtr/blob/2d0b87896713d79a1b373dacd8190a4fcdf51f85/PACKAGE_REVIEW.md)
and [CDCAtlas at
3c02b95](https://github.com/VagishHemmige/CDCAtlas/blob/3c02b95e5ffd3ac623752ca2e02a5e1a3692c2cd/PACKAGE_REVIEW.md),
with usRds-specific clinical coverage, source requirements and data
boundaries.

## Purpose and scope

Assess current implementation, scientific definitions, complete user
workflows, documentation, tests and CI, every open issue, and justified
future needs. Ask whether users can obtain invalid analyses even when
code works as written. Distinguish verified defects, evidence gaps,
methodological choices, intentional unfinished work, documentation
problems and optional enhancements.

Review does not authorize fixes or selection of scientific defaults. It
does include independent synthetic checks and concrete proposed
documentation, regression-test and CI patches. Keep these separate from
the frozen baseline. Install permanent changes only through the
maintainer’s authorized workflow.

## 1. Freeze the target and establish safe execution

Record repository, verified default branch, full commit SHA, date,
package version, policy revision, comparison scope, website URL and
observed deployment revision if available. For PRs use target-branch
policy at its recorded SHA and the merge base; proposed policy does not
govern its own review. Whole-package scope covers the complete frozen
package, not only its latest diff. GitHub scope excludes unpushed work.
For a requested local review, inventory staged, unstaged and relevant
untracked changes read-only; execute only in an isolated workspace.

Never access, copy, upload or expose restricted patient-level data.
Never run real-data tests, even if enabled by environment variables. The
connected working copy, synced sources and active RStudio session remain
read-only. Inspect data-raw/ source without running regeneration; never
edit or regenerate data/ or R/sysdata.rda. For uncertain fixture
provenance, report only its path and request verification without
opening values.

Before loading package code, inspect startup files, R/zzz.R and other
load hooks, test helpers, setup files, guards and call sites for data
access or writes. Inspect tests/testthat/helper-live.R for the actual
live-test variables at the reviewed revision; do not assume one guard
protects all paths. Unset USRDS_WD, disable/unset all discovered
live-data switches and exclude checks whose real data access cannot be
ruled out. Do not copy private startup settings.

Use a fresh Rscript –vanilla process. Set R_ENVIRON_USER and
R_PROFILE_USER to empty files in the isolated workspace for child
processes as well. Retain those files for the entire run. Verify parent
and child startup isolation using harmless synthetic startup files
before relying on package checks, and record the result. Recheck
effective guards where helpers can restore settings. Keep caches and
incidental outputs in temporary locations. No check may use the
maintainer’s active session or real-data directories.

Use only small, obviously synthetic fixtures with documented columns and
provenance. Synthetic checks establish code behavior, not validity on
actual USRDS releases. Report exact blockers and safe remaining
maintainer commands without requesting patient-level output.

## 2. Required review perspectives

Use independent reviewer contexts where supported, scheduling roles in
waves when necessary. These are AI specialist perspectives, not claims
of clinical credentials or replacements for authoritative sources and
human expertise. Record unavailable roles or lack of independence as
coverage limitations.

**At minimum, clinical review must include separate dialysis and
transplant expert perspectives. Neither can be replaced by a generic
clinical reviewer.**

| Perspective | Required coverage |
|----|----|
| Dialysis clinician-researcher | Hemodialysis and peritoneal dialysis; incident/prevalent cohorts; modality and facility transitions; treatment episodes; dialysis access and complications; hospitalization, mortality and ascertainment limits |
| Transplant clinician-researcher | Kidney transplantation, functioning graft versus graft failure, return to dialysis, retransplantation, sequential/multiorgan transplantation, post-transplant follow-up and applicability of shared definitions |
| USRDS and Medicare claims methodology specialist | Release-specific guides and appendices, file/field meanings, payer and eligibility histories, claims availability, coding eras, linkage and units of observation |
| Biostatistician and epidemiologist | Time origins, time-varying covariates, lookback, censoring, competing events, repeated episodes, missingness, selection and ascertainment bias |
| Health economist or claims-cost methods reviewer | Payment versus charges, claim versus revenue-line amounts, overlap, proration, negative adjustments, inflation and monetary perspective |
| R package and data engineer | Exported/internal functions, SAS/CSV/Parquet behavior, identifiers, joins, labels, attributes, dependencies, errors, side effects, performance evidence and Windows behavior |
| Independent testing and reproducibility reviewer | Test expectations, fixtures, mocks, integration coverage, skips, startup isolation, CI configuration and observed runs; concrete regression-test and CI proposals |
| Scientific librarian and provenance reviewer | Source coverage, editions, locators, actual reading status, contradictions, external code provenance and reference maintenance |
| Researcher using the package | Website, README, help and vignettes; discoverability, explanations, practical misuse risks and complete workflows |

Add infectious diseases, oncology, pharmacy, pediatric, spatial or other
specialists when the inventory warrants them. Do not invent capabilities
to fill roles. Dialysis and transplant reviewers must both assess shared
logic for dialysis-to-transplant transitions, graft failure/return to
dialysis, retransplantation, mortality and follow-up. Claims,
statistical and engineering reviewers independently challenge the
corresponding representations and timing.

The coordinator assigns every in-scope file/function, verifies findings,
reconciles disagreements and tracks coverage. No single specialist must
read everything. Agreement among reviewers is not scientific evidence.

## 3. Reference use and independent first passes

Use
[reference/README.md](https://vagishhemmige.github.io/usRds/reference/README.md)
as the single guide to source selection, placement and citation.
Inventory the actual files at the frozen revision, including:

- [Official
  sources](https://vagishhemmige.github.io/usRds/reference/web-sources.md).
- [Manuscript
  catalog](https://vagishhemmige.github.io/usRds/reference/pmc-manuscripts.md)
  and linked annotations.
- [External
  code](https://vagishhemmige.github.io/usRds/reference/repositories.md).
- [Methodological
  background](https://vagishhemmige.github.io/usRds/reference/methodology-notes.md).

The coordinator and librarian map the full catalog to review topics and
identify coverage gaps. A catalog of 100 manuscripts is not proof that
all were fully read or that every package definition is supported.
Record relevant sources selected, sources screened out with a reason,
unread material and access gaps. Do not require every reviewer to reread
every paper; do require substantive verification of the sources
supporting their consequential conclusions.

Prepare topic-specific packets with primary-source links, editions,
study periods, population, units, exact sections/tables and pinned
external-code locations. Include both dialysis and transplant
literature. Distinguish defining sources, published conventions and
external implementations. Verify the underlying source rather than
treating annotations as authority. Recheck exact field/code names
against a named release. Publication year is not data vintage; 2025
documentation does not automatically establish older-release
definitions. Check unclear converted tables against originals and
disclose unavailable guides, appendices or supplements.

For initial independent passes, withhold prior package diagnoses, issue
conclusions and other reviewers’ findings. Existing source, tests and
neutral reference facts remain available. Do not pass annotated
judgments wholesale and claim blindness; disclose unavoidable exposure.
Private conversations and handoffs are coordinator context only and must
not be published.

External code is source-inspection evidence, not scientific authority or
permission to open its data. Follow reference/README.md’s provenance
boundaries. Record new sources and reconcile useful background into
existing reference entries. Keep package defects and implementation
decisions in their owning issues, tests or documentation.

For each consequential scientific conclusion record source, edition/era,
locator, what was actually read, what it supports, uncertainties, and
the definition or check it informs. A bibliography alone does not
satisfy this.

## 4. Inventory, trace and assess definitions

Inventory all tracked files, exported/internal functions, tests/helpers,
documentation, workflows, reference records, and open issues/PRs.
Paginate collections and reconcile counts. Inspect relevant closed
issues and merged PRs for prior resolutions. Keep unmerged fixes
distinct from current behavior.

Maintain a resumable coverage record outside the repository:

| Item | Revision | Assigned perspectives | Read | Source verification | Executed checks | Disposition/gap |
|----|----|----|----|----|----|----|

Read every in-scope human-written source and documentation file, not a
sample. Check generated documentation against source; inventory binaries
without opening uncertain data. State exclusions and reasons. “Not
assessed” remains a coverage gap. On resumption, reuse records and
recheck intervening changes; a fresh audit must not merely rerun an old
bundle.

Trace loading -\> labeling/missingness -\> linkage -\>
eligibility/cohort creation -\> derived measures -\> analysis-ready
output. Compare documented contracts, implementation, callers, returned
attributes and complete workflows.

For each scientific definition or derived measure, record population and
unit, source files/fields, codes, dates/time units, release,
missingness, eligibility, timing, censoring, assumptions, implementation
and test coverage. Require: clinical/methodological validity, support
from the applicable source, and correct implementation. Preserve
disagreements and identify evidence or a maintainer decision needed to
settle them.

Apply REVIEWING.md’s usRds-specific checks, emphasizing:

- Person, treatment episode, transplant, encounter, claim and
  revenue-line units; identifier precision, duplicate keys and join
  multiplication.
- Cross-format and cross-release layouts, column selection, labels
  versus codes, distinct missing categories, partial years and stale
  session state.
- Eligibility and payer history versus administrative follow-up and
  observable claims; ICD era, exact/prefix matching, positions and
  distinct encounters.
- Dialysis modality transitions, graft failure, return to dialysis,
  retransplantation and row-varying supplied baselines versus
  patient-specific default baselines. Preserve cohort attributes and
  finalization state.
- Costs by named measure: payment/charge distinctions, overlap,
  proration conservation, partial windows, negative adjustments and
  inflation coverage.

Do not transfer an individual analysis’s inclusion, matching or endpoint
rules into package defaults without a decision. Compare meaningful
alternatives on the same synthetic inputs when useful; label
decision-dependent expectations.

## 5. Website and documentation

Give the researcher perspective the published site and help first,
before code. Read every article/vignette, README and exported-function
help page. Then compare with the frozen implementation. Assess:

- Whether a researcher can follow installation and complete a workflow
  without unstated prerequisites; use synthetic substitutes where
  execution is safe.
- Whether USRDS the data source and usRds the package are clearly
  distinguished.
- Whether units, coverage assumptions, missingness, costs and follow-up
  choices are explained, including when defaults are unsuitable.
- Whether examples use the current API and output, and all exported
  functions appear in the reference index.
- Whether the deployed site matches the reviewed revision; distinguish
  source inspection, an isolated build and observed deployment.
- Links, citations, headings, meaningful alt text, readable tables and
  color independence. Check Markdown/LLM copies if present.
- Whether root review files or other unintended content are published.
  .Rbuildignore excludes files from package builds, not necessarily
  pkgdown.

Record passage, problem, likely consequence and proposed rewrite. Keep
explanatory shortcomings distinct from calculation defects; code/help
conflicts must identify which contract needs a decision. Do not execute
real-data vignettes to complete this workstream.

## 6. Independent tests and CI

Audit every test/helper and workflow. Map coverage to definitions,
functions and end-to-end workflows. Derive expected results from sources
and hand-worked synthetic examples independently of implementation.
Challenge mocks that bypass the claimed behavior, unjustified skips and
assertions that encode the same bug.

Create useful synthetic reproducers for serious suspected defects and
uncovered high-risk behavior. Preserve their inputs, source basis, exact
commands, dependencies and observed results separately from the frozen
package. Distinguish passing, failing, decision-dependent and
blocked/not-run checks. Do not weaken assertions or silently fix
implementation to make an audit pass.

Inspect CI triggers/path filters, actual tested revisions, R/OS
matrices, dependency handling, permissions, secrets use, caches, skips,
timeouts and failure propagation. Inspect required-check settings if
available and disclose access gaps. Configuration is not evidence of
execution; a pkgdown build is not a full package check. Assess
installation, exports, synthetic format equivalence, Windows paths and
meaningful integration coverage.

Deliver concrete permanent-test or inert workflow patches for material
gaps, with destination, rationale, expected signal, prerequisites and
validation status; if none are warranted, explain why. Strengthen
existing tests/workflows before creating new infrastructure. Keep
proposed workflow changes inert until authorized. Do not create a second
permanent audit suite or tracking backlog.

When a fix is implemented, integrate its regression beside the owning
tests, demonstrate failure before/success after when feasible, and
retire duplicate standalone checks. Do not encode an unresolved
methodological choice as a permanent test contract.

Record actual runtime, OS, R/dependency versions, commands, failures and
skips. Separate source inspection, personally executed synthetic checks,
observed CI at a named revision, author-reported checks and remaining
real-data validation. Investigate safe isolated alternatives if
R/dependencies are unavailable. Give exact remaining maintainer commands
and relevant vignette rebuilds with prerequisites and data-access
implications; do not run real-data checks.

## 7. Reconcile issues and challenge findings

After independent discovery, review every open issue with its complete
discussion, linked PRs and relevant sources. Record premise, current
behavior, evidence, consequences, proposed solution’s adequacy,
duplication, missing checks/decisions, recommended disposition and a
substantive draft comment. Refresh the inventory before completion. A
proposed fix is not a merged fix.

Have dialysis and transplant reviewers jointly challenge shared
transitions and outcomes; claims and cost reviewers challenge
aggregation and monetary measures; statistics and engineering reviewers
challenge timing and representation; testing challenges all claimed
guarantees. Correct unsupported findings and merge duplicates without
losing distinct consequences.

For future capabilities, identify concrete research use, source
feasibility, existing alternatives, why the capability belongs in the
package, dependencies, priority and acceptance criteria. Distinguish
enhancements from defects.

## 8. Deliver, preserve and integrate

Deliver a consolidated assessment with prioritized findings,
issue-by-issue drafts, deduplicated new-issue proposals, scientific
choices and alternatives, coverage/source records, reusable reproducers,
concrete test/CI/documentation patches, validation limits and a staged
roadmap.

Use REVIEWING.md’s Must fix / Should fix / Consider categories,
separately from classification. Each finding needs a pinned location,
evidence, consequence, confidence, proposed remedy and acceptance check.
Serious findings need a reproducer or explicit verification blocker.

Keep full reports, reviewer transcripts, coverage ledgers and
exploratory artifacts in permitted durable maintainer-accessible storage
outside the repo. Temporary paths alone are insufficient. Preserve
lasting knowledge in its existing home: reference background via
reference/README.md, regression tests beside owning tests, user
explanations in help/vignettes, process lessons in review guidance, and
decisions in owning issues/implementation documentation. Do not create a
second reference catalog, live backlog or repository audit archive.

Prepare concrete self-reviewed diffs for useful documentation
improvements. Report each material result as integrated (link), proposed
(patch/link), deferred (owning item and reason) or archive-only
(reason). Keep analytical coverage, remaining validation and repository
integration distinct. If coverage is incomplete, label the assessment
partial; posting findings alone does not complete integration. End with
what was preserved, where, and what remains.

## 9. Publication and follow-up permissions

Present the consolidated report before posting audit comments or new
issues. Wait for explicit authorization for that posting step unless
already supplied for the commissioned audit. Refresh
revisions/discussions and deduplicate before posting; confirm writes
succeeded. Use concise dated reassessments with pinned evidence,
practical consequence and next step. Provide public synthetic
reproducers where needed; never publish private conversations or archive
links.

Preparing drafts, posting findings, installing tests, changing behavior
and activating CI are distinct actions. Follow the maintainer’s
permissions and per-file behavior-change approval rules. Do not close
issues, formally approve or merge PRs, delete branches or change
automation under this protocol. Automatic Claude review remains governed
by its external configuration; this protocol does not enable it.
