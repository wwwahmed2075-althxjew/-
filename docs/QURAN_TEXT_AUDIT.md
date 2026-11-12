# Quran text and page-layout audit

Date: 2026-11-12

## Text comparison against KFGQPC Hafs data

Compared all 6,236 ayah records in the app's bundled `mushaf_text` source
(`hafs.tsv`) against the KFGQPC Hafs Unicode data mirror
(`thetruetruth/quran-data-kfgqpc/hafs/data/hafsData_v18.csv`).

The mirror identifies its source as King Fahd Glorious Quran Printing Complex
(KFGQPC), Hafs Uthmanic data version 0.18, dated 2021-10-25. The official
KFGQPC developer platform describes the same database fields: surah, ayah,
page, line start/end, and Uthmanic Hafs Unicode text:
https://qurancomplex.gov.sa/quran-dev/

Results:
- KFGQPC reference records: 6,236
- Bundled records: 6,236
- Unique (surah, ayah) keys in both: 6,236
- Missing or extra verse keys: 0
- All 6,236 verse texts match after Unicode NFC and one presentation-form
  normalization: final alif-maqsura `ى` versus yeh `ي`.
- All 6,236 line_start and line_end values match the KFGQPC v18 reference.
- No Quran text was edited.

This resolves the earlier 15 residual text differences: they were caused by
comparing different Unicode representations, not by missing or different
verse wording. Do not describe them as 15 Quran text errors.

## Page-number discrepancies found

The bundled `hafs.tsv` page field does **not** match the KFGQPC v18 page field
for 56 ayahs across 36 pages. The differing ayah keys are:

5:77, 5:83, 5:90, 6:131, 55:17, 55:18, 55:41, 55:68, 55:69,
68:16, 69:35, 70:40, 74:18, 79:16, 80:41, 80:42, 83:5, 83:6,
83:34, 84:25, 87:11, 87:12, 87:13, 87:14, 87:15, 88:23,
88:24, 88:25, 88:26, 89:23, 90:19, 90:20, 92:10, 92:11,
92:12, 92:13, 92:14, 94:3, 94:4, 94:5, 94:6, 94:7, 94:8,
96:13, 96:14, 96:15, 96:16, 96:17, 96:18, 96:19, 98:6,
98:7, 100:6, 100:7, 100:8, 100:9.

Independent page-level cross-checks against the KFGQPC V2 (1421H) page
layout mirror in `manaf/KFGQPC-Madinah-Mushaf` confirm concrete examples:
- Page 120 includes 5:77 (lines 13-15), but the bundled page assignment puts
  5:77 on page 121.
- Page 531 includes 55:17-18 (lines 14-15), but the bundled page assignment
  puts them on page 532.
- The same mirror contains 604 distinct page JSON records. It is a QUL-derived
  layout mirror, not the KFGQPC publisher's own distribution endpoint.

The package's own `layout.txt` is internally consistent with its own
`hafs.tsv`, but that internal test does not independently validate the
printed page mapping. Its line token counts also differ from the independent
QUL page JSON for pages such as 5, 120, and 531. For page 120, the QUL layout
has line token counts
`11,9,12,9,9,10,11,9,9,12,9,12,11,11,12`, while the bundled layout has
`9,9,9,8,11,8,10,10,8,7,10,6,8,9,10`.

## Status and safety decision

- Text completeness and normalized text parity: verified against KFGQPC v18.
- Surah/ayah key completeness: verified (6,236/6,236).
- Existing 604-page layout asset: internally complete, but independent page
  and line-layout parity is **not yet verified**.
- The 56 page-number discrepancies and page-line differences remain unresolved.
- No page mapping, line layout, or Quran text was changed as part of this audit.
- Do not release or claim the Mushaf is fully verified until page-to-word
  layout has been corrected and checked against a trusted edition-matched
  reference, including every page, line, ayah marker, and waqf sign.

## Sources and limitations

- KFGQPC developer platform: https://qurancomplex.gov.sa/quran-dev/
- KFGQPC Hafs v18 data mirror: https://github.com/thetruetruth/quran-data-kfgqpc
- KFGQPC V2 1421H layout mirror (QUL-derived): https://github.com/manaf/KFGQPC-Madinah-Mushaf
- KFGQPC describes its Hafs Unicode data as a digital representation for
  Uthmanic text; the publisher also distinguishes the smart-device font,
  intended for verse-level display, from full-page typesetting.
- The mirrors are useful for reproducible comparison but do not replace a
  final visual review against the official printed edition.
