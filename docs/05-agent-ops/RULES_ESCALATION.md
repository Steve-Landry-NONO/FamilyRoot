# FamilyRoots — Agent Escalation Rules

This document defines when an AI agent may proceed autonomously and when it must stop for a human decision.

## 1. Default rule

Proceed autonomously only when the expected behavior is already clear, the change is reversible, and risk is local.

If the agent must invent product intent, weaken security, make an irreversible change or choose between materially different architectures, escalate.

## 2. Decision matrix

| Change / action | Agent may do | Human approval required |
|---|---:|---:|
| Read code/docs/history | ✅ | |
| Create working branch | ✅ | |
| Implement well-defined issue | ✅ | |
| Fix reproducible local bug with clear expected behavior | ✅ | |
| Add/update unit tests | ✅ | |
| Add/update integration/E2E tests | ✅ | |
| Refactor without behavior change | ✅ | |
| Update docs/runbooks to match verified behavior | ✅ | |
| Open PR | ✅ | |
| Correct lint/type/build failures | ✅ | |
| Small UI polish matching existing design system | ✅ | |
| Change acceptance criteria / product behavior | | ✅ |
| Change genealogy/business semantics | | ✅ |
| Introduce a new relation type | | ✅ |
| Change invitation expiry/business pricing/tier rules | | ✅ |
| Breaking GraphQL contract change | | ✅ |
| Destructive or irreversible DB migration | | ✅ |
| Any auth / authorization / RLS policy behavior change | | ✅ |
| Introduce or rotate production secrets | | ✅ |
| Add foundational dependency or external SaaS | | ✅ |
| Major architecture migration | | ✅ |
| Direct push to `main` or `develop` | | ❌ forbidden |
| Production deployment | | ✅ |
| Delete production data/resources | | ✅ |
| Disable security controls to unblock development | | ✅ |

## 3. Low-risk database changes

Even non-destructive schema changes deserve special care.

An agent may prepare a migration in a PR when the issue explicitly requires it, but it must flag the PR as requiring human review if the migration:

- changes persisted business data;
- adds/removes uniqueness constraints;
- changes cascades or foreign keys;
- backfills a large table;
- alters enum values;
- could lock or rewrite significant data.

Never apply destructive production migrations autonomously.

## 4. Product / business ambiguity

Escalate instead of guessing for questions such as:

- What should happen to existing relatives when a member is deleted or marked deceased?
- Can the same profile belong to multiple families?
- Are circular/complex family relationships allowed in a given case?
- Which role can edit another member?
- How long should an invitation remain valid?
- Does a new behavior belong in MVP scope?

A good escalation contains:

1. the exact ambiguity;
2. why it matters;
3. 2–3 concrete options when useful;
4. the agent's recommendation and trade-off;
5. what work is blocked by the decision.

## 5. Security escalation

Stop and escalate when a change affects:

- Supabase Auth token validation;
- JWT handling;
- role/ownership checks;
- Row Level Security;
- API exposure of personal data;
- secret management;
- CORS/CSRF/security headers in production;
- file/storage access control.

Do not treat a failing security check as a nuisance to bypass.

## 6. Architecture escalation

Human approval is required before:

- replacing Supabase, Prisma, GraphQL, NestJS, Riverpod or Flutter architecture wholesale;
- introducing queues, event buses, microservices or a new persistence layer;
- moving major domain responsibilities across services;
- changing public API versioning strategy;
- adopting a new deployment platform that changes operations materially.

Local implementation patterns that fit the existing architecture do not need separate approval.

## 7. Loop / failure policy

An agent should not loop indefinitely.

Escalate when:

- the same failure persists after multiple materially different diagnostic attempts;
- tests are flaky and the root cause cannot be isolated;
- required credentials or infrastructure access are unavailable;
- external service behavior contradicts documented assumptions;
- fixing the issue would require broad changes outside the issue scope.

The escalation must include attempts made, observed evidence and the smallest next human action needed.

## 8. Merge policy for Phase 0/1

Until CI and branch protections are fully configured:

- agents may prepare PRs;
- agents must not autonomously merge sensitive changes;
- production-impacting changes require human approval;
- merge automation should remain conservative.

After Phase 1, low-risk auto-merge may be introduced only when required checks and review rules are enforceable.

## 9. Principle

When in doubt between **guessing quickly** and **asking once with evidence**, choose the evidence-backed escalation.
