# FamilyRoots — Agent Operating Contract

Ce fichier est le point d'entrée obligatoire pour tout agent IA qui travaille sur FamilyRoots.

## 1. Mission

Faire avancer FamilyRoots de manière autonome **sans inventer de règles métier, contourner la sécurité, ni dégrader la traçabilité Git**.

L'humain reste Product Owner et arbitre les décisions produit, métier, architecture et sécurité qui dépassent un changement local et réversible.

## 2. Source de vérité et ordre de priorité

Lire dans cet ordre avant tout changement significatif :

1. L'issue / instruction humaine courante.
2. `docs/01-product/FamilyRoots_MVP_Scope_Freeze_v1.0.html` pour le périmètre MVP.
3. `docs/03-architecture/FamilyRoots_Business_Rules_v1.0.html` pour les règles métier.
4. `docs/03-architecture/FamilyRoots_API_GraphQL_Spec_v1.0.html` pour le contrat API attendu.
5. `src/backend/prisma/schema.prisma` pour le schéma réellement utilisé par le backend.
6. Le code actuel et les tests.
7. `docs/05-agent-ops/` pour les règles opérationnelles des agents.

Si deux sources importantes se contredisent et que le choix modifie le comportement produit, **ne pas deviner** : escalader.

## 3. Lecture minimale avant de coder

Toujours lire :

- `docs/05-agent-ops/PROJECT_STATE.md`
- `docs/05-agent-ops/CODING_STANDARDS.md`
- `docs/05-agent-ops/RULES_ESCALATION.md`
- le ou les documents métier pertinents dans `docs/`
- le code voisin de la zone modifiée

Pour une tâche d'installation, test, livraison ou incident, lire également le runbook correspondant dans `docs/05-agent-ops/runbooks/`.

## 4. Workflow Git obligatoire

- Ne jamais pousser directement sur `main` ou `develop`.
- Partir de `develop`, sauf instruction explicite différente.
- Une issue ou unité de travail = une branche dédiée.
- Noms recommandés : `feat/FR-xxx-slug`, `fix/FR-xxx-slug`, `chore/slug`.
- Garder les commits cohérents et explicites.
- Ouvrir une Pull Request vers `develop`.
- Ne pas merger une PR nécessitant une validation humaine tant que cette validation n'existe pas.

## 5. Autonomie autorisée

Un agent peut, sans demander :

- implémenter une issue dont les critères d'acceptation sont non ambigus ;
- corriger un bug local dont le comportement attendu est déjà défini ;
- écrire ou renforcer des tests ;
- refactoriser sans changer le comportement observable ;
- améliorer la documentation opérationnelle ;
- corriger lint, types, imports, formatage et erreurs de compilation ;
- ajouter de l'observabilité non sensible et non intrusive.

Voir `RULES_ESCALATION.md` pour la matrice complète.

## 6. Actions interdites sans validation humaine

- migration destructive ou perte potentielle de données ;
- changement de modèle métier ou de relation généalogique ;
- changement d'authentification, RLS, autorisations ou gestion des secrets ;
- nouvelle dépendance structurante ou service externe ;
- changement majeur d'architecture ;
- changement UX qui modifie un parcours ou une règle du MVP ;
- déploiement en production ;
- suppression massive de données, branches ou ressources ;
- désactivation de contrôles de sécurité pour faire passer un test.

## 7. Sécurité

- Aucun secret, token, clé Supabase ou mot de passe dans Git.
- Ne jamais logguer de JWT ou donnée personnelle sensible.
- Ne jamais considérer une clé côté client comme autorisation suffisante.
- Toute modification auth/RLS exige validation humaine et tests dédiés.
- Les contournements temporaires de sécurité doivent être explicitement autorisés et documentés.

## 8. Definition of Done

Une tâche n'est terminée que si :

- les critères d'acceptation sont satisfaits ;
- le code compile ;
- lint/analyse statique passent ;
- les tests pertinents passent ;
- les cas limites raisonnables sont couverts ;
- la documentation est mise à jour si le comportement ou l'exploitation change ;
- aucun secret n'est introduit ;
- le diff ne contient pas de modification hors périmètre inexpliquée ;
- la PR contient résumé, risques, tests exécutés et éventuelles décisions humaines requises.

## 9. Politique en cas d'échec

L'agent doit tenter de diagnostiquer et corriger les erreurs reproductibles. Il doit arrêter et escalader lorsqu'il rencontre :

- une ambiguïté métier ;
- une contradiction entre sources de vérité ;
- une opération irréversible ;
- un problème de permissions/secrets nécessitant un accès humain ;
- une boucle de correction sans progrès mesurable ;
- un doute sérieux sur la sécurité ou l'intégrité des données.

## 10. Principe directeur

**Human-driven product, AI-driven engineering.**

L'agent optimise l'exécution. L'humain tranche les choix qui définissent ce que FamilyRoots doit être.
