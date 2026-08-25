# FamilyRoots — Coding Standards for Agents

These standards are intentionally close to the code already present in the repository. Do not introduce a new architectural style merely because it is fashionable or preferred by a model.

## 1. General principles

- Prefer small, reviewable changes.
- Preserve existing public behavior unless the issue explicitly changes it.
- Avoid unrelated refactors in feature PRs.
- Reuse existing abstractions before adding new ones.
- Treat compiler, analyzer and test warnings as signals to resolve, not suppress by default.
- Do not commit generated secrets, local environment files, build artifacts or dependency caches.

## 2. Backend — NestJS / GraphQL / Prisma

### Structure

Use the existing domain-module pattern under `src/backend/src/`:

```text
<domain>/
├── <domain>.module.ts
├── <domain>.resolver.ts
├── <domain>.service.ts
├── <domain>.type.ts
└── dto/
```

Not every domain needs every file. Match neighboring modules before creating new structure.

### Responsibilities

- **Resolver:** GraphQL transport concerns, auth guards, argument mapping and field resolution.
- **Service:** domain behavior and data-access orchestration.
- **PrismaService:** database access primitive; avoid leaking raw DB access into unrelated layers when a domain service already owns the behavior.
- **DTO/Input:** validated GraphQL inputs.
- **Type:** GraphQL object/enums exposed to clients.

Avoid private-property access such as `service['prisma']` in new code. If a resolver needs domain data, expose an explicit service method instead.

### GraphQL

The project uses code-first GraphQL. `src/backend/src/schema.gql` is generated from decorators.

- Keep TypeScript GraphQL types and runtime resolver behavior aligned.
- Do not loosen nullability to make an error disappear without confirming the product contract.
- When adding or changing a field, update tests and client queries as needed.
- Return stable, meaningful errors; do not expose secrets, SQL or JWT details.
- Preserve auth guards on protected operations.

### Relationships

`Relationship` is directional in storage with `fromMemberId`, `toMemberId` and `type`.

Before changing relationship semantics:

- read the business rules document;
- check reciprocal relationship creation behavior;
- check tree rendering assumptions;
- verify no cycles or invalid self-relations are introduced where prohibited.

Changes to relationship semantics require human validation unless already specified.

### Prisma / database

- `src/backend/prisma/schema.prisma` is the runtime schema source.
- Use migrations for schema changes; do not rely on ad-hoc production schema edits.
- Add indexes only with a concrete query/use case.
- Preserve existing `@map` / `@@map` naming unless intentionally migrating.
- Never perform destructive migration automatically.
- Verify cascade behavior before changing foreign keys.

### TypeScript

- Prefer explicit domain types over `any` in new/modified code.
- Avoid type assertions that only silence compiler errors.
- Keep functions focused and name side effects clearly.
- Use async/await consistently with existing code.
- Do not swallow exceptions silently unless the user-facing contract intentionally treats the failure as absence; document such cases.

## 3. Mobile — Flutter / Riverpod / GraphQL

### Structure

Follow the existing feature-first organization:

```text
lib/
├── core/
│   ├── config/
│   ├── graphql/
│   └── services/
└── features/
    └── <feature>/
        ├── providers/
        ├── screens/
        └── widgets/
```

Place cross-feature infrastructure in `core/`; feature-specific code stays inside its feature.

### State management

The current implementation uses Riverpod `StateNotifier` patterns in places.

- Follow the local pattern of the feature being changed.
- Do not migrate the whole project to a different Riverpod generation style inside an unrelated PR.
- Represent loading/error/data states explicitly.
- Avoid putting GraphQL transport details directly into UI widgets when a provider/service already owns them.

### GraphQL client

- Centralize reusable operations in the existing GraphQL query/mutation layer.
- Keep variables typed/structured consistently.
- Handle `hasException` paths and user-visible errors.
- Do not log access tokens.
- If backend schema changes, update affected queries atomically in the same PR when feasible.

### UI

- Respect the existing FamilyRoots design system and theme.
- Prefer reusable widgets for repeated visual elements.
- Provide loading, empty and error states for async screens.
- Avoid hard-coding production URLs or environment values.
- Preserve accessibility basics: readable contrast, meaningful labels, tappable target sizes.

## 4. Tests

Every bug fix should include a regression test when technically reasonable.

Every feature should test:

- expected happy path;
- authorization/ownership where relevant;
- invalid input or important edge case;
- regression risk introduced by the change.

Do not write tests that merely mirror implementation internals if a behavior-level assertion is possible.

See `runbooks/TESTING.md` for commands.

## 5. Formatting and lint

Backend scripts currently include a lint command with `--fix`. For CI/check-only behavior, prefer a non-mutating ESLint invocation rather than relying on a command that rewrites files.

Before PR:

- backend formatting must be stable;
- TypeScript must build;
- Flutter analyzer must pass for touched code;
- generated files must be refreshed only when expected.

## 6. Dependencies

Adding a dependency requires checking:

- whether an existing dependency already solves the problem;
- maintenance/activity and license;
- security implications;
- mobile/backend size or runtime impact;
- whether it is structurally important.

A new foundational dependency or external service requires human approval.

## 7. Comments and documentation

Comments should explain **why**, invariants or non-obvious behavior, not restate syntax.

Update agent/runbook docs when a change affects how future agents must build, test, deploy or operate the system.

## 8. Commit and PR quality

Recommended commit prefixes:

- `feat:` new product behavior
- `fix:` bug fix
- `test:` tests only
- `refactor:` behavior-preserving internal change
- `docs:` documentation only
- `chore:` tooling/maintenance

PR descriptions must include:

- problem/context;
- implementation summary;
- tests executed and result;
- risk areas;
- migrations/config changes;
- human decisions still required.
