# Developer Context Compressor Kit

Local-first shell bundle for turning a repository into three bounded markdown artifacts:

1. `project-map.md`
2. `llm-handoff.md`
3. `change-risk.md`

## What It Does

- `scripts/repo_map.sh` scans a repo root and emits a shallow project map.
- `scripts/llm_handoff.sh` turns that map into an agent-ready orientation brief.
- `scripts/change_risk.sh` emits a bounded blast-radius and test checklist.
- `scripts/packet_bundle.sh` runs all three in one command.

## Quick Start

After cloning the public repo, enter it once:

```bash
cd developer-context-compressor-kit
```

Run the full packet on the cloned kit itself:

```bash
make bundle
```

Verify the shipped fixture-backed regression checks before using the kit on another repo:

```bash
make check
```

Run the packet on another repo:

```bash
./scripts/packet_bundle.sh /path/to/repo
```

Run the packet on another repo with explicit target paths for the change-risk section:

```bash
./scripts/packet_bundle.sh \
  /path/to/repo \
  path/to/file1 path/to/file2
```

Use that `packet_bundle.sh /path/to/repo <target...>` form when the repo you want to inspect
is not the DCCK clone itself.

Concrete Python example from an outside repo:

```bash
./scripts/packet_bundle.sh \
  /tmp/dcck-requests-targeted \
  src/requests/sessions.py tests/test_requests.py
```

Write the three-section packet for another repo to a file:

```bash
./scripts/packet_bundle.sh /path/to/repo \
  > /tmp/dcck-packet.md
```

Print just the LLM handoff section for the current repo:

```bash
make handoff
```

Run a targeted change-risk pass for specific files while staying inside the cloned repo:

```bash
make risk-target TARGETS="README.md scripts/change_risk.sh"
```

`make risk-target` is repo-local. It scopes the change-risk output to files inside the current
cloned DCCK repo; for another repo, use `./scripts/packet_bundle.sh /path/to/repo <target...>`
instead.

## Output Shape

The bundle emits three markdown sections to stdout in this order:

1. `# Project Map`
2. `# LLM Handoff`
3. `# Change Risk`

Reference section shapes live in `templates/`.

## Example Packet

- `examples/control-sample-packet.md` is a redacted sample captured from the venture control run.
- It shows the emitted section order and tone without leaking the full workspace path.

## Templates

- `templates/project-map.md`
- `templates/llm-handoff.md`
- `templates/change-risk.md`

These are fixed reference layouts for the v0 bundle. They are not runtime inputs yet; they define the intended shape so the packet can be used without opening archive notes first.

## Current Scope

- Local-only
- Shell-first
- No accounts
- No spend
- No hosted service

## Release Notes

- `LICENSE` ships the planned `MIT` terms for the first public repo shape.
- `REPO-CHECKLIST.md` is the publish-safe preflight list for the first `SPA-001` GitHub push.
- `make handoff` exposes the middle LLM-oriented section directly so the public repo has the same one-command affordance as `bundle`, `map`, and `risk`.
- `make check` now runs against the repo-local fixture repos under `fixtures/`, so the regression guardrail no longer depends on Jane-local `/tmp` clones or the venture workspace path.
