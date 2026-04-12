# 📚 FamilyRoots — Index des Documents

> Table des matières complète de la documentation projet

**Version :** 0.3.0  
**Dernière mise à jour :** 12 Avril 2026  
**Auteur :** Steve-Landry KOUOKAM NONO

---

## 🗂️ Vue d'ensemble

| Paquet | Statut | Documents |
|--------|--------|-----------|
| **Paquet 1** — Fondations Produit | ✅ v0.1.0 | 4 documents |
| **Paquet 2** — Architecture Technique | ✅ v0.2.0 | 4 documents |
| **Paquet 3** — Règles Métier & Design | ✅ v0.3.0 | 2 documents |

**Total : 10 documents de référence**

---

## 📁 01-product/ — Fondations Produit

Documents de cadrage fonctionnel et périmètre MVP.

| Document | Version | Format | Description |
|----------|---------|--------|-------------|
| [FamilyRoots_PRD_MVP](01-product/FamilyRoots_PRD_MVP_v1.0.pdf) | v1.0 | PDF | Product Requirements Document — Vision, personas, user stories MVP |
| [FamilyRoots_MVP_Scope_Freeze](01-product/FamilyRoots_MVP_Scope_Freeze_v1.0.html) | v1.0 | HTML | **🔒 SOURCE OF TRUTH** — Périmètre MVP gelé (18 écrans, 17 US, 8 tables) |
| [FamilyRoots_Audit_Maquettes](01-product/FamilyRoots_Audit_Maquettes_v2.0.pdf) | v2.0 | PDF | Audit structuré des maquettes UI/UX — Points forts, gaps, recommandations |
| [FamilyRoots_Charte_Graphique](01-product/FamilyRoots_Charte_Graphique_v1.0.pdf) | v1.0 | PDF | Charte graphique — Logo, couleurs, typographie |

### Décisions clés (Paquet 1)
- ✅ MVP = Mobile-only, 1 famille par user
- ✅ Hors MVP : Forgot Password, Social Login, QR Code, Multi-familles, Calendrier, Fil d'activité
- ✅ Pricing : FREE (15 membres) / FAMILLE 4.99€ (100) / FAMILLE+ 9.99€ (illimité)

---

## 📁 02-design/ — Design & UX

Maquettes UI et parcours utilisateur.

| Document | Version | Format | Description |
|----------|---------|--------|-------------|
| [FamilyRoots_UI_Maquettes](02-design/FamilyRoots_UI_Maquettes_v2.1.html) | v2.1 | HTML | 32+ écrans mobile & web — Maquettes interactives haute fidélité |
| [FamilyRoots_UserFlow](02-design/FamilyRoots_UserFlow_v1.0.html) | v1.0 | HTML | Diagramme Mermaid — Parcours utilisateur MVP |
| [FamilyRoots_UserFlow](02-design/FamilyRoots_UserFlow_v1.0.mmd) | v1.0 | Mermaid | Source Mermaid du User Flow |
| [FamilyRoots_Design_System](02-design/FamilyRoots_Design_System_v1.0.html) | v1.0 | HTML | **Design System** — Couleurs, typo, composants Flutter |

### Écrans MVP (18)
1. **Onboarding (4)** : Splash, Slides 1-3
2. **Auth (5)** : Login, Register, Confirmation Email, Créer Famille, Rejoindre Famille
3. **Dashboard (2)** : Dashboard, Notifications
4. **Arbre (2)** : Vue Arbre, Popup Membre
5. **Profils (3)** : Mon Profil, Profil Membre, Modifier Profil
6. **Features (2)** : Invitation, Ajouter Membre

---

## 📁 03-architecture/ — Architecture Technique

Modèle de données, API, et décisions techniques.

| Document | Version | Format | Description |
|----------|---------|--------|-------------|
| [FamilyRoots_Architecture_Auth_ERD](03-architecture/FamilyRoots_Architecture_Auth_ERD_v1.1.html) | v1.1 | HTML | Décision Supabase Auth + ERD 8 tables + Flux backend + Patch clarifications |
| [FamilyRoots_Prisma_Schema](03-architecture/FamilyRoots_Prisma_Schema_v1.0.prisma) | v1.0 | Prisma | Schema Prisma — 8 models, 6 enums, relations, index |
| [FamilyRoots_API_GraphQL_Spec](03-architecture/FamilyRoots_API_GraphQL_Spec_v1.0.html) | v1.0 | HTML | Spécification API complète — Types, Queries, Mutations, Erreurs, Guards |
| [FamilyRoots_Business_Rules](03-architecture/FamilyRoots_Business_Rules_v1.0.html) | v1.0 | HTML | **Règles Métier** — Validations, limites, calculs, flux détaillés |

