## Résumé

Décrire ce que cette PR change et pourquoi.

## Issue

Closes #

## Type de changement

- [ ] Bugfix
- [ ] Feature
- [ ] Refactor sans changement fonctionnel
- [ ] Tests / CI / outillage
- [ ] Documentation

## Risque

- [ ] Faible — local, réversible, sans changement métier
- [ ] Moyen — plusieurs composants ou comportement observable
- [ ] Élevé — données, auth, sécurité, architecture, production ou migration

## Validation humaine obligatoire

Cocher toute zone concernée :

- [ ] Décision métier / produit
- [ ] Migration de base de données
- [ ] Migration destructive ou perte potentielle de données
- [ ] Auth / permissions / RLS
- [ ] Sécurité / secrets
- [ ] Nouvelle dépendance ou service structurant
- [ ] Changement majeur d'architecture
- [ ] Changement UX majeur
- [ ] Déploiement production
- [ ] Aucune de ces zones

## Tests exécutés

- [ ] Backend build
- [ ] Backend lint
- [ ] Backend unit tests
- [ ] Backend E2E
- [ ] Flutter analyze
- [ ] Flutter tests
- [ ] Non applicable expliqué ci-dessous

Détails / commandes / résultats :

## Preuve avant/après

Pour un bug, fournir la reproduction avant et la preuve du correctif. Pour une feature, relier les critères d'acceptation aux tests ou captures pertinentes.

## Documentation

- [ ] Documentation métier / architecture mise à jour si nécessaire
- [ ] Runbook mis à jour si l'exploitation change
- [ ] `PROJECT_STATE.md` mis à jour si l'état réel du projet change
- [ ] Aucun changement documentaire requis

## Checklist agent

- [ ] J'ai lu `AGENTS.md` et les documents `docs/05-agent-ops/` pertinents.
- [ ] Le diff reste dans le périmètre de l'issue.
- [ ] Aucun secret ou token n'est introduit.
- [ ] Je n'ai pas contourné un contrôle pour faire passer la CI.
- [ ] Les décisions humaines requises sont explicitement signalées.
