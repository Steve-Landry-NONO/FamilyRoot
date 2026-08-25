# FamilyRoots — Phase 1 Summary

Phase 1 turns the Phase 0 operating contract into enforceable repository workflows.

## Added controls

- Backend CI: incremental lint on changed TypeScript files, unit tests and build.
- Backend E2E: PostgreSQL 16 service + Prisma schema push + Jest E2E.
- Flutter CI: `flutter analyze` + `flutter test` on Flutter 3.27.3.
- Secret guard: rejects tracked `.env` files and several high-confidence secret formats.
- Issue templates for bugs, features and human-decision escalations.
- Pull request quality-gate template.
- Agent work-queue states via `AGENT_STATE`.
- Branch-protection requirements documented for `develop` and `main`.

## Baseline findings from the first real CI runs

Phase 1 intentionally ran against the existing repository before claiming the gates were stable. That exposed real pre-existing debt:

- the backend full-repository ESLint audit currently reports 127 problems (114 errors and 13 warnings); therefore the blocking PR gate is incremental and lints changed backend TypeScript files rather than pretending the historical debt is already clean;
- the old backend E2E still expected the NestJS scaffold response `GET / -> Hello World!`; it was replaced by a GraphQL endpoint smoke test;
- the old Flutter widget test still referenced the removed scaffold `MyApp`; it was replaced by a minimal Flutter test-harness smoke test;
- `Supabase.initialize(anonKey: ...)` is deprecated by the resolved Supabase Flutter version; it was migrated to the equivalent `publishableKey` parameter without changing the configured key value;
- the first secret guard pattern classified the long placeholder in `.env.template` as a secret; the rule was tightened to detect a JWT-shaped Supabase service-role value instead of rejecting legitimate templates.

The backend dependency install also reports package audit/deprecation warnings. Those are technical-debt signals to triage separately; Phase 1 does not apply broad dependency upgrades because they are outside the CI-bootstrap scope.

## Quality policy after Phase 1

Historical debt is not silently ignored. Instead:

1. build, unit tests and E2E remain repository-wide gates;
2. new or modified backend TypeScript files must pass ESLint;
3. Flutter analysis remains repository-wide because only one actionable deprecation was present and it was corrected;
4. future cleanup can progressively reduce the backend lint baseline in dedicated issues.

## Not included

- No product feature.
- No fix for `Relationship.fromMember`.
- No database migration.
- No Auth/RLS modification.
- No production deployment.
- No automatic merge enablement.

The `Relationship.fromMember` blocker remains the recommended first pilot issue after Phase 1 is merged and the CI checks are stable.
