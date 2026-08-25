# FamilyRoots — Branch Protection Requirements

Phase 1 introduces CI checks but repository branch protection must be configured in GitHub settings before any autonomous merge policy is enabled.

## develop

Recommended rules:

- require a pull request before merging;
- require status checks to pass before merging;
- require branches to be up to date before merging when practical;
- block force pushes;
- block branch deletion;
- do not allow agents to bypass protections.

Required status checks after the Phase 1 workflows have run at least once:

- `Backend / build-lint-unit`
- `Backend / e2e`
- `Flutter / analyze-test`
- `Security / tracked-secret-guard`

Human approval remains required whenever `AGENTS.md` or `RULES_ESCALATION.md` says so.

## main

Recommended rules are at least as strict as `develop`:

- pull request required;
- all relevant status checks required;
- force pushes and deletion blocked;
- production release remains a human-approved action.

## Activation sequence

1. Merge the Phase 1 CI PR into `develop` only after its own checks are understood and corrected.
2. Confirm each workflow has produced a stable status-check name.
3. Configure the four checks above as required on `develop`.
4. Configure equivalent protections on `main`.
5. Only then consider automatic merging for low-risk, non-escalated work.

A green CI result is necessary but not sufficient for changes involving product decisions, Auth/RLS, destructive migrations, security, major architecture or production deployment.
