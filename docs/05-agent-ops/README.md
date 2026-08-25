# FamilyRoots — Agent Operations

This directory is the persistent operational memory for AI-assisted development.

## Read order

1. [`/AGENTS.md`](../../AGENTS.md) — global operating contract
2. [`PROJECT_STATE.md`](PROJECT_STATE.md) — verified repository state and known drift/blockers
3. [`CODING_STANDARDS.md`](CODING_STANDARDS.md) — implementation conventions
4. [`RULES_ESCALATION.md`](RULES_ESCALATION.md) — autonomy vs human approval
5. relevant runbook below

## Runbooks

- [`runbooks/LOCAL_SETUP.md`](runbooks/LOCAL_SETUP.md) — prepare a development environment
- [`runbooks/TESTING.md`](runbooks/TESTING.md) — build, lint, unit/E2E and regression expectations
- [`runbooks/DEPLOYMENT.md`](runbooks/DEPLOYMENT.md) — staging/production policy and approval gates
- [`runbooks/INCIDENTS.md`](runbooks/INCIDENTS.md) — incident triage, containment and recovery

## Relationship with existing documentation

This folder does **not** replace the existing product and architecture documents.

- `docs/01-product/` defines product intent and MVP scope.
- `docs/02-design/` defines user journeys/design.
- `docs/03-architecture/` defines architecture, API, business rules and reference schemas.
- `docs/04-backlog/` defines planned work.
- `docs/05-agent-ops/` defines **how an autonomous or semi-autonomous engineering agent is allowed to work**.

When product intent is ambiguous, agents must use the escalation rules rather than inventing behavior.

## Phase status

Phase 0: agent memory and governance bootstrap.

Phase 1 should add enforceable GitHub automation: CI, issue/PR templates, branch protections and a first controlled coding-agent pilot.
