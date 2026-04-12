# 🌳 FamilyRoots

> Application mobile de généalogie collaborative — Construis ton arbre, connecte ta famille.

[![Version](https://img.shields.io/badge/version-0.2.0-green.svg)](https://github.com/Steve-Music/FamilyRoots)
[![Status](https://img.shields.io/badge/status-MVP%20Design-blue.svg)]()
[![Stack](https://img.shields.io/badge/stack-Flutter%20%7C%20NestJS%20%7C%20Supabase-purple.svg)]()

---

## 📋 À propos

**FamilyRoots** est une application mobile-first permettant aux familles de :
- 🌲 Construire leur arbre généalogique de manière collaborative
- 👨‍👩‍👧‍👦 Inviter des proches à contribuer
- 🎂 Recevoir des notifications pour les anniversaires et événements familiaux
- 🔐 Gérer les accès avec un système d'invitation sécurisé

### Différenciateurs clés
- **Collaboration native** — Chaque membre peut enrichir l'arbre
- **Support polygamie** — Adapté aux structures familiales africaines et autres
- **Mobile-first** — Optimisé pour l'usage quotidien
- **Freemium** — Gratuit jusqu'à 15 membres, plans payants pour les grandes familles

---

## 🏗️ État du projet

| Phase | Statut | Description |
|-------|--------|-------------|
| **Paquet 1** — Fondations Produit | ✅ Terminé | PRD, Maquettes, User Flow, Scope Freeze |
| **Paquet 2** — Architecture Technique | ✅ Terminé | ERD, Prisma, API GraphQL, Backlog |
| **Paquet 3** — Règles Métier & Design System | 🔜 À venir | Règles métier, corrections UI, composants |
| **Sprint 1** — Infrastructure & Auth | ⏳ Planifié | NestJS, Supabase, Flutter setup |

**Version actuelle :** `v0.2.0` (Paquet 2 complet)

---

## 📁 Structure du projet

```
FamilyRoots/
├── docs/                          # Documentation projet
│   ├── 01-product/                # PRD, Scope, Audit
│   ├── 02-design/                 # Maquettes, User Flows
│   ├── 03-architecture/           # ERD, Prisma, API Spec
│   ├── 04-backlog/                # User Stories, Sprints
│   └── INDEX.md                   # Table des matières
│
├── src/                           # Code source (à venir)
│   ├── backend/                   # NestJS + GraphQL
│   └── mobile/                    # Flutter
│
└── README.md
```

---

## 🛠️ Stack Technique

### Backend
- **Framework:** NestJS (Node.js)
- **API:** GraphQL (Apollo Server, code-first)
- **ORM:** Prisma
- **Database:** PostgreSQL (Supabase)
- **Auth:** Supabase Auth (JWT)
- **Storage:** Supabase Storage (photos)

### Mobile
- **Framework:** Flutter 3.x
- **State:** Riverpod
- **Navigation:** GoRouter
- **GraphQL:** graphql_flutter
- **Push:** Firebase Cloud Messaging

### Infrastructure
- **Database/Auth/Storage:** Supabase
- **CI/CD:** GitHub Actions
- **Hosting:** À définir (Vercel/Railway pour backend)

---

## 📊 MVP Scope

### Écrans (18)
- Onboarding (4) — Splash, slides intro
- Auth (5) — Login, Register, Confirmation, Créer/Rejoindre famille
- Dashboard (2) — Stats, Notifications
- Arbre (2) — Vue interactive, Popup membre
- Profils (3) — Mon profil, Profil membre, Édition
- Features (2) — Invitation, Ajouter membre

### Tables BDD (8)
`Profile` · `Family` · `UserFamily` · `Member` · `Relationship` · `Event` · `Invitation` · `Notification`

### Hors MVP (V1.5+)
- Forgot Password, Social Login
- QR Code invitation
- Multi-familles
- Calendrier dédié
- Fil d'activité
- Web App

---

## 📄 Documentation

Voir [docs/INDEX.md](docs/INDEX.md) pour la liste complète des documents.

### Documents clés
| Document | Description |
|----------|-------------|
| [MVP Scope Freeze](docs/01-product/FamilyRoots_MVP_Scope_Freeze_v1.0.html) | Source of Truth — Périmètre gelé |
| [Architecture Auth + ERD](docs/03-architecture/FamilyRoots_Architecture_Auth_ERD_v1.1.html) | Modèle de données + décisions techniques |
| [API GraphQL Spec](docs/03-architecture/FamilyRoots_API_GraphQL_Spec_v1.0.html) | Types, Queries, Mutations |
| [Backlog MVP](docs/04-backlog/FamilyRoots_Backlog_MVP_v1.0.html) | 24 User Stories sur 3 sprints |

---

## 🏷️ Versioning

Ce projet utilise [Semantic Versioning](https://semver.org/).

| Tag | Description |
|-----|-------------|
| `v0.1.0` | Paquet 1 — Fondations Produit |
| `v0.2.0` | Paquet 2 — Architecture Technique |
| `v1.0.0` | MVP prêt pour release |

---

## 👤 Auteur

**Steve Landry KOUOKAM NONO**
- Formation : HETIC Mastère Data & IA
- Alternance : Data Analyst @ Michelin
- Contact : [LinkedIn](https://www.linkedin.com/in/steve-landry-kouokam-nono-18b175291/)

---

## 📝 License

Ce projet est privé. Tous droits réservés © 2026 Steve Landry KOUOKAM NONO.

---

*Dernière mise à jour : 11 Avril 2026*
