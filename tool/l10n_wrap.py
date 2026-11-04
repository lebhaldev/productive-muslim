#!/usr/bin/env python3
"""Wraps literal English UI strings in Dart files for translation.

  Text('Hello')            -> Tr('Hello')
  Text('Hi $name')         -> Tr('Hi {0}', args: [name])
  tooltip: 'Back'          -> tooltip: tr('Back')

Only string literals that start with a letter and contain a space or start
with a capital are touched, so keys, routes and setting values stay as they
are. Run, then `flutter analyze`; tool/l10n_fix_const.py removes `const`
where a wrapped string made it invalid. Usage: l10n_wrap.py FILE...
"""
import re
import sys

NAMED = ('labelText', 'hintText', 'helperText', 'tooltip', 'semanticsLabel',
         'label', 'title', 'subtitle', 'content', 'message', 'text',
         'confirmText', 'cancelText', 'helpText', 'errorText')
TR_PARAMS = {'style', 'textAlign', 'maxLines', 'overflow', 'softWrap', 'key'}


def read_literal(s, i):
    """Reads adjacent Dart string literals starting at s[i]. Returns
    (parts, end) where parts is a list of ('text', str) / ('expr', str),
    or None if s[i] does not start a plain literal."""
    parts, j, seen = [], i, False
    while True:
        k = j
        while k < len(s) and s[k] in ' \t\n\r':
            k += 1
        if k >= len(s) or s[k] not in '\'"':
            break
        if s[k:k + 3] in ("'''", '"""'):
            return None
        q = s[k]
        k += 1
        buf = ''
        while True:
            if k >= len(s):
                return None
            c = s[k]
            if c == '\\':
                buf += s[k:k + 2]
                k += 2
            elif c == q:
                k += 1
                break
            elif c == '$':
                if buf:
                    parts.append(('text', buf))
                    buf = ''
                if s[k + 1] == '{':
                    depth, m = 1, k + 2
                    while depth:
                        if s[m] == '{':
                            depth += 1
                        elif s[m] == '}':
                            depth -= 1
                        m += 1
                    parts.append(('expr', s[k + 2:m - 1]))
                    k = m
                else:
                    m = k + 1
                    while m < len(s) and (s[m].isalnum() or s[m] == '_'):
                        m += 1
                    parts.append(('expr', s[k + 1:m]))
                    k = m
            elif c == '\n':
                return None
            else:
                buf += c
                k += 1
        if buf:
            parts.append(('text', buf))
        seen = True
        j = k
    return (parts, j) if seen else None


def is_ui(parts):
    text = ''.join(v for t, v in parts if t == 'text')
    if not re.search(r'[A-Za-z]', text):
        return False
    first = text.lstrip()
    if not first:
        return False
    return (' ' in text.strip() or first[0].isupper()) and not re.match(
        r'^(https?:|/|assets/|[a-z]+[A-Z]\w*$)', first)


def template(parts):
    key, args = '', []
    for t, v in parts:
        if t == 'text':
            key += v
        else:
            key += '{%d}' % len(args)
            args.append(v)
    return key, args


def quote(key):
    q = "'" if "'" not in key.replace("\\'", '') else '"'
    return q + key + q


def call_has_only(s, start):
    """True if the call whose args start at s[start] uses only Tr params."""
    depth, k, names = 1, start, []
    while depth and k < len(s):
        c = s[k]
        if c in '([{':
            depth += 1
        elif c in ')]}':
            depth -= 1
        elif depth == 1 and c == ',':
            m = re.match(r'\s*(\w+)\s*:', s[k + 1:])
            if m:
                names.append(m.group(1))
        k += 1
    return all(n in TR_PARAMS for n in names)


def process(src):
    out, i, n = [], 0, 0
    pat = re.compile(r'\bText\(|\b(%s)\s*:\s*' % '|'.join(NAMED))
    while True:
        m = pat.search(src, i)
        if not m:
            out.append(src[i:])
            break
        lit = read_literal(src, m.end())
        if not lit or not is_ui(lit[0]):
            out.append(src[i:m.end()])
            i = m.end()
            continue
        parts, end = lit
        key, args = template(parts)
        out.append(src[i:m.start()])
        if m.group(0).startswith('Text(') and call_has_only(src, end):
            arg = ', args: [%s]' % ', '.join(args) if args else ''
            out.append('Tr(' + quote(key) + arg)
        elif m.group(0).startswith('Text('):
            arg = ', [%s]' % ', '.join(args) if args else ''
            out.append('Text(tr(' + quote(key) + arg + ')')
        else:
            arg = ', [%s]' % ', '.join(args) if args else ''
            out.append(m.group(0) + 'tr(' + quote(key) + arg + ')')
        n += 1
        i = end
    return ''.join(out), n


IMPORT = "import 'package:nurday/l10n/strings.dart';"

if __name__ == '__main__':
    total = 0
    for path in sys.argv[1:]:
        src = open(path, encoding='utf-8').read()
        new, n = process(src)
        if n:
            if 'l10n/strings.dart' not in new:
                last = list(re.finditer(r"^import .*;$", new, re.M))[-1]
                new = new[:last.end()] + '\n' + IMPORT + new[last.end():]
            open(path, 'w', encoding='utf-8').write(new)
            print(f'{n:4d} {path}')
            total += n
    print(total, 'strings wrapped')
