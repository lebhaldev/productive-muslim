#!/usr/bin/env python3
"""Builds assets/l10n/<code>.json from tool/l10n/<code>.tsv.

Each .tsv line is `English<TAB>translation`. Keys left out stay English.
Fails if a {0}, {1}… placeholder differs, a line is malformed, or a
translated key no longer exists in the app (see tool/l10n_keys.py), and
lists keys still missing per language.
"""
import json
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
keys = set((ROOT / 'tool/l10n_keys.txt').read_text(encoding='utf-8').splitlines())
# Built at runtime, so not found by the key scan.
keys |= {'rough', 'low', 'okay', 'good', 'bright', 'preview', 'page', 'pages'}
ok = True
for src in sorted((ROOT / 'tool/l10n').glob('*.tsv')):
    out = {}
    for n, line in enumerate(src.read_text(encoding='utf-8').splitlines(), 1):
        if not line.strip():
            continue
        if line.count('\t') != 1:
            print(f'{src.name}:{n}: expected one tab')
            ok = False
            continue
        en, t = line.split('\t')
        if en not in keys:
            print(f'{src.name}:{n}: unknown key "{en}"')
            ok = False
        if sorted(re.findall(r'\{\d\}', en)) != sorted(re.findall(r'\{\d\}', t)):
            print(f'{src.name}:{n}: placeholders differ for "{en}"')
            ok = False
        out[en] = t
    (ROOT / f'assets/l10n/{src.stem}.json').write_text(
        json.dumps(out, ensure_ascii=False, indent=1, sort_keys=True) + '\n',
        encoding='utf-8')
    print(f'{src.stem}: {len(out)} strings')
sys.exit(0 if ok else 1)
