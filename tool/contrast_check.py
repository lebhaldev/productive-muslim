#!/usr/bin/env python3
"""WCAG contrast check for every Palette in lib/app/theme.dart.

Run: python3 tool/contrast_check.py   (exit 1 if any pair fails)
Text pairs need 4.5:1; the check mark on sage600 needs 3:1.
"""
import re
import sys
from pathlib import Path

src = Path(__file__).resolve().parent.parent / "lib/app/theme.dart"
text = src.read_text()

def lum(h):
    c = [int(h[i:i + 2], 16) / 255 for i in (0, 2, 4)]
    c = [x / 12.92 if x <= 0.03928 else ((x + 0.055) / 1.055) ** 2.4 for x in c]
    return 0.2126 * c[0] + 0.7152 * c[1] + 0.0722 * c[2]

def ratio(a, b):
    hi, lo = sorted([lum(a), lum(b)], reverse=True)
    return (hi + 0.05) / (lo + 0.05)

PAIRS = [  # (foreground, background, minimum)
    ("text", "bg", 4.5), ("text", "surface", 4.5), ("neutral700", "surface", 4.5),
    ("neutral700", "bg", 4.5), ("accent700", "surface", 4.5), ("onAccent", "accent700", 4.5),
    ("sage900", "sage200", 4.5), ("text", "sage300", 4.5), ("accent900", "accent200", 4.5),
    ("bg", "sage600", 3.0),
]

failed = False
for name, body in re.findall(r"static const (\w+) = Palette\((.*?)\n  \);", text, re.S):
    tokens = dict(re.findall(r"(\w+): Color\(0xFF([0-9A-Fa-f]{6})\)", body))
    bad = [f"{f}/{b} {ratio(tokens[f], tokens[b]):.2f}" for f, b, m in PAIRS
           if f in tokens and b in tokens and ratio(tokens[f], tokens[b]) < m]
    print(f"{name:14} {'OK' if not bad else 'FAIL ' + ', '.join(bad)}")
    failed |= bool(bad)
sys.exit(1 if failed else 0)
