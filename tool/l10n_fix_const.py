#!/usr/bin/env python3
"""Removes the `const` that encloses each "can't be invoked in constant
expressions" error from `flutter analyze` (after tool/l10n_wrap.py).
Usage: flutter analyze | python3 tool/l10n_fix_const.py"""
import re
import sys
from collections import defaultdict

errs = defaultdict(list)
for line in sys.stdin:
    m = re.search(r'const_eval_method_invocation|invalid_constant|'
                  r'const_with_non_constant_argument|non_constant', line)
    if not m:
        continue
    p = re.search(r'• (\S+\.dart):(\d+):(\d+) •', line)
    if p:
        errs[p.group(1)].append((int(p.group(2)), int(p.group(3))))


def span_end(s, open_idx):
    depth, k = 0, open_idx
    while k < len(s):
        if s[k] in '([{':
            depth += 1
        elif s[k] in ')]}':
            depth -= 1
            if depth == 0:
                return k
        k += 1
    return len(s)


for path, spots in errs.items():
    s = open(path, encoding='utf-8').read()
    lines = s.split('\n')
    offsets = []
    for ln, col in spots:
        offsets.append(sum(len(x) + 1 for x in lines[:ln - 1]) + col - 1)
    remove = set()
    for pos in offsets:
        for m in reversed(list(re.finditer(r'\bconst\s+', s[:pos]))):
            k = m.end()
            # Find the opening bracket of the const expression.
            b = re.search(r'[(\[{]', s[k:])
            if not b:
                continue
            o = k + b.start()
            if span_end(s, o) >= pos:
                remove.add((m.start(), m.end()))
                break
    for a, b in sorted(remove, reverse=True):
        s = s[:a] + s[b:]
    open(path, 'w', encoding='utf-8').write(s)
    print(len(remove), path)
