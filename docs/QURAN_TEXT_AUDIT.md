# Quran text comparison audit

Date: 2026-11-12

## Scope

Compared the 6,236 verse records in the bundled `mushaf_text` Hafs TSV asset
(`assets/mushaf/hafs.tsv`, package repository `sherifshabans/mushaf-text`)
against the Tanzil Uthmani text v1.1 reference file
(`acfatah/tanzil/data/quran-uthmani.txt`).

Tanzil identifies the text as Uthmani, version 1.1, and licenses it under
Creative Commons Attribution 3.0. Reference source:
https://github.com/acfatah/tanzil/blob/main/data/quran-uthmani.txt

## Result

- Tanzil reference verse records: 6,236
- Bundled package verse records: 6,236
- Unique (surah, ayah) keys in each: 6,236
- Missing verse keys: 0
- Differences in normalized Arabic letter sequence: 0

Normalization for this comparison removed Arabic diacritics and Quranic
annotation marks, removed tatweel and whitespace, and normalized common
Uthmani/Arabic letter presentation variants (alif forms, hamza-seat forms,
and alif maqsura). For surahs other than Al-Fatiha, the opening basmala was
removed from the reference verse before comparison because the bundled
Mushaf data represents the basmala separately from the first verse text.

## Important limitations

This is a structural and normalized-letter-sequence cross-check only. It
does **not** certify exact orthography, every haraka/diacritic, stop signs,
ayah markers, page breaks, line placement, or the rendered appearance.
Those require separate exact-script and visual checks against an authorized
Madinah Mushaf reference. No Quran text was edited as part of this audit.
