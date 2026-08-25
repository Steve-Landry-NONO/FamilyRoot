# Runbook — Deployment

This runbook defines the deployment policy for FamilyRoots during the agentic-development bootstrap.

## 1. Current state

At the Phase 0 audit, the repository did not contain a GitHub Actions deployment workflow or a documented production pipeline.

Therefore agents must **not pretend a deployment succeeded** and must not invent hosting steps that are not configured.

## 2. Environment model

Target operating model:

```text
feature branch
    ↓
Pull Request
    ↓
CI checks
    ↓
develop
    ↓
staging deployment
    ↓
smoke / E2E validation
    ↓
human approval
    ↓
main / release
    ↓
production deployment
```

Phase 1 should make CI and staging enforceable before any autonomous production behavior is considered.

## 3. Rules

- Never deploy production from an unreviewed feature branch.
- Never expose production secrets in logs or repository files.
- Database migrations must be reviewed before production application.
- Auth/RLS/security changes require human approval.
- Production deployment requires explicit human approval during the current autonomy level.
- A failed deployment must not be followed by repeated blind retries; inspect evidence first.

## 4. Pre-deployment checklist

Before staging or production:

- target commit SHA is known;
- required CI checks are green;
- migration/config changes are documented;
- secrets/config exist in the target environment;
- backup/recovery expectations are understood for DB-affecting changes;
- release notes or PR summary identify user-visible changes;
- rollback path is known.

## 5. Staging

Once configured, staging should be the first automated deployment target after merge to `develop` or an explicitly approved release candidate.

Staging validation should include:

- backend health/startup;
- GraphQL endpoint reachability;
- Supabase authentication;
- core flow smoke tests;
- relevant database migrations;
- mobile client compatibility with the deployed GraphQL schema.

## 6. Production approval gate

Production should require a human go/no-go until the system has demonstrated stable CI, staging, monitoring and rollback over multiple releases.

The approval summary should include:

- release SHA/tag;
- PRs/features included;
- CI/staging result;
- migrations;
- known risks;
- rollback instruction.

## 7. Rollback

Application rollback should prefer redeploying the last known-good release.

Database rollback is not automatically safe. If a migration is destructive or data-transforming, recovery may require restoring data or a forward-fix. This is why such migrations require explicit human review before production.

## 8. Post-deploy checks

After deployment verify:

- service starts without repeated errors;
- authentication works;
- a basic GraphQL query succeeds;
- critical user journey works;
- no obvious spike in errors;
- schema/client mismatch is absent.

If a critical regression is found, follow `INCIDENTS.md`.

## 9. Phase 1 implementation target

Phase 1 should decide and document the actual hosting targets, then add:

- CI workflows;
- staging deployment workflow;
- environment-scoped secrets;
- required checks / branch protection;
- release/versioning process;
- production approval gate;
- monitoring and rollback evidence.
