---
name: Agent escalation
about: Bloquer proprement une tâche qui exige une décision humaine
title: "[HUMAN-DECISION] "
labels: ""
assignees: ""
---

AGENT_STATE: HUMAN-DECISION

## Décision requise

Formuler une seule décision claire à prendre.

## Pourquoi l'agent s'arrête

Expliquer la règle d'escalade déclenchée : métier, architecture, Auth/RLS, sécurité, données, dépendance structurante, production ou opération irréversible.

## Contexte vérifié

Lister les fichiers, tests, logs et documents consultés.

## Options

### Option A

Conséquences, avantages et risques.

### Option B

Conséquences, avantages et risques.

### Autre option si nécessaire

Uniquement si elle apporte une vraie alternative.

## Recommandation de l'agent

Proposer une option sans la considérer comme approuvée.

## Impact si aucune décision n'est prise

Préciser ce qui reste bloqué et ce qui peut continuer indépendamment.

## Réponse humaine

À compléter par le Product Owner. Une fois la décision documentée, l'issue d'origine peut revenir à `READY` si tous les autres prérequis sont satisfaits.
