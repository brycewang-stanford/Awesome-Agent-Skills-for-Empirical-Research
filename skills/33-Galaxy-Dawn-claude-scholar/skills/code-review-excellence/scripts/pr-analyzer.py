#!/usr/bin/env python3
from __future__ import annotations

import argparse
import subprocess
from pathlib import Path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description='Summarize git diff size for review planning.')
    parser.add_argument('--repo', default='.', help='Repository path')
    parser.add_argument('--base', default='HEAD~1', help='Base revision')
    parser.add_argument('--head', default='HEAD', help='Head revision')
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    repo = Path(args.repo).resolve()
    result = subprocess.run(
        ['git', '-C', str(repo), 'diff', '--numstat', args.base, args.head],
        capture_output=True,
        text=True,
        check=False,
    )
    if result.returncode != 0:
        print(result.stderr.strip() or 'git diff failed')
        return result.returncode
    files = 0
    added = 0
    deleted = 0
    for line in result.stdout.splitlines():
        parts = line.split('	')
        if len(parts) != 3:
            continue
        a, d, _ = parts
        if a.isdigit():
            added += int(a)
        if d.isdigit():
            deleted += int(d)
        files += 1
    print(f'files={files}')
    print(f'added={added}')
    print(f'deleted={deleted}')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
