# Quran text comparison audit

Date: 2026-11-12

## Scope

Compared all 6,236 verse records in the bundled `mushaf_text` Hafs TSV asset
(`flutter/assets/mushaf/hafs.tsv`, package repository `sherifshabans/mushaf-text`)
against the Tanzil Uthmani text v1.1 reference file
(`acfatah/tanzil/data/quran-uthmani.txt`).

Tanzil identifies the text as Uthmani, version 1.1, under Creative Commons
Attribution 3.0. Reference:
https://github.com/acfatah/tanzil/blob/main/data/quran-uthmani.txt

## Record and key integrity

- Tanzil reference verse records: 6,236
- Bundled package verse records: 6,236
- Unique (surah, ayah) keys in each: 6,236
- Missing verse keys: 0

## Normalized comparison

A stricter normalization was applied to both texts: Unicode NFC normalization;
removal of combining diacritic and Quranic annotation marks, tatweel, and
whitespace; and narrowly specified normalization of common alif/hamza
presentation forms. The opening basmala was removed from Tanzil verses for
surahs 2–114 because the bundled data stores the basmala separately.

Result:
- Verses equal after this normalization: 6,221
- Verses still differing after normalization: 15

The 15 remaining verse keys are:
10:15, 16:90, 17:7, 20:130, 24:11, 28:30, 30:8, 30:16,
35:43, 42:51, 52:21, 56:23, 70:38, 74:52, 80:37.

The differences observed are concentrated in Uthmani hamza forms and
orthographic presentation (for example, hamza carried by alif versus a
separate hamza form, and differing encodings of hamza-bearing letters).
This automated comparison does not establish which representation is correct
for the intended Madinah Mushaf edition. These 15 locations require review
against a trusted, edition-matched Madinah Mushaf reference before any edit.

## Important limitations

This comparison does **not** certify exact Uthmani orthography, every haraka
or small sign, stop signs, ayah markers, page breaks, line placement, or
rendered appearance. It is not a substitute for a page-by-page comparison
against an authorized Madinah Mushaf reference. No Quran text was edited
during this audit.

A previous broader normalization reported zero differences because it
collapsed hamza distinctions too aggressively. That result is superseded by
the stricter result above; do not rely on the earlier zero-difference claim.
