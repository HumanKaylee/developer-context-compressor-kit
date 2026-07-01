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

Run the full packet on a repo:

```bash
bash ventures/developer-context-compressor-kit/scripts/packet_bundle.sh /path/to/repo
```

Run the packet with explicit target paths for the change-risk section:

```bash
bash ventures/developer-context-compressor-kit/scripts/packet_bundle.sh \
  /path/to/repo \
  path/to/file1 path/to/file2
```

Write the three-section packet to a file:

```bash
bash ventures/developer-context-compressor-kit/scripts/packet_bundle.sh /path/to/repo \
  > /tmp/dcck-packet.md
```

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
