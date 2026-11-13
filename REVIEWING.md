# Reviewing usRds

Shared standards for human, ChatGPT and Claude reviews. Read AGENTS.md too.
This file grants no posting, implementation, approval or merge permission.

## Policy revision and scope

For PR reviews, record the current target-branch SHA and read AGENTS.md and
REVIEWING.md at that revision. Proposed policy changes are reviewed under the
existing target policy, never their own proposed rules. For local reviews, use
committed policy at HEAD and assess uncommitted policy edits separately.
Implementation follows applicable working-branch and subdirectory guidance.

Begin with the reviewed copy, branch, exact commit, comparison scope and policy
revision. GitHub excludes unpushed work. If a local folder is connected, inspect
status, staged/unstaged diffs and relevant untracked source without modifying it.
Otherwise use an isolated GitHub copy; verify the actual default branch.

A PR/branch is compared with its target using the merge base. A named commit or
latest default-branch change is compared with its parent unless another scope
is requested; identify the parent for a merge commit. Whole-package reviews
cover the whole package. Follow-ups focus on changes since the previous reviewed
revision, retain full relevant context, and do not repeat resolved findings.
If history was rewritten, explain the revised comparison rather than assume
the earlier head is an ancestor.

## Procedure

1. Establish intent from the PR, milestone, linked issues and durable design
   records. Distinguish verified defects, validation gaps, methodological
   choices, intentional unfinished work and unrelated existing limitations.
   Read changed human-written code and relevant surrounding paths; identify
   omitted or truncated material. Reserve whole-package coverage for an
   explicitly whole-package review.
2. Trace downstream effects through callers, joins, returned objects and their
   attributes, tests, documentation and affected workflows. Evaluate whether
   a design fits existing APIs or duplicates functionality. Intentional,
   documented interface changes may be appropriate during development;
   accidental breakage is still a defect.
3. Derive edge cases independently of the implementation. Verify scientific
   claims against release-appropriate authoritative sources. A missing source
   is an evidence gap, not proof that a definition is wrong. Do not silently
   settle an unresolved methodological choice.
4. Evaluate tests and CI independently: passing checks can encode incorrect
   assumptions. Check expected values, mock boundaries, skips and whether a
   regression test detects the original bug. Inspect CI for the reviewed SHA;
   distinguish absent, pending, failed and passed checks. Do not equate a
   website build with a full package check.
5. Execute only safe, relevant synthetic checks in isolation after the startup
   and data-access inspection required by AGENTS.md. Never run live tests.
   Missing checks and dependency limitations must be reported without claiming
   execution based on someone else's report.
6. Reconcile previous findings against the current code and milestone. Identify
   partial fixes without repeating resolved findings or treating every open
   issue as a new regression. Assess other reviewers' claims rather than
   automatically accepting them.

## usRds-specific checks

- Identifier types/precision, leading zeros, join keys and row multiplication;
  patient-, episode-, encounter-, claim- and revenue-line aggregation.
- SAS/CSV/Parquet equivalence, column selection, dates and time units, file
  coverage and layouts across releases, duplicate format selection, partial
  years, cache scope and stale session state.
- Variable-specific missing codes, labels versus underlying codes, and absent
  required columns. Package metadata and converted tables are not infallible
  scientific authorities.
- ICD version and date applicability, code formatting, exact versus prefix
  matching, diagnosis/procedure positions and distinct-encounter rules.
- Eligibility and coverage intervals, claims completeness versus administrative
  follow-up, event/censoring boundaries, retransplants, row-varying baselines,
  cohort attributes and finalization state.
- Payment versus charge definitions, claim/revenue overlap, conservation under
  proration, partial windows, negative adjustments, missing values and inflation
  index direction/coverage. Preserve a named source for each monetary measure.
- Installation, exports/imports, dependency declarations, generated help
  consistency and affected vignettes. Check Windows paths, encoding, case,
  locale and line endings when relevant.
- Data provenance, live-test guards, permitted write destinations and the
  maintainer-only regeneration rule. Report uncertain data by path only;
  distinguish suspected exposure from established exposure.

## Reporting

Group actionable findings as **Must fix**, **Should fix**, or **Consider**,
omitting empty groups. Prioritize incorrect calculations, silent corruption,
broken installation/exports, unsafe data access and misleading claims.
Development stage does not excuse these. Documented unfinished work may be
acceptable for its milestone but must not be represented as complete or ready
to merge. Missing documentation or validation has severity proportional to its
impact, not an automatic severity solely from the file type.

For each finding give file and line, classification (verified defect, validation
gap or methodological decision), problem, practical impact and suggested fix.
Use focused snippets when helpful. Avoid stylistic nitpicks and unnecessary
arguments, abstractions or process. Missing generated help can be noted once
as unfinished work; a broken export or installation retains its actual severity.

Separate source inspection, personally executed synthetic checks (commands and
results), observed CI, author-reported validation and remaining real-data
validation. Synthetic checks establish code behavior, not validity on real
USRDS files. Provide exact maintainer validation commands when applicable,
including relevant vignette rebuilding. List material reference/runtime/coverage
limitations. Never reproduce private conversations or patient data.

End with a one-line verdict scoped to the reviewed changes. No findings does
not imply formal approval, comprehensive correctness or real-data validation.
