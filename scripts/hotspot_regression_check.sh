#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
venture_root="$(cd "$script_dir/.." && pwd)"
fixtures_root="$venture_root/fixtures"

assert_hotspot() {
  local repo_root="$1"
  local expected="$2"
  local actual=""

  if [ ! -d "$repo_root" ]; then
    echo "missing control sample: $repo_root" >&2
    exit 1
  fi

  actual="$("$script_dir/repo_map.sh" "$repo_root" \
    | awk '
        /^## Hotspots To Read First$/ { in_hotspots=1; next }
        in_hotspots && /^## / { exit }
        in_hotspots && /^- / { sub(/^- /, "", $0); print; exit }
      ')"

  if [ "$actual" != "$expected" ]; then
    echo "hotspot regression for $repo_root: expected $expected, got ${actual:-<none>}" >&2
    exit 1
  fi

  printf 'ok  %-60s -> %s\n' "$repo_root" "$actual"
}

assert_hotspot "$fixtures_root/package-dir" "boltons"
assert_hotspot "$fixtures_root/src-layout" "src"
assert_hotspot "$fixtures_root/shell-first" "scripts"
