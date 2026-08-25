# FamilyRoots — Agent Work Queue

Ce document définit les états minimaux qu'un orchestrateur ou coding agent doit respecter avant de prendre une issue.

## Marqueur canonique

Les issues destinées aux agents contiennent une ligne :

```text
AGENT_STATE: <STATE>
```

États reconnus :

- `DRAFT`
- `READY`
- `BLOCKED`
- `HUMAN-DECISION`

Un orchestrateur ne doit automatiquement prendre que les issues `READY`.

## DRAFT

L'issue n'est pas assez cadrée pour être exécutée.

L'agent peut aider à analyser ou proposer des critères, mais ne doit pas démarrer une implémentation autonome.

## READY

Tous les prérequis suivants sont vrais :

- comportement attendu non ambigu ;
- critères d'acceptation vérifiables ;
- périmètre et hors-périmètre compréhensibles ;
- sources de vérité identifiées lorsque nécessaire ;
- aucune décision humaine déjà connue comme manquante ;
- aucune dépendance bloquante connue.

L'agent peut créer une branche, développer, tester, documenter et ouvrir une PR conformément à `AGENTS.md`.

## BLOCKED

La tâche est comprise mais une dépendance empêche son exécution : environnement indisponible, service externe, permission, issue préalable, donnée de test manquante ou autre blocage factuel.

L'agent doit documenter :

1. le blocker exact ;
2. la preuve ;
3. ce qui débloquera la tâche ;
4. les travaux indépendants éventuellement encore possibles.

Il ne doit pas inventer de workaround qui modifie les règles, la sécurité ou l'architecture.

## HUMAN-DECISION

La progression exige une décision qui appartient explicitement à l'humain selon `RULES_ESCALATION.md`.

L'agent doit :

1. arrêter la partie concernée ;
2. formuler la décision précisément ;
3. présenter les options importantes avec impacts et risques ;
4. donner une recommandation non contraignante ;
5. attendre une réponse humaine documentée.

Après réponse, l'issue peut repasser à `READY` uniquement si la décision résout l'ambiguïté et qu'aucun autre blocker ne subsiste.

## Transitions autorisées

```text
DRAFT ──humain/cadrage──> READY
READY ──dépendance──────> BLOCKED
READY ──décision────────> HUMAN-DECISION
BLOCKED ──déblocage─────> READY
HUMAN-DECISION ──réponse humaine──> READY
READY ──PR mergée───────> DONE via fermeture de l'issue
```

Une IA ne doit pas inventer une réponse humaine pour faire passer `HUMAN-DECISION` à `READY`.

## Cycle d'exécution d'une issue READY

1. Lire `AGENTS.md`.
2. Lire `PROJECT_STATE.md`, `CODING_STANDARDS.md`, `RULES_ESCALATION.md` et les documents métier concernés.
3. Reproduire l'état initial lorsque la tâche est un bug.
4. Créer une branche dédiée depuis `develop`.
5. Implémenter le changement le plus petit satisfaisant les critères.
6. Ajouter / ajuster les tests pertinents.
7. Exécuter les contrôles locaux applicables.
8. Mettre à jour la documentation / runbook si nécessaire.
9. Ouvrir une PR vers `develop` avec le template du repo.
10. Corriger les erreurs de CI reproductibles et les remarques de review dans le périmètre autorisé.
11. Escalader toute nouvelle décision hors autonomie.

## CI minimale attendue

La Phase 1 impose sur les PR :

- backend : lint sans modification, tests unitaires, build et E2E avec PostgreSQL éphémère ;
- Flutter : analyse statique et tests ;
- sécurité : garde contre fichiers `.env` suivis et plusieurs formats de secrets à forte confiance.

Ces checks sont des garde-fous, pas une preuve absolue de correction ou de sécurité.

## Merge et production

Une CI verte n'autorise pas automatiquement un agent à merger une PR qui déclenche une règle d'escalade. Le déploiement production reste soumis au runbook et à la validation humaine prévue par `AGENTS.md`.
