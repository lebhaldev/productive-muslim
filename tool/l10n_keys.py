#!/usr/bin/env python3
"""Lists every English interface string in lib/ (the keys of
assets/l10n/<code>.json) and reports, per language, which are missing.

  python3 tool/l10n_keys.py            # report
  python3 tool/l10n_keys.py --write    # also write tool/l10n_keys.txt
"""
import json
import pathlib
import re
import sys

sys.path.insert(0, str(pathlib.Path(__file__).parent))
from l10n_wrap import read_literal, is_ui, template  # noqa: E402

ROOT = pathlib.Path(__file__).resolve().parent.parent
SKIP = re.compile(r'(fontFamily|family|heading|body|Key|ValueKey|import|'
                  r'putSetting|raw\[|settings\[|startsWith|endsWith|contains|'
                  r'jsonDecode|toString|assert|debugPrint|throw\s+StateError)\s*[(:]?\s*$')


def keys_in(src):
    found = set()
    i = 0
    while True:
        m = re.search(r'[\'"]', src[i:])
        if not m:
            return found
        start = i + m.start()
        lit = read_literal(src, start)
        if not lit:
            i = start + 1
            continue
        parts, end = lit
        before = src[max(0, start - 40):start]
        in_tr = re.search(r'\b(tr|Tr)\(\s*$', before)
        if in_tr or (is_ui(parts) and not SKIP.search(before)):
            if in_tr or all(t == 'text' for t, _ in parts):
                key, _ = template(parts)
                found.add(key.replace("\\'", "'").replace('\\"', '"'))
        i = end


JUNK = re.compile(r'^([A-Z]{1,3}|[EMHdy :]+|[A-Z][a-z]+[A-Z]\w*|PRAGMA .*|Content-Type.*|'
                  r'Authorization|SOFT|Bearer .*)$')


def all_keys():
    keys = set()
    for f in (ROOT / 'lib').rglob('*.dart'):
        if 'l10n' in f.parts or f.name.endswith('.g.dart'):
            continue
        keys |= keys_in(f.read_text(encoding='utf-8'))
    return sorted(k for k in keys if not JUNK.match(k))


if __name__ == '__main__':
    keys = all_keys()
    print(len(keys), 'keys')
    if '--write' in sys.argv:
        (ROOT / 'tool/l10n_keys.txt').write_text('\n'.join(keys) + '\n')
    for f in sorted((ROOT / 'assets/l10n').glob('*.json')):
        have = json.loads(f.read_text(encoding='utf-8'))
        missing = [k for k in keys if k not in have]
        print(f'{f.stem}: {len(have)} strings, {len(missing)} missing')
