# Runbook — Testing

FamilyRoots agents must use tests as an independent check on implementation, not as a box-ticking exercise.

## 1. Minimum checks before PR

### Backend

From `src/backend/`:

```bash
npm ci
npm run build
npx eslint "{src,apps,libs,test}/**/*.ts"
npm test -- --runInBand
npm run test:e2e -- --runInBand
```

Notes:

- the repository's `npm run lint` currently includes `--fix`; CI should prefer the non-mutating ESLint command above;
- if E2E requires external services or credentials, report the exact blocker rather than claiming the suite passed;
- generated GraphQL schema changes should be reviewed when relevant.

### Mobile

From `src/mobile/`:

```bash
flutter pub get
flutter analyze
flutter test
```

For UI/flow changes, run the affected screen on at least one practical target (Chrome is acceptable during early MVP development) and record the manual smoke test in the PR.

## 2. Test expectations by change type

### Bug fix

Required when reasonable:

1. reproduce failure;
2. add a failing regression test or a reproducible scripted case;
3. implement fix;
4. prove the regression now passes;
5. run neighboring tests.

Do not "fix" a GraphQL nullability error only by making the field nullable unless null is valid by product contract.

### Feature

Cover at least:

- happy path;
- invalid input or important edge case;
- authorization/ownership where relevant;
- persistence/relationship behavior where relevant;
- client error/loading state where relevant.

### Refactor

Existing behavior-level tests should remain green. Add tests first if the area has no coverage and the refactor is risky.

### Database change

Test:

- migration applies to a safe development/test database;
- Prisma client regenerates;
- existing reads/writes still work;
- constraints/cascades behave as intended;
- rollback or recovery plan exists for risky changes.

## 3. Relationship / family-tree checks

Changes touching `Member` or `Relationship` should consider:

- from/to member hydration;
- reciprocal relationship creation if required by current business rules;
- same-family ownership;
- self-relations;
- duplicates;
- spouse/parent/child rendering impact;
- deletion/cascade implications;
- members with and without linked profiles;
- deceased-member rendering when affected.

## 4. Auth/security checks

For protected GraphQL operations, verify at minimum:

- unauthenticated access is rejected;
- authenticated user can perform allowed action;
- user cannot access/modify another family's data through ID manipulation;
- errors do not leak tokens or sensitive internals.

Changes to Auth/RLS require human review regardless of test results.

## 5. Handling flaky or unavailable tests

Never hide a failing test by disabling it without explicit rationale.

If a test is flaky:

- reproduce multiple times;
- capture failure evidence;
- isolate shared state/timing/network dependencies;
- fix the cause if within scope;
- otherwise mark the PR blocked or escalate.

If external infrastructure is unavailable, state:

- which suite could not run;
- why;
- which local/static checks did run;
- what must be executed before merge.

## 6. Evidence in PR

PR description should contain a concise section such as:

```text
Tests
- npm run build ✅
- ESLint check ✅
- npm test -- --runInBand ✅ (42 tests)
- npm run test:e2e -- --runInBand ✅ (8 tests)
- flutter analyze ✅
- flutter test ✅ (12 tests)
- Manual smoke: create family → add member → tree refresh ✅
```

Never invent test counts or success states.

## 7. Future Phase 1 CI gates

The intended CI gates are:

- backend dependency install
- backend build
- backend non-mutating lint
- backend unit tests
- backend E2E tests where environment supports them
- Flutter dependency install
- Flutter analyze
- Flutter tests
- secret/security scan

No autonomous merge should be enabled until required gates are enforced by branch protection.
