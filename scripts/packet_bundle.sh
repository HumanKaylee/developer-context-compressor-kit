#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "usage: $0 /path/to/repo [target-path ...]" >&2
}

if [ "${1-}" = "" ]; then
  usage
  exit 1
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="${1%/}"
shift || true

if [ ! -d "$repo_root" ]; then
  echo "repo root not found: $repo_root" >&2
  exit 1
fi

map_tmp="$(mktemp)"
trap 'rm -f "$map_tmp"' EXIT

"$script_dir/repo_map.sh" "$repo_root" >"$map_tmp"

cat "$map_tmp"
printf '\n'
"$script_dir/llm_handoff.sh" "$map_tmp"
printf '\n'
"$script_dir/change_risk.sh" "$repo_root" "$@"
