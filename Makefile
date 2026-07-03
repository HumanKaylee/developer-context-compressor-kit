SHELL := /bin/bash

.PHONY: help bundle map handoff risk risk-target check

help:
	@printf '%s\n' 'make bundle  # run the full DCCK packet bundle on this repo'
	@printf '%s\n' 'make map     # print the shallow repo map'
	@printf '%s\n' 'make handoff # print the LLM handoff brief'
	@printf '%s\n' 'make risk    # print the repo-level change-risk brief'
	@printf '%s\n' 'make risk-target TARGETS="path1 path2"  # print a targeted change-risk brief'
	@printf '%s\n' 'make check   # run hotspot regression checks on the control samples'

bundle:
	@./scripts/packet_bundle.sh .

map:
	@./scripts/repo_map.sh .

handoff:
	@./scripts/repo_map.sh . | ./scripts/llm_handoff.sh -

risk:
	@./scripts/change_risk.sh .

risk-target:
	@./scripts/change_risk.sh . $(TARGETS)

check:
	@./scripts/hotspot_regression_check.sh
