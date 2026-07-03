#!/usr/bin/env bash
set -euo pipefail

if [ "${1-}" = "" ]; then
  echo "usage: $0 /path/to/repo" >&2
  exit 1
fi

repo_root="${1%/}"
if [ ! -d "$repo_root" ]; then
  echo "repo root not found: $repo_root" >&2
  exit 1
fi

repo_root="$(cd "$repo_root" && pwd)"

repo_name="$(basename "$repo_root")"
scanned_at="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

list_matches() {
  local root="$1"
  shift
  local matches=()
  local pattern
  for pattern in "$@"; do
    while IFS= read -r line; do
      matches+=("${line#$root/}")
    done < <(find "$root" -maxdepth 2 -type f -name "$pattern" 2>/dev/null | sort)
  done
  if [ "${#matches[@]}" -eq 0 ]; then
    echo "- none found"
    return
  fi
  printf '%s\n' "${matches[@]}" | awk '!seen[$0]++ { print "- " $0 }'
}

top_dirs() {
  local root="$1"
  find "$root" -mindepth 1 -maxdepth 1 -type d 2>/dev/null \
    | sort \
    | sed "s#^$root/##" \
    | grep -Ev '^[.]|^C:|^Jane_Reports$|^_test-artifacts$|^tmp$|^backups$' \
    | sed 's#^#- #'
}

hotspots() {
  local root="$1"
  local name
  local emitted=0
  local source_first=0
  local package_like=""
  for name in src lib app crates pkg; do
    if [ -d "$root/$name" ]; then
      source_first=1
      break
    fi
  done
  if [ "$source_first" -eq 1 ]; then
    for name in src lib app crates pkg tests test __tests__ spec specs docs; do
      if [ -d "$root/$name" ]; then
        echo "- $name"
        emitted=1
      fi
    done
  else
    while IFS= read -r package_like; do
      [ -n "$package_like" ] || continue
      echo "- $package_like"
      emitted=1
    done < <(
      find "$root" -mindepth 1 -maxdepth 1 -type d 2>/dev/null \
        | sort \
        | sed "s#^$root/##" \
        | grep -Ev '^[.]|^(docs|doc|tests|test|__tests__|spec|specs|misc|examples|example|vendor|dist|build|coverage|tmp|backups|program-docs|ventures|scripts|memory|logs|config|tools)$' \
        | while IFS= read -r topdir; do
            if find "$root/$topdir" -maxdepth 2 -type f \( -name '*.py' -o -name '*.rs' -o -name '*.js' -o -name '*.ts' -o -name '*.tsx' -o -name '*.jsx' -o -name '*.go' -o -name '*.java' -o -name '*.rb' -o -name '*.php' -o -name '*.sh' \) 2>/dev/null | grep -q .; then
              echo "$topdir"
            fi
          done
    )
    for name in tests test __tests__ spec specs docs; do
      if [ -d "$root/$name" ]; then
        echo "- $name"
        emitted=1
      fi
    done
  fi
  for name in program-docs ventures scripts docs memory logs config tools; do
    if [ -d "$root/$name" ] && ! { [ "$name" = "docs" ] && [ "$source_first" -eq 1 -o "$emitted" -eq 1 ]; }; then
      echo "- $name"
      emitted=1
    fi
  done
  if [ "$emitted" -eq 0 ]; then
    top_dirs "$root" | head -n 8
  fi
}

guess_commands() {
  local root="$1"
  local emitted=0
  if [ -f "$root/package.json" ]; then
    echo "- Node package detected: try \`npm test\`, \`npm run build\`, or inspect package.json scripts"
    emitted=1
  fi
  if [ -f "$root/pyproject.toml" ] || [ -f "$root/requirements.txt" ]; then
    echo "- Python project detected: try \`pytest\` or inspect \`pyproject.toml\` / test config"
    emitted=1
  fi
  if [ -f "$root/Cargo.toml" ]; then
    echo "- Rust project detected: try \`cargo test\` and \`cargo build\`"
    emitted=1
  fi
  if [ -f "$root/Makefile" ]; then
    echo "- Makefile detected: inspect \`make help\` or the default targets"
    emitted=1
  fi
  if [ -f "$root/docker-compose.yml" ] || [ -f "$root/docker-compose.yaml" ]; then
    echo "- Docker Compose detected: inspect compose services before local start-up"
    emitted=1
  fi
  if [ "$emitted" -eq 0 ]; then
    echo "- No obvious root-level build/test command detected from the shallow scan"
  fi
}

unknowns() {
  local root="$1"
  local emitted=0
  if [ ! -f "$root/README.md" ] && [ ! -f "$root/readme.md" ]; then
    echo "- No top-level README found"
    emitted=1
  fi
  if [ ! -d "$root/tests" ] && ! find "$root" -maxdepth 2 -type d \( -name test -o -name tests -o -name __tests__ \) | grep -q .; then
    echo "- No obvious dedicated test directory found in the first two levels"
    emitted=1
  fi
  if [ "$emitted" -eq 0 ]; then
    echo "- No immediate structural unknowns from the shallow scan"
  fi
}

orientation_files() {
  local root="$1"
  local root_docs=""
  local program_docs=""
  root_docs="$(list_matches "$root" "README.md" "readme.md" "AGENTS.md" "TOOLS.md" "USER.md" "SOUL.md" "CONTRIBUTING.md" "PRD.md" 2>/dev/null | grep -v '^- none found$' | grep -Ev '^- \\.' || true)"
  if [ -d "$root/program-docs" ]; then
    program_docs="$(list_matches "$root/program-docs" "ROADMAP.md" "BACKLOG.md" "ARCHITECTURE.md" 2>/dev/null | grep -v '^- none found$' | grep -Ev '^- \\.' || true)"
  fi
  if [ -n "$root_docs" ] && [ -n "$program_docs" ]; then
    printf '%s\n%s\n' "$root_docs" "$program_docs"
    return
  fi
  if [ -n "$root_docs" ]; then
    printf '%s\n' "$root_docs"
    return
  fi
  if [ -n "$program_docs" ]; then
    printf '%s\n' "$program_docs"
    return
  fi
  echo "- none found"
}

cat <<EOF
# Project Map

- Repo: \`$repo_name\`
- Root: \`$repo_root\`
- Scanned: \`$scanned_at\`

## Top-Level Directories
$(top_dirs "$repo_root")

## Likely Entrypoints And Build Files
$(list_matches "$repo_root" "package.json" "pyproject.toml" "Cargo.toml" "Makefile" "docker-compose.yml" "docker-compose.yaml" ".env.example")

## Docs And Orientation Files
$(orientation_files "$repo_root")

## Likely Commands
$(guess_commands "$repo_root")

## Hotspots To Read First
$(hotspots "$repo_root")

## Unknowns
$(unknowns "$repo_root")
EOF
