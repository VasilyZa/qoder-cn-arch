#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 || -z "$1" ]]; then
  printf 'usage: %s DEBIAN_VERSION\n' "$0" >&2
  exit 64
fi

raw_version="$1"
epoch=0
pkgver="$raw_version"

if [[ "$pkgver" == *:* ]]; then
  epoch="${pkgver%%:*}"
  pkgver="${pkgver#*:}"
fi

pkgver="${pkgver//-/_}"
pkgver="${pkgver//\~/_}"

if [[ ! "$epoch" =~ ^[0-9]+$ || ! "$pkgver" =~ ^[A-Za-z0-9][A-Za-z0-9.+_]*$ ]]; then
  printf 'unsupported Debian version: %s\n' "$raw_version" >&2
  exit 65
fi

printf 'epoch=%s\n' "$epoch"
printf 'pkgver=%s\n' "$pkgver"
printf 'tag=v%s\n' "$pkgver"
printf 'raw_version=%s\n' "$raw_version"
