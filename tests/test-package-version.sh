#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

assert_output() {
  local input="$1"
  local expected="$2"
  local actual
  actual="$("$repo_root/scripts/package-version.sh" "$input")"
  if [[ "$actual" != "$expected" ]]; then
    printf 'unexpected output for %s:\n%s\n' "$input" "$actual" >&2
    exit 1
  fi
}

assert_output '1:0.3.3' $'epoch=1\npkgver=0.3.3\ntag=v0.3.3\nraw_version=1:0.3.3'
assert_output '0.5.1-1770967312' $'epoch=0\npkgver=0.5.1_1770967312\ntag=v0.5.1_1770967312\nraw_version=0.5.1-1770967312'
assert_output '2:0.5~beta1' $'epoch=2\npkgver=0.5_beta1\ntag=v0.5_beta1\nraw_version=2:0.5~beta1'

if "$repo_root/scripts/package-version.sh" 'broken version' >/dev/null 2>&1; then
  printf 'invalid versions must fail\n' >&2
  exit 1
fi

printf 'package-version tests passed\n'
