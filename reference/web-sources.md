# Official sources and access

Checked 2026-11-15. This is a source map, not a claim that every linked document
has been read or that current definitions apply to historical releases.

## Researcher's Guide and appendices

[NIDDK Researcher's Guide landing page](https://www.niddk.nih.gov/about-niddk/strategic-plans-reports/usrds/for-researchers/researchers-guide)
lists the 2025 Guide (PDF), Appendix B (file descriptions, XLSX) and Appendix C
(formats, XLSX). The page was inspected; the underlying documents have not been
comprehensively audited for this reference-infrastructure change.

- Guide: source organization, eligibility, file relationships and methods.
- Appendix B: exact file and variable layouts; preserve worksheet/row locators.
- Appendix C: formats and code meanings; connect the format to the applicable
  variable rather than matching a label by appearance.

Project reference names are `USRDS_Researcher_Guide_2025_text.md`,
`USRDS_Appendix_B_2025_text.md` and `USRDS_Appendix_C_2025_text.md`. Availability
is environment-dependent: only Appendix B was supplied in the working session
that created this map. Its header identifies a worksheet transcription with
original row/column coordinates, JSON-encoded values and merged-cell anchors.
Those escapes are not necessarily corruption. Consult the original workbook
for ambiguous layout or merged headings. Do not assume another reviewer has
these uploads, and do not copy private storage paths into source citations.

For historical work, locate the matching edition. The
[2024 Guide](https://www.niddk.nih.gov/-/media/Files/USRDS/For-Researchers/2024/USRDS_Researcher_Guide_2024.pdf)
is a separate source, not a substitute for older dictionaries. Search retrieval
exposed its Table 2 descriptions; the full document was not read here.

## Registry membership and claims availability

[NIDDK USRDS FAQ](https://www.niddk.nih.gov/about-niddk/strategic-plans-reports/usrds/about-usrds),
questions on registry and SAF inclusion, distinguishes broad ESRD registry
membership from fee-for-service claims availability. Assess coverage for the
specific file, era and observation window; insurance at a single index date
does not establish a complete lookback or continued claims observation.

## ADR methods

Use the Methods chapter associated with the ADR year and volume being
reproduced, reached through the [USRDS site](https://www.niddk.nih.gov/about-niddk/strategic-plans-reports/usrds).
No ADR chapter was fully read for this infrastructure draft. Before adopting an
ADR convention, record its year, population, denominator, modality and payer
rules, time origin and censoring, and payment/inflation perspective as relevant.
Keep a paper's adaptations distinct from the ADR's original convention.

## Full-text access routes

The manuscript catalog links NCBI PMC and Europe PMC. Europe PMC search provides
bibliographic metadata; NCBI BioC can provide main text and text tables. Access
depends on article permissions and service behavior. XML not available, HTTP
429, timeout and verification pages are different outcomes. Retry politely or
use another authorized route, and distinguish retrieval from reading. Do not
infer that a supplement was read from the presence of its link.
