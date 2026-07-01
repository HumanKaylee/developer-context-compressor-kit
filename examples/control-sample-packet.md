# Project Map

- Repo: `developer-context-compressor-kit`
- Root: `<repo-root>`
- Scanned: `<redacted-ts>`

## Top-Level Directories
- notes
- scripts
- templates

## Likely Entrypoints And Build Files
- none found

## Docs And Orientation Files
- README.md
- PRD.md

## Likely Commands
- No obvious root-level build/test command detected from the shallow scan

## Hotspots To Read First
- scripts

## Unknowns
- No obvious dedicated test directory found in the first two levels

# LLM Handoff

## Task Framing
- Repo: `developer-context-compressor-kit`
- Root: `<repo-root>`
- Derived from project map scanned at: `<redacted-ts>`
- Goal: provide a bounded orientation brief before code review, bug fixing, or feature work.

## Repo Orientation
### Likely Entrypoints And Build Files
- none found

### Docs And Orientation Files
- README.md
- PRD.md

### Likely Commands
- No obvious root-level build/test command detected from the shallow scan

## Safe-First Reading Order
- scripts

## Likely Traps
- No obvious dedicated test directory found in the first two levels

## Open Questions
- Confirm whether the shallow scan missed nested test/config entrypoints before making broad changes.
- Verify the actual task against the repo's build/test workflow instead of assuming the generic command hints are correct.
- Inspect adjacent docs and release/process files before editing public or operator-facing surfaces.

# Change Risk

## Task Framing
- Repo: `developer-context-compressor-kit`
- Root: `<repo-root>`
- Scanned: `<redacted-ts>`

## Target Paths
- No explicit target paths provided; this is a repo-level pre-change risk pass.

## Affected Surfaces
- README.md
- scripts/

## Dependency Risks
- No obvious dependency surface detected from the shallow repo scan.

## Test Expectations
- No obvious automated test entrypoint detected; require a manual verification note if a change lands.

## Rollback Notes
- If behavior changes, update adjacent docs in the same patch or explicitly note the drift.
- Re-run this script plus the repo's narrowest build/test check before and after the change to confirm blast radius stayed bounded.
