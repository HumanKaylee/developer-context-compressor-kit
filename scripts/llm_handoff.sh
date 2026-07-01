#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "usage: $0 /path/to/project-map.md" >&2
  echo "   or: repo_map.sh /path/to/repo | $0 -" >&2
}

if [ "${1-}" = "" ]; then
  usage
  exit 1
fi

input="${1-}"
if [ "$input" = "-" ]; then
  map_content="$(cat)"
elif [ -f "$input" ]; then
  map_content="$(cat "$input")"
else
  echo "project map not found: $input" >&2
  exit 1
fi

trim_blank_lines() {
  awk '
    BEGIN { blank = 0 }
    {
      if ($0 ~ /^[[:space:]]*$/) {
        if (blank == 0) print ""
        blank = 1
        next
      }
      blank = 0
      print
    }
  ' | sed '/./,$!d'
}

section_body() {
  local heading="$1"
  printf '%s\n' "$map_content" | awk -v heading="$heading" '
    $0 == heading { in_section = 1; next }
    /^## / && in_section { exit }
    in_section { print }
  ' | trim_blank_lines
}

repo_line="$(printf '%s\n' "$map_content" | awk -F'`' '/^- Repo: / { print $2; exit }')"
root_line="$(printf '%s\n' "$map_content" | awk -F'`' '/^- Root: / { print $2; exit }')"
scanned_line="$(printf '%s\n' "$map_content" | awk -F'`' '/^- Scanned: / { print $2; exit }')"

entrypoints="$(section_body '## Likely Entrypoints And Build Files')"
docs="$(section_body '## Docs And Orientation Files')"
commands="$(section_body '## Likely Commands')"
hotspots="$(section_body '## Hotspots To Read First')"
unknowns="$(section_body '## Unknowns')"

[ -n "$entrypoints" ] || entrypoints="- none found"
[ -n "$docs" ] || docs="- none found"
[ -n "$commands" ] || commands="- none found"
[ -n "$hotspots" ] || hotspots="- none found"
[ -n "$unknowns" ] || unknowns="- none found"

cat <<EOF
# LLM Handoff

## Task Framing
- Repo: \`${repo_line:-unknown}\`
- Root: \`${root_line:-unknown}\`
- Derived from project map scanned at: \`${scanned_line:-unknown}\`
- Goal: provide a bounded orientation brief before code review, bug fixing, or feature work.

## Repo Orientation
### Likely Entrypoints And Build Files
$entrypoints

### Docs And Orientation Files
$docs

### Likely Commands
$commands

## Safe-First Reading Order
$hotspots

## Likely Traps
$unknowns

## Open Questions
- Confirm whether the shallow scan missed nested test/config entrypoints before making broad changes.
- Verify the actual task against the repo's build/test workflow instead of assuming the generic command hints are correct.
- Inspect adjacent docs and release/process files before editing public or operator-facing surfaces.
EOF
