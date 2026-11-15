# USRDS manuscript collection

**Target: 100 original full-manuscript reads and annotations. This collection is in progress.**
Count completed annotations from the accepted batch indexes; neither a search hit nor a downloaded article counts as read. Each annotation contains its own status, date, source locators and unread-material limits.

Start with [batch 01](manuscript-batches/batch-01.md). Additional independently reviewable batches appear in [manuscript-batches/](manuscript-batches/), with individual notes in [manuscripts/](manuscripts/). Each batch owns different files, so reviewers can amend one batch without changing a shared status table. A consolidated 100-paper index will be reconciled after the selected annotations are complete.

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
