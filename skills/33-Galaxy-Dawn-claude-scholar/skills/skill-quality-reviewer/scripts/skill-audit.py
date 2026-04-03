#!/usr/bin/env python3
from __future__ import annotations

import argparse
import re
from pathlib import Path

REF_RE = re.compile(r'(references/[^\s)`]+|examples/[^\s)`]+|scripts/[^\s)`]+|assets/[^\s)`]+)')


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description='Audit a skill for missing local references and rough size metrics.')
    parser.add_argument('skill_path', help='Path to the skill directory')
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    root = Path(args.skill_path).expanduser().resolve()
    skill_md = root / 'SKILL.md'
    if not skill_md.exists():
        print('missing SKILL.md')
        return 1
    text = skill_md.read_text(encoding='utf-8')
    words = len(re.findall(r'\w+', text))
    print(f'word_count={words}')
    refs = sorted(set(match.rstrip('*:.,') for match in REF_RE.findall(text)))
    missing = [ref for ref in refs if not (root / ref).exists()]
    if missing:
        print('missing_refs=')
        for ref in missing:
            print(f'- {ref}')
    else:
        print('missing_refs=0')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
