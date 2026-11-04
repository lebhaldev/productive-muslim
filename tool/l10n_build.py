#!/usr/bin/env python3
"""Builds assets/l10n/<code>.json from tool/l10n/<code>.txt.

Each .txt has one line per key in tool/l10n_keys.txt (same order); `=` keeps
the English. Extra keys (built at runtime, e.g. mood names) follow after a
line `---` as `English = translation`. Fails if the line count or the
{0}, {1}… placeholders do not match.
"""
import json
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
keys = (ROOT / 'tool/l10n_keys.txt').read_text(encoding='utf-8').splitlines()
ok = True
for src in sorted((ROOT / 'tool/l10n').glob('*.txt')):
    lines = src.read_text(encoding='utf-8').split('\n')
    if lines and lines[-1] == '':
        lines.pop()
    extra = []
    if '---' in lines:
        i = lines.index('---')
        lines, extra = lines[:i], lines[i + 1:]
    if len(lines) != len(keys):
        print(f'{src.name}: {len(lines)} lines for {len(keys)} keys')
        ok = False
        continue
    out = {}
    pairs = list(zip(keys, lines))
    for e in extra:
        if ' = ' in e:
            a, b = e.split(' = ', 1)
            pairs.append((a, b))
    for en, t in pairs:
        t = t.strip()
        if not t or t == '=' or t == en:
            continue
        if sorted(re.findall(r'\{\d\}', en)) != sorted(re.findall(r'\{\d\}', t)):
            print(f'{src.name}: placeholders differ for "{en}" -> "{t}"')
            ok = False
        out[en] = t
    (ROOT / f'assets/l10n/{src.stem}.json').write_text(
        json.dumps(out, ensure_ascii=False, indent=1, sort_keys=True) + '\n',
        encoding='utf-8')
    print(f'{src.stem}: {len(out)} strings')
sys.exit(0 if ok else 1)
