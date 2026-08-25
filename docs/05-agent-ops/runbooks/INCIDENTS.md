# Runbook — Incidents

This runbook describes how an agent should respond to regressions, failed deployments and critical application errors.

## 1. Priorities

In order:

1. protect user data and secrets;
2. stop further damage;
3. restore a known-good service state;
4. preserve evidence;
5. diagnose root cause;
6. implement and verify a fix;
7. document lessons and prevention.

## 2. Severity guide

### SEV-1 — Critical

Examples:

- data loss/corruption;
- unauthorized cross-family access;
- leaked secret/token;
- authentication broadly broken;
- production unavailable for core flows.

Action: stop autonomous changes and escalate immediately.

### SEV-2 — Major

Examples:

- major feature unusable;
- repeated server crashes;
- GraphQL contract break affecting current app;
- important family-tree data rendered incorrectly.

Action: stabilize, gather evidence, prepare fix; human review before risky production action.

### SEV-3 — Moderate

Examples:

- isolated feature bug;
- non-critical UI regression;
- degraded but usable behavior.

Action: create/reproduce issue, fix through normal PR flow.

## 3. First response checklist

Capture before changing things when possible:

- environment;
- commit/release SHA;
- exact error and timestamp;
- affected operation/user flow;
- relevant logs without exposing secrets;
- reproducibility;
- recent deployments/migrations/config changes.

Do not paste JWTs, access tokens or private user data into GitHub issues.

## 4. Containment

Safe containment actions may include:

- stop an automated rollout;
- disable an affected non-critical feature through an existing safe mechanism;
- roll back application code to a known-good release when no DB incompatibility exists.

Human approval is required for:

- destructive DB actions;
- emergency RLS/auth changes;
- deleting user data;
- rotating production credentials unless the human has delegated that incident action explicitly.

If a secret is exposed, treat it as compromised and escalate for rotation.

## 5. Diagnosis

Work from evidence:

1. reproduce on the smallest safe environment;
2. compare failing release with last known-good release;
3. inspect the first causal error;
4. verify schema/config/dependency drift;
5. create a regression test when possible;
6. fix the smallest root cause.

Avoid speculative broad refactors during an incident.

## 6. FamilyRoots-specific checks

For relationship/tree incidents verify:

- Prisma relationship row has valid `fromMemberId` and `toMemberId`;
- both related members exist and belong to the intended family;
- resolver includes/hydrates `fromMember` and `toMember` as required by GraphQL nullability;
- GraphQL client requests fields compatible with current schema;
- tree layout handles all returned relation types;
- no stale client/backend schema mismatch exists.

For auth/access incidents verify:

- Supabase session validity;
- backend JWT validation;
- current profile resolution;
- family ownership/role checks;
- RLS status/policies if relevant;
- no identifier manipulation can cross family boundaries.

## 7. Recovery validation

A recovery is not complete until:

- the original failure no longer reproduces;
- regression test passes;
- neighboring critical flows pass;
- no new security/data integrity issue is introduced;
- staging or equivalent safe environment is healthy before production approval.

## 8. Incident record

For SEV-1/SEV-2 create a concise record containing:

- impact;
- timeline;
- root cause;
- containment/recovery;
- permanent fix;
- tests added;
- follow-up actions;
- owner/status.

The goal is to improve the system memory so future agents do not rediscover the same failure.
