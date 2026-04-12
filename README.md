# 🌳 FamilyRoots

> Application mobile-first de généalogie collaborative — construis ton arbre, connecte ta famille.

![Version](https://img.shields.io/badge/version-v0.4.0-green.svg)
![Status](https://img.shields.io/badge/status-MVP%20en%20construction-blue.svg)
![Stack](https://img.shields.io/badge/stack-Flutter%20%7C%20NestJS%20%7C%20GraphQL%20%7C%20Supabase-purple.svg)

---

## 📋 À propos

**FamilyRoots** est une application de généalogie collaborative pensée d’abord pour le mobile.  
L’objectif est de permettre à une famille de :

- 🌲 construire un arbre généalogique partagé
- 👨‍👩‍👧‍👦 inviter des proches à contribuer
- 🎂 suivre les anniversaires et événements familiaux
- 🔐 gérer l’accès via authentification et invitations sécurisées

### Différenciateurs
- **Collaboration native** — plusieurs membres peuvent enrichir l’arbre
- **Support des structures familiales complexes** — y compris la polygamie
- **Mobile-first** — usage simple et quotidien
- **Freemium** — version gratuite pour les petites familles, plans évolutifs ensuite

---

## 🚧 État actuel du projet

| Bloc | Statut | Détails |
|---|---|---|
| Documentation produit | ✅ Terminé | PRD, scope freeze, audit, user flow, design system |
| Architecture technique | ✅ Terminé | ERD, Prisma schema, API GraphQL, backlog |
| Backend | ✅ Initialisé | NestJS + GraphQL + Prisma + Supabase |
| Authentification | ✅ Fonctionnelle | Supabase Auth côté app |
| App Flutter | ✅ Initialisée | thème, routing, écrans MVP de base |
| Navigation | ✅ Fonctionnelle | login, register, home, create/join family, tree, profile |
| Intégration Flutter ↔ GraphQL | 🚧 En cours | Sprint 3 |
| Arbre interactif complet | 🚧 En cours | placeholder / intégration progressive |
| Notifications avancées | ⏳ À venir | centre de notifications + logique métier complète |

**Version actuelle :** `v0.4.0`

---

## 📁 Structure du projet

```text
FamilyRoot/
├── docs/
│   ├── 00-legacy/              # Archives, anciennes versions, premières maquettes
│   ├── 01-product/             # PRD, scope freeze, audit, charte
│   ├── 02-design/              # Maquettes, user flow, design system
│   ├── 03-architecture/        # ERD, business rules, Prisma, API GraphQL
│   ├── 04-backlog/             # Backlog MVP
│   └── INDEX.md
│
├── src/
│   ├── backend/                # NestJS + GraphQL + Prisma + Supabase
│   └── mobile/                 # Flutter app
│
├── .env.template
├── CHANGELOG.md
├── README.md
└── .gitignore
```

---

## 🛠️ Stack technique

### Backend
- **NestJS**
- **GraphQL (Apollo)**
- **Prisma ORM**
- **PostgreSQL via Supabase**
- **Supabase Auth**
- **Supabase Storage**

### Mobile
- **Flutter 3.x**
- **Riverpod**
- **GoRouter**
- **Supabase Flutter**
- **GraphQL côté client** en cours d’intégration

### Outils
- Git / GitHub
- Chrome pour debug web Flutter
- Semantic Versioning
- Documentation produit structurée dans `docs/`

---

## ✅ Ce qui fonctionne déjà

### Backend
- serveur NestJS démarrable
- schéma Prisma en place
- modules principaux :
  - Auth
  - Profile
  - Family
  - Member
  - Invitation
  - Notification
- GraphQL opérationnel

### Mobile
- app Flutter lancée
- thème FamilyRoots appliqué
- authentification Supabase fonctionnelle
- écrans présents :
  - Login
  - Register
  - Home
  - Create Family
  - Join Family
  - Tree
  - Profile
- navigation via GoRouter

### Produit / Architecture
- MVP défini
- architecture auth clarifiée
- conventions `Profile` / `Member` / `Family` figées
- distinction `family.code` / `invitation.code` documentée

---

## 🧭 Roadmap immédiate

### Sprint 3 — priorité actuelle
Connexion complète **Flutter ↔ Backend GraphQL** :

- [ ] brancher `me`
- [ ] brancher `createFamily`
- [ ] brancher `joinFamily`
- [ ] brancher `familyTree`
- [ ] brancher `dashboard`
- [ ] injecter le JWT Supabase dans les headers GraphQL
- [ ] remplacer les placeholders par des données réelles

### Ensuite
- [ ] arbre généalogique interactif complet
- [ ] centre de notifications
- [ ] dashboard dynamique
- [ ] stabilisation UX (loading, empty states, errors)
- [ ] préparation d’une release MVP exploitable

---

## ▶️ Lancer le projet en local

### 1. Cloner le repo
```bash
git clone git@github.com:Steve-Landry-NONO/FamilyRoot.git
cd FamilyRoot
```

### 2. Backend
```bash
cd src/backend
npm install
npm run start:dev
```

Le backend doit ensuite être disponible localement sur son port de dev.

### 3. Mobile Flutter
```bash
cd src/mobile
flutter pub get
flutter run -d chrome
```

---

## 🔐 Configuration

Un fichier `.env.template` est présent à la racine du projet.

Prévois au minimum :
- URL Supabase
- clé publique Supabase
- variables backend nécessaires à NestJS / Prisma
- URL du backend GraphQL pour Flutter

---

## 📄 Documentation

La documentation projet est centralisée dans :

```text
docs/INDEX.md
```

### Documents clés
| Document | Rôle |
|---|---|
| `docs/01-product/FamilyRoots_MVP_Scope_Freeze_v1.0.html` | périmètre MVP gelé |
| `docs/03-architecture/FamilyRoots_Architecture_Auth_ERD_v1.1.html` | auth + ERD |
| `docs/03-architecture/FamilyRoots_API_GraphQL_Spec_v1.0.html` | contrat API GraphQL |
| `docs/03-architecture/FamilyRoots_Prisma_Schema_v1.0.prisma` | modèle Prisma |
| `docs/04-backlog/FamilyRoots_Backlog_MVP_v1.0.html` | backlog MVP |

---

## 🏷️ Versioning

Le projet suit une logique **SemVer**.

| Version | Signification |
|---|---|
| `v0.3.0` | documentation structurée et repo réorganisé |
| `v0.4.0` | backend + app Flutter + auth + navigation de base |
| `v0.5.0` | cible probable après intégration GraphQL Sprint 3 |
| `v1.0.0` | MVP stable prêt à être présenté / déployé |

---

## 👤 Auteur

**Steve Landry KOUOKAM NONO**
- HETIC — Mastère Data & IA
- Data Analyst @ Michelin
- LinkedIn : https://www.linkedin.com/in/steve-landry-kouokam-nono-18b175291/

---

## 📝 Licence

Projet privé — tous droits réservés © 2026 Steve Landry KOUOKAM NONO.

---

*Dernière mise à jour : 12 avril 2026*
