---
name: Bug report
about: Reproduire et corriger un comportement incorrect de FamilyRoots
title: "[BUG] "
labels: ""
assignees: ""
---

AGENT_STATE: DRAFT

<!--
Valeurs autorisées :
- DRAFT : issue incomplète, l'agent ne doit pas la prendre
- READY : l'agent peut travailler en autonomie
- BLOCKED : dépendance technique ou externe non résolue
- HUMAN-DECISION : décision produit/métier/sécurité requise
-->

## Problème

Décrire le comportement observé.

## Comportement attendu

Décrire précisément ce qui devrait se produire selon les sources de vérité du projet.

## Reproduction

1.
2.
3.

## Preuves

Logs, stack trace, capture, requête GraphQL, données de test ou autre preuve reproductible.

## Portée

- Backend : oui / non
- Mobile : oui / non
- Base de données : oui / non
- Auth / RLS : oui / non

## Critères d'acceptation

- [ ] Le bug est reproduit avant le correctif.
- [ ] Un test de régression échoue avant le correctif lorsque c'est raisonnablement possible.
- [ ] La cause racine est documentée.
- [ ] Le correctif traite la cause racine et non uniquement le symptôme.
- [ ] Les tests pertinents passent.
- [ ] Aucun comportement hors périmètre n'est modifié.

## Sources de vérité concernées

Lister les documents / fichiers qui définissent le comportement attendu.

## Escalade potentielle

Indiquer toute ambiguïté métier, migration, Auth/RLS, sécurité ou décision irréversible susceptible d'exiger `HUMAN-DECISION`.
