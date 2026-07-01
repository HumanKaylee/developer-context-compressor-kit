#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "usage: $0 /path/to/repo [target-path ...]" >&2
}

if [ "${1-}" = "" ]; then
  usage
  exit 1
fi

repo_root="${1%/}"
shift || true

if [ ! -d "$repo_root" ]; then
  echo "repo root not found: $repo_root" >&2
  exit 1
fi

repo_name="$(basename "$repo_root")"
scanned_at="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
targets=("$@")

rel_path() {
  local path="$1"
  case "$path" in
    "$repo_root"/*) printf '%s\n' "${path#$repo_root/}" ;;
    *) printf '%s\n' "$path" ;;
  esac
}

find_first_existing() {
  local path
  for path in "$@"; do
    if [ -e "$path" ]; then
      printf '%s\n' "$path"
      return 0
    fi
  done
  return 1
}

target_summary() {
  if [ "${#targets[@]}" -eq 0 ]; then
    echo "- No explicit target paths provided; this is a repo-level pre-change risk pass."
    return
  fi

  local target abs
  for target in "${targets[@]}"; do
    if [ -e "$repo_root/$target" ]; then
      abs="$repo_root/$target"
    elif [ -e "$target" ]; then
      abs="$target"
    else
      echo "- $target (missing; verify path before editing)"
      continue
    fi

    if [ -d "$abs" ]; then
      echo "- $(rel_path "$abs")/ (directory target)"
    else
      echo "- $(rel_path "$abs")"
    fi
  done
}

affected_surfaces() {
  if [ "${#targets[@]}" -eq 0 ]; then
    local entry
    for entry in README.md package.json pyproject.toml Cargo.toml Makefile docs scripts src tests; do
      if [ -e "$repo_root/$entry" ]; then
        if [ -d "$repo_root/$entry" ]; then
          echo "- $entry/"
        else
          echo "- $entry"
        fi
      fi
    done
    return
  fi

  local target abs parent
  for target in "${targets[@]}"; do
    if [ -e "$repo_root/$target" ]; then
      abs="$repo_root/$target"
    elif [ -e "$target" ]; then
      abs="$target"
    else
      continue
    fi

    parent="$(dirname "$abs")"
    echo "- primary: $(rel_path "$abs")"
    if [ "$parent" != "$repo_root" ] && [ "$parent" != "$abs" ]; then
      echo "- adjacent dir: $(rel_path "$parent")/"
    fi
  done | awk '!seen[$0]++'
}

dependency_risks() {
  local emitted=0
  local match
  match="$(find_first_existing "$repo_root/package.json" "$repo_root/pyproject.toml" "$repo_root/requirements.txt" "$repo_root/Cargo.toml" "$repo_root/Makefile")" || true
  if [ -n "${match:-}" ]; then
    echo "- Build/test entrypoint present: $(rel_path "$match"); confirm whether the target change crosses that workflow."
    emitted=1
  fi

  match="$(find_first_existing "$repo_root/docker-compose.yml" "$repo_root/docker-compose.yaml" "$repo_root/.github/workflows")" || true
  if [ -n "${match:-}" ]; then
    echo "- Automation surface present: $(rel_path "$match"); check for CI/runtime assumptions before editing."
    emitted=1
  fi

  if [ "${#targets[@]}" -gt 0 ]; then
    echo "- Target-specific imports/callers are not traced automatically; use rg on the named paths before broad refactors."
    emitted=1
  fi

  if [ "$emitted" -eq 0 ]; then
    echo "- No obvious dependency surface detected from the shallow repo scan."
  fi
}

test_expectations() {
  local emitted=0
  if [ -d "$repo_root/tests" ] || find "$repo_root" -maxdepth 2 -type d \( -name test -o -name tests -o -name __tests__ \) | grep -q .; then
    echo "- A dedicated test directory exists; run the narrowest relevant test slice after changes."
    emitted=1
  fi
  if [ -f "$repo_root/package.json" ]; then
    echo "- Inspect package.json scripts before claiming a JS/TS change is safe."
    emitted=1
  fi
  if [ -f "$repo_root/pyproject.toml" ] || [ -f "$repo_root/requirements.txt" ]; then
    echo "- Inspect Python test/lint config before claiming a Python change is safe."
    emitted=1
  fi
  if [ -f "$repo_root/Cargo.toml" ]; then
    echo "- Run cargo build/test if touching Rust code or manifests."
    emitted=1
  fi
  if [ "$emitted" -eq 0 ]; then
    echo "- No obvious automated test entrypoint detected; require a manual verification note if a change lands."
  fi
}

rollback_notes() {
  if [ "${#targets[@]}" -gt 0 ]; then
    echo "- Keep the edit scoped to the listed targets so a single-file revert or patch is possible."
  fi
  if [ -d "$repo_root/docs" ] || [ -f "$repo_root/README.md" ]; then
    echo "- If behavior changes, update adjacent docs in the same patch or explicitly note the drift."
  fi
  echo "- Re-run this script plus the repo's narrowest build/test check before and after the change to confirm blast radius stayed bounded."
}

cat <<EOF
# Change Risk

## Task Framing
- Repo: \`$repo_name\`
- Root: \`$repo_root\`
- Scanned: \`$scanned_at\`

## Target Paths
$(target_summary)

## Affected Surfaces
$(affected_surfaces)

## Dependency Risks
$(dependency_risks)

## Test Expectations
$(test_expectations)

## Rollback Notes
$(rollback_notes)
EOF
