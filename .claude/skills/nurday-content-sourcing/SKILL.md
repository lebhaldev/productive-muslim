---
name: nurday-content-sourcing
description: Rules and steps for any religious or quoted content in Nurday (ayah, translation, tafsir, hadith, grading, explanation, quotes). Use before adding, changing, explaining or displaying such content, or when a user asks for "explanations", "more hadith", "another translation" or similar.
---

# Content sourcing in Nurday

The one rule: **never make up religious content.** No ayah, translation, tafsir, hadith, grading, chain, explanation or attributed quote may be written, paraphrased, summarised or machine-translated by the app or by an agent. Everything shown is copied verbatim from a named source and credited. Rules live in `docs/01-functional-spec.md` (CR-1 … CR-8).

## Where content comes from today
| Content | Source | How it ships |
|---|---|---|
| Ayah Arabic + translation | AlQuran Cloud (`quran-uthmani` + `en.sahih`), Quran.com for Khattab | Fetched at runtime, cached in `content_cache` |
| Ayah pool | `assets/content/ayah_refs.json` (120 references only) | Bundled |
| Tafsir | Al-Muyassar (ar) and Al-Mukhtasar (en) from `spa5k/tafsir_api` (Quran.com / QUL mirror) | Bundled verbatim in `assets/content/tafsir.json` for the 120 refs |
| Hadith | `fawazahmed0/hadith-api`, Bukhari + Muslim, 120 reviewed | Bundled `assets/content/hadith.json` |
| Hadith explanation | **None available** that maps to our hadith | Card says so; do not fill the gap |
| Quotes | OpenITI corpus, Arabic only, 55 reviewed | Bundled `assets/content/quotes_ar.json` |

## Adding or extending a dataset
1. Find a published source with an explicit author/publisher and licence. Prefer datasets mirrored from Quran.com/QUL, sunnah.com or OpenITI.
2. Check reachability from the container: `raw.githubusercontent.com` works; most APIs (api.quran.com, alquran.cloud, hadeethenc.com, jsdelivr) are blocked by the proxy. If blocked, say so; do not guess API shapes or content.
3. Download with a script that asserts each record's reference matches what was requested (see how `tafsir.json` was built: per-ayah fetch, `assert surah/ayah`), and fail loudly on gaps.
4. Store with a `note` and `sources` block (name, author, url, dataset) next to the data. Credit it in `lib/features/settings/about_section.dart` and PRIVACY.md if it adds a network host.
5. Show the source name under the text in the UI.
6. Tests use **placeholder fixtures** only (`test/fixtures/*.json`, text like `[ fixture tafsir arabic ]`). `test/no_scripture_in_code_test.dart` fails if Arabic script or hadith text appears in `lib/`, so Arabic labels belong in assets, never in Dart code.
7. Update CR rules in `docs/01-functional-spec.md` and the CHANGELOG.

## When a user asks for something no source provides
Say plainly that no reliable source is available, show "No reviewed explanation is available …" in the UI, and offer to integrate a source the user names (for example HadeethEnc or Dorar for hadith explanations) on a machine that can reach it.
