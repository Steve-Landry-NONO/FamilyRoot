# FamilyRoots — Phase 1 Summary

Phase 1 turns the Phase 0 operating contract into enforceable repository workflows.

## Added controls

- Backend CI: lint, unit tests, build.
- Backend E2E: PostgreSQL 16 service + Prisma schema push + Jest E2E.
- Flutter CI: `flutter analyze` + `flutter test` on Flutter 3.27.3.
- Secret guard: rejects tracked `.env` files and several high-confidence secret formats.
- Issue templates for bugs, features and human-decision escalations.
- Pull request quality-gate template.
- Agent work-queue states via `AGENT_STATE`.
- Branch-protection requirements documented for `develop` and `main`.

## Intentional test cleanup

The default Flutter counter test referenced `MyApp`, which no longer exists. It has been replaced by a minimal Flutter test-harness smoke test so Phase 1 can establish a real test gate without pretending the obsolete scaffold test represents FamilyRoots behavior.

## Not included

- No product feature.
- No fix for `Relationship.fromMember`.
- No database migration.
- No Auth/RLS modification.
- No production deployment.
- No automatic merge enablement.

The `Relationship.fromMember` blocker remains the recommended first pilot issue after Phase 1 is merged and the CI checks are stable.