### Décisions clés (Paquet 2)
- ✅ **Auth** : Supabase Auth = source de vérité (Option A)
- ✅ **Naming** : `Profile` (jamais "User"), `Member` pour l'arbre
- ✅ **Codes** : `family.code` (FAM-) = identifiant, `invitation.code` (INV-) = jeton de jointure
- ✅ **MVP** : 1 famille par profil (contrainte technique)

### Tables BDD (8)
| Table | Description |
|-------|-------------|
| `Profile` | Profil applicatif lié à auth.users |
| `Family` | Groupe familial avec code FAM- |
| `UserFamily` | Pivot Profile↔Family avec rôle |
| `Member` | Personne dans l'arbre |
| `Relationship` | Lien PARENT/CHILD/SPOUSE |
| `Event` | BIRTHDAY/WEDDING/DEATH |
| `Invitation` | Jeton INV- temporaire |
| `Notification` | Alertes in-app |

### API GraphQL — Résumé
- **6 Queries** : me, dashboard, familyTree, member, validateInvitationCode, notifications
- **8 Mutations** : createFamily, joinFamily, createInvitation, addMember, updateMember, updateProfile, markNotificationAsRead, markAllNotificationsAsRead
- **10 Erreurs métier** standardisées

---

## 📁 04-backlog/ — Backlog & Planning

User stories et planification des sprints.

| Document | Version | Format | Description |
|----------|---------|--------|-------------|
| [FamilyRoots_Backlog_MVP](04-backlog/FamilyRoots_Backlog_MVP_v1.0.html) | v1.0 | HTML | 6 Epics, 24 User Stories, ~85 Story Points, 3 Sprints |

### Structure Backlog
| Sprint | Focus | Story Points |
|--------|-------|--------------|
| **Sprint 1** (Sem 1-2) | Infrastructure & Auth | ~30 pts |
| **Sprint 2** (Sem 3-4) | Famille & Arbre | ~30 pts |
| **Sprint 3** (Sem 5-6) | Dashboard & Notifications | ~25 pts |

### Epics MVP
1. ⚙️ Infrastructure & Setup (4 stories)
2. 🔐 Authentification (5 stories)
3. 👨‍👩‍👧‍👦 Gestion Famille (5 stories)
4. 🌳 Arbre Généalogique (5 stories)
5. 🏠 Dashboard & Profils (5 stories)
6. 🔔 Notifications (4 stories)

---

## 📁 00-legacy/ — Archives

Anciennes versions et documents de travail conservés pour référence.

| Dossier | Contenu |
|---------|---------|
| `CDC/` | Spécifications techniques originales (3 PDFs) |
| `maquettes-v1/` | Anciennes maquettes (dashboard, onboarding v1) |
| `prompt-original/` | Prompt maître initial |
| `anciennes-versions/` | Versions précédentes des documents actuels |

---

## 📋 Historique des versions

| Version | Date | Changements |
|---------|------|-------------|
| **v0.3.0** | 12/04/2026 | Paquet 3 — Règles Métier + Design System |
| v0.2.0 | 11/04/2026 | Paquet 2 — Architecture, ERD, Prisma, API Spec, Backlog |
| v0.1.0 | 11/04/2026 | Paquet 1 — PRD, Maquettes v2.1, User Flow, Scope Freeze |

---

## 📊 Statistiques Projet

| Métrique | Valeur |
|----------|--------|
| Documents de référence | 10 |
| Écrans MVP | 18 |
| User Stories | 24 |
| Story Points | ~85 |
| Tables BDD | 8 |
| Queries GraphQL | 6 |
| Mutations GraphQL | 8 |
| Règles Métier documentées | 50+ |

---

## ⚠️ Notes importantes

### Source of Truth
> **Le document `MVP_Scope_Freeze_v1.0.html` fait foi.**  
> En cas de doute sur le périmètre MVP, c'est lui qui prime.

### Conventions de versioning des documents
- Format : `NomDocument_vX.Y.ext`
- `X` = version majeure (changements breaking)
- `Y` = version mineure (ajouts, corrections)

### Ordre de lecture recommandé
1. `MVP_Scope_Freeze` — Comprendre le périmètre
2. `UI_Maquettes` + `UserFlow` — Visualiser le produit
3. `Architecture_Auth_ERD` — Comprendre le modèle technique
4. `API_GraphQL_Spec` — Détails de l'API
5. `Business_Rules` — Règles métier détaillées
6. `Design_System` — Guidelines UI Flutter
7. `Backlog_MVP` — Planifier le développement

---

*Généré le 12 Avril 2026 — FamilyRoots Documentation v0.3.0*
