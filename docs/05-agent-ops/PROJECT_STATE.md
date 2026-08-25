# FamilyRoots — Project State for Agents

**Last verified against GitHub:** 2026-08-25  
**Reference branch:** `develop`  
**Reference commit at audit:** `7216610cd1756b4db9579007b3d10de40e5c0f2e`

This document describes the repository state observed by the agent-ops bootstrap. It is operational context, not a replacement for product specifications.

## 1. Repository topology

```text
FamilyRoot/
├── docs/
│   ├── 00-legacy/
│   ├── 01-product/
│   ├── 02-design/
│   ├── 03-architecture/
│   ├── 04-backlog/
│   └── INDEX.md
├── src/
│   ├── backend/
│   └── mobile/
├── .env.template
├── CHANGELOG.md
└── README.md
```

The `develop` branch is the active integration branch. At the Phase 0 audit it was ahead of `main` and contained the current implementation work.

## 2. Backend observed stack

Location: `src/backend/`

- NestJS 11
- GraphQL with Apollo
- Prisma 5.22
- PostgreSQL through Supabase
- Supabase Auth
- TypeScript 5.7
- Jest
- ESLint + Prettier

Main domain modules currently present:

- auth
- profile
- family
- member
- invitation
- notification
- prisma

The GraphQL schema is generated from NestJS code-first definitions to `src/backend/src/schema.gql`.

## 3. Mobile observed stack

Location: `src/mobile/`

- Flutter / Dart SDK constraint `^3.6.1`
- Riverpod
- GoRouter
- Supabase Flutter
- GraphQL Flutter
- Freezed / json_serializable toolchain available
- graphview dependency present

The codebase is organized primarily as:

```text
lib/
├── core/
├── features/
└── main.dart
```

Feature code currently uses providers/notifiers, screens and widgets.

## 4. Database observed state

The runtime Prisma schema contains 8 models:

1. `Profile`
2. `Family`
3. `UserFamily`
4. `Member`
5. `Relationship`
6. `Event`
7. `Invitation`
8. `Notification`

Important naming rules already encoded in the project:

- application account = `Profile`
- genealogy person = `Member`
- family membership pivot = `UserFamily`
- relationship direction is represented by `fromMemberId` / `toMemberId`

The product documentation remains authoritative for intended business semantics.

## 5. Documentation drift detected

At this audit, some operational documents lag behind the code:

- `README.md` still describes Sprint 3 as the immediate priority.
- the latest `develop` commit observed is a Sprint 4 tree-visualization change.
- `CHANGELOG.md` still contains an old Sprint 1 checklist and version 0.3.0 entries.

Therefore:

- use the product scope/rules documents for **intended behavior**;
- use the current code and Git history for **implementation state**;
- do not silently infer product behavior from stale roadmap text.

Updating project status/versioning is a separate maintenance task and should be handled explicitly.

## 6. Known / reported blocker

A current human-reported blocker is a GraphQL relationship issue involving `Relationship.fromMember` returning null or otherwise not resolving as expected.

Relevant current code:

- `MemberType` exposes `Relationship.fromMember` and `toMember` as non-null GraphQL fields.
- the `MemberResolver.relations` field resolver queries Prisma relationships with both `fromMember` and `toMember` included.

This blocker must be reproduced with a failing test or request before applying a fix. Do not weaken GraphQL nullability merely to hide the root cause unless the product contract explicitly requires nullable relationships.

## 7. Security / infrastructure state

At the Phase 0 audit:

- no repository-level GitHub Actions workflow directory was present;
- `develop` was not protected by required status checks;
- production deployment automation was not documented in the repository.

Do not assume RLS, production hosting, backups, monitoring or secret rotation are fully configured unless verified against the relevant environment. These items belong to the hardening work before autonomous merges/deployments are enabled.

## 8. Current agent autonomy level

**Level: assisted engineering.**

Agents may create branches, implement scoped changes, run tests, write docs and open PRs. Agents must not autonomously deploy production or merge sensitive changes.

## 9. Phase 0 objective

Phase 0 adds the persistent operating memory needed by future agents:

- root `AGENTS.md`
- coding standards
- escalation rules
- project-state snapshot
- local setup, testing, deployment and incident runbooks

Phase 1 should add enforceable automation: CI, PR/issue templates, branch protection and first controlled agent pilot.
