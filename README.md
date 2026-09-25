# VanshaSetu (वन्शसेतु) — Digital Public Infrastructure Kinship Platform

> **A Production-Grade, Minimalist, Material 3 Digital Public Infrastructure (DPI) Kinship Platform for Global Lineage Mapping, OCP Document Vaulting, Indian Civil Life Events, Matrimony with Gotra Exogamy, Census Demographic Analytics, and WhatsApp-Verifiable Vansha Cards.**

[![Platform Version](https://img.shields.io/badge/version-1.2.0--PROD-blue.svg)](Docs/constitution.md)
[![License: Proprietary / DPI](https://img.shields.io/badge/License-DPI%20Sovereign-green.svg)](README.md)
[![Flutter](https://img.shields.io/badge/Flutter-3.20%2B-02569B?logo=flutter)](https://flutter.dev)
[![Node.js](https://img.shields.io/badge/Node.js-18%2F20%20LTS-339933?logo=node.js)](https://nodejs.org)
[![MySQL](https://img.shields.io/badge/MySQL-8.0%20InnoDB%20TDE-4479A1?logo=mysql)](https://mysql.com)
[![Compliance: DPDP + HIPAA](https://img.shields.io/badge/Compliance-DPDP%202023%20%2B%20HIPAA%20%C2%A7164.312-blueviolet.svg)](Docs/security_compliance.md)
[![Test Suite](https://img.shields.io/badge/Tests-100%2F100%20Passed-brightgreen.svg)](Docs/constitution.md#section-71-the-100-test-pass-mandate)

---

## 1. Executive Summary & Brand Identity

* **Platform Name:** **VanshaSetu** (वन्शसेतु)
  * *Etymology:* *Vansha* (Sanskrit: **वंश** — lineage, ancestry, kinship descent) + *Setu* (Sanskrit: **सेतु** — bridge, connecting channel). Aligns with Indian Digital Public Infrastructure conventions (e.g., API Setu, Aarogya Setu).
  * *Target Domains:* `vanshasetu.in`, `api.vanshasetu.in`, `vanshasetu.org`, `vanshasetu.io`
* **Universal Identifier:** **VUID (VanshaSetu Universal ID)**
  * **Format:** Strictly **12 numeric digits** (`^[0-9]{12}$`) in the integer range $[100000000000, 999999999999]$.
  * **Constraint:** Pure numeric string with zero alphabetic characters, no state prefixes, and no checksum digits.
  * **Display Convention:** Space-delimited 4-digit clusters (`XXXX XXXX XXXX`) for human readability.
* **Identity Credential:** **Vansha Card** (वन्श कार्ड)
  * ISO/IEC 7810 ID-1 standard credit card form factor ($85.60\text{ mm} \times 53.98\text{ mm}$, aspect ratio 1.586).
  * Dynamic HMAC-signed QR code linking directly to the citizen's family tree node (`https://vanshasetu.in/tree/{vuid}`).
  * One-tap native WhatsApp sharing engine for community verification.
* **Canonical Common Domain Models & Zero-Default Mandate:**
  * Universal common models for `religion`, `marital_status`, `gotra`, `category`, `caste`, `blood_group`, `gender`, `relationship`, `qualification_level`, `occupation_sector`, and `document_type`.
  * **Strict Zero-Default Invariant:** No silent fallbacks or placeholders (`|| 'Hindu'`, `|| 'GEN'`, `|| 'Single'`); operations strictly work with explicitly passed values or fail fast with deterministic errors (`HTTP 400 Bad Request`). Enshrined in [Article X of Constitution](Docs/constitution.md#article-x-fail-fast-integrity-universal-prohibition-of-defaults--canonical-domain-models).

---

## 2. Core Value Propositions & Missions

1. **Sovereign Lineage Mapping:**  
   Map citizens into an interactive, multi-generational directed kinship graph spanning ancestors, descendants, spouses, siblings, and legal guardians.
2. **Indian Civil Life Events Registry:**  
   First-class lifecycle tracking for **Child Birth** (with automatic 12-digit VUID allocation and parental kinship linking), **Civil Death** (with municipal certificate logging and status mutation to `Deceased`), and **Civil Marriage** (with legal age validation and reciprocal spousal edges).
3. **Citizen Education & Professional Skills Registry:**  
   Track recognized qualifications from Primary through Doctorate alongside professional occupation sectors (`Government`, `Defense`, `Corporate`, `Healthcare`, `Agriculture`, `Business`, `Legal`) for national human capital mapping.
4. **Indian Matrimony Engine with Gotra Exogamy:**  
   Bride-groom matchmaking engine evaluating Gotra exogamy: detects Sagotra consanguinity, flags `Warning_Sagotra` vs `Permitted_Exogamous`, with comprehensive multi-criteria demographic filtering.
5. **Dynamic National Demographic & Census Population Analytics:**  
   Real-time population census pyramid aggregated dynamically by State, District, Gender, Age Brackets (0-14, 15-24, 25-59, 60+), Social Categories (GEN, OBC, SC, ST, EWS), and digital adoption rates.
6. **Unified Document Vault (OCP & DigiLocker):**  
   Consolidate Indian national credentials (Aadhaar, PAN, Voter ID, Driving License, Passport, Ration Card) under one sovereign profile.
7. **Zero-Knowledge Privacy & DPDP Compliance:**  
   Raw government identity numbers are **never stored in plaintext**. Only salted SHA-256 cryptographic collision tokens (`doc_hash`) and masked display strings (`XXXX-XXXX-1234`) are retained.
8. **Special Investigation Registry (SIR) Anomaly Engine:**  
   Real-time detection of cross-tree document collisions, ghost-voter entries, and multi-ration claiming across district boundaries.
9. **HIPAA § 164.312(b) & DPDP Tamper-Proof Chained Auditing:**  
   Every life event, query, and administrative mutation is recorded with cryptographic SHA-256 blockchain hash chaining, verifiable via `/api/v1/audit/verify-integrity`.

---

## 3. High-Level Architecture & Topology

```
┌──────────────────────────────────────────────────────────────────────────┐
│                   Flutter Client (Android / iOS / Web)                  │
│  - Material 3 Design System        - InteractiveViewer Graph Canvas      │
│  - Demographics Census Dashboard   - Matrimony Matchmaking & Exogamy     │
│  - Immutable Audit Log Inspector   - Vansha Card QR & WhatsApp Exporter  │
│  - Canonical Domain Models Form    - GPS Live Reverse-Geocoding Engine   │
└────────────────────────────────────┬─────────────────────────────────────┘
                                     │ HTTPS / TLS 1.3 (Signed Payload + HMAC)
                                     ▼
┌──────────────────────────────────────────────────────────────────────────┐
│             BigRock Cloud Hosting Middleware (Node.js / Express)         │
│  - 12-Digit Numeric ID Allocator   - Tokenized Document Vault Engine     │
│  - Civil Life Events Router        - Matrimony & Gotra Exogamy Engine    │
│  - Dynamic Demographic Aggregator  - SHA-256 Blockchain Audit Chainer    │
│  - Rate Limiting LRU Eviction      - Zero-Default Fail-Fast Validator    │
└────────────────────────────────────┬─────────────────────────────────────┘
                                     │ Local Socket / 127.0.0.1:3306 (Internal Only)
                                     ▼
┌──────────────────────────────────────────────────────────────────────────┐
│               BigRock Cloud MySQL 8.0 Database (InnoDB TDE)              │
│  - citizens (VUID: CHAR(12))       - relationships (Directed Graph)      │
│  - citizen_documents (Hashed)      - duplicate_conflict_logs (SIR)       │
│  - audit_logs (Chained Hashes)     - citizen_education (Qualifications)  │
│  - marriages (Civil Ledger)        - All 7 Tables ENCRYPTION='Y' (TDE)   │
└──────────────────────────────────────────────────────────────────────────┘
```

---

## 4. Key Platform Features

### 4.1 Interactive Multi-Generational Canvas
* **Infinite Pan & Zoom Canvas:** Built on Flutter's `InteractiveViewer` with scaling bounds from 0.2x to 2.5x and virtual bounds of 2000x2000px.
* **Custom Kinship Rendering:** Smooth cubic Bezier curves connecting parent nodes to children in slate (`#64748B`), and horizontal purple lines (`#9333EA`) joining spouses.
* **Color-Coded Gender Ergonomics:** Deep Blue (`#1E3A8A`) for Male, Maroon (`#BE185D`) for Female, and Amber for Other.
* **Quick Life Event Action Chips:** One-tap action chips directly on canvas to register child births, marriages, deaths, and education credentials.

### 4.2 Vansha Card (वन्श कार्ड) & WhatsApp Share
* **Standard Dimensions:** Proportional to ISO/IEC 7810 ID-1 standard ratio (1.586 aspect ratio).
* **Cyber Slate Theme:** Sleek slate gradient (`#0F172A` $\to$ `#1E293B`) framed with electric cyan (`#38BDF8`) borders and monospace VUID typography.
* **Instant Export:** Converts the live Flutter widget off-screen to a high-resolution PNG image and invokes native Android/iOS share sheets for instant WhatsApp messaging.

### 4.3 Civil Life Events & Lineage Transitions
* **Child Birth:** Allocates unique 12-digit numeric VUID, validates community attributes (`caste`, `category`, `gotra`, `religion`, `geography`), and establishes reciprocal parental kinship edges.
* **Death Registration:** Updates status to `Deceased`, records municipal certificate number and verified cause of death, while preserving ancestral graph links for probate and lineage continuity.
* **Civil Marriage:** Enforces statutory age compliance ($\ge 21$ groom, $\ge 18$ bride), issues marriage registration records, and transitions marital status to `Married`.

### 4.4 Indian Matrimony Engine & Gotra Exogamy
* **Consanguinity Defense:** Instant detection of Sagotra candidates with prominent `Warning_Sagotra` (`⚠️ Sagotra Alert (सगोत्र)`) versus certified `Permitted_Exogamous` (`✅ Exogamous Match (विवाह योग्य)`).
* **Demographic Filtering:** Age range sliders, community/caste filters, state/district selectors, height thresholds, and minimum education requirements.

### 4.5 Real-Time Demographic & Census Analytics
* **Interactive Population Dashboards:** Dynamic population counts filtered across all 28 states and union territories.
* **Demographic Breakdown:** Dynamic gender distribution gauges, five-tier age pyramids, and social category percentages.

### 4.6 Zero-Default Fail-Fast Integrity
* **No Placeholders:** Rejects any input relying on fallback defaults. Every civil entity must be explicitly specified according to the canonical models or the system returns an immediate `400 Bad Request`.

---

## 5. Repository Documentation Roadmap

| Document | Description | Direct Link |
| :--- | :--- | :--- |
| **Sovereign Constitution** | Supreme technical bylaws, zero-trust rules, Article X zero-default mandate | [constitution.md](Docs/constitution.md) |
| **Master Specification** | Full technical, mathematical, DDL, and API specification | [vanshasetu_master_specification.md](Docs/vanshasetu_master_specification.md) |
| **Architectural Plan** | Detailed system architecture, security compliance & runbook | [plan.md](Docs/plan.md) |
| **Implementation Tasks** | 13-phase hierarchical checklist with all tracking tasks completed | [tasks.md](Docs/tasks.md) |
| **Security & HIPAA Specification** | Zero-trust, E2EE, TDE, and HIPAA/DISHA/DPDP architecture | [security_compliance.md](Docs/security_compliance.md) |
| **Production Runbook** | BigRock cPanel deployment, CloudLinux Passenger & SSL setup | [deployment_runbook.md](Docs/deployment_runbook.md) |
| **Client Documentation** | Flutter client architecture, state management & screens | [client/README.md](client/README.md) |

---

## 6. Technology Stack Summary

| Layer | Component | Technologies |
| :--- | :--- | :--- |
| **Mobile & Web Client** | Frontend Application | Flutter 3.20+, Dart 3.2+, Material 3, Riverpod, `qr_flutter`, `screenshot`, `share_plus` |
| **Canonical Models** | Common Ontologies | `civil_models.js` (Backend) & `civil_models.dart` (Client) |
| **Middleware API** | Backend Service | Node.js 18/20 LTS, Express, Helmet, CORS, `mysql2/promise`, CloudLinux Passenger |
| **Database** | Relational Graph Store | MySQL 8.0 Community / CloudLinux cPanel MySQL, InnoDB, `utf8mb4_unicode_ci`, TDE `ENCRYPTION='Y'` |
| **Security & Privacy** | Cryptography & Compliance | Salted SHA-256 (`doc_hash`), AES-256-GCM metadata, TLS 1.3, CSPRNG VUID, SHA-256 Blockchain Audit Chaining |
| **Hosting & Infra** | Cloud Infrastructure | BigRock Cloud Linux Shared/VPS Hosting, AutoSSL / Let's Encrypt |

---

## 7. Quickstart Guide (Local Development)

### 7.1 Database Setup
1. Launch MySQL 8.0 server.
2. Execute the complete DDL script in `database/schema.sql` (creates all 7 tables with TDE and CHECK constraints).
3. Optionally load seed data via `database/seed.sql`.
4. Validate database schema compliance:
   ```bash
   node database/validate_ddl.js
   ```

### 7.2 Backend Middleware Setup
```bash
# Clone the repository
cd FamilyTree

# Install dependencies
npm --prefix backend install

# Configure environment variables (.env)
DB_HOST=127.0.0.1
DB_USER=vanshasetu_user
DB_PASSWORD=YourSecurePassword
DB_NAME=vanshasetu_db
HASH_SALT=<random-64-hex-chars>
FLE_MASTER_KEY=<random-64-hex-chars>
API_HMAC_SECRET=<random-64-hex-chars>
PORT=3000

# Start development server
node backend/server.js
```

### 7.3 Launching the Application (`run_app.sh`)

Use the unified executable runner script from the root workspace directory:

```bash
# Launch Flutter Web on Google Chrome (also automatically verifies/boots the backend API)
./run_app.sh web

# Launch on connected iOS device or iOS Simulator
./run_app.sh ios

# Launch on connected Android device or Emulator
./run_app.sh android

# Launch as macOS Desktop application
./run_app.sh macos
```

### 7.4 Production Build & cPanel Deployment

```bash
# 1. Execute full production build pipeline (runs tests, compiles Flutter Web, stages API):
npm run build:prod

# 2. Deploy or package for BigRock CloudLinux cPanel:
npm run deploy:cpanel

# 3. Verify deployed production health and security headers:
npm run verify:deploy -- https://api.vanshasetu.in
```

---

## 8. Comprehensive Verification & 100% Test Coverage

VanshaSetu implements rigorous, multi-layered automated testing spanning the entire stack with **109 automated assertions & tests passing at a 100% success rate**.

```
========================================================================================
🛡️  VANSHACERTIFIED — 100% TEST COVERAGE MATRIX (109 / 109 PASSING)
========================================================================================
  Layer               Test Suite                       Tests   Pass   Fail   Coverage
────────────────────────────────────────────────────────────────────────────────────────
  Database DDL        database/validate_ddl.js            30     30      0    100% PASS
  Backend API Routes  backend/tests/api_routes.test.js    13     13      0    100% PASS
  E2E Lifecycle & SIR backend/tests/e2e_workflow.test.js  10     10      0    100% PASS
  Civil Events & More backend/tests/extended_features      8      8      0    100% PASS
  Crypto & E2EE       backend/tests/crypto.test.js         6      6      0    100% PASS
  Multilingual Suite  client/test/localization_test.dart   6      6      0    100% PASS
  Security Guard      backend/tests/security_middleware    5      5      0    100% PASS
  Client Models       client/test/models_test.dart         5      5      0    100% PASS
  VUID Engine         backend/tests/vuid.test.js           3      3      0    100% PASS
  Kinship Canvas UI   client/test/tree_canvas_test.dart    3      3      0    100% PASS
  Client Extended UI  client/test/extended_features_test   3      3      0    100% PASS
  Client API Client   client/test/api_client_test.dart     3      3      0    100% PASS
  Theme & Colors      client/test/theme_test.dart          3      3      0    100% PASS
  Registration UI     client/test/registration_screen      2      2      0    100% PASS
  Core Services       client/test/services_test.dart       2      2      0    100% PASS
  HIPAA § 164.312     backend/tests/audit.test.js          2      2      0    100% PASS
  Vansha Card UI      client/test/vansha_card_widget       1      1      0    100% PASS
  App Smoke Test      client/test/widget_test.dart         1      1      0    100% PASS
────────────────────────────────────────────────────────────────────────────────────────
  TOTAL COMPLIANCE    Entire Workspace                   109    109      0    100% PASS
========================================================================================
```

### Running Automated Tests

```bash
# Run all tests (backend + client + database) in a single pass:
npm run test:all && npm run validate:db

# Run backend API, security, cryptographic, and HIPAA tests:
npm test

# Run Flutter client unit, model, service, and widget tests:
npm run test:client

# Validate MySQL database DDL, constraints, TDE flags, and HIPAA schema:
npm run validate:db
```

---

## 9. License & Governance

VanshaSetu is developed under Digital Public Infrastructure (DPI) sovereign guidelines for kinship governance, socio-economic research, civil registry assistance, and demographic transparency. All platform modifications are governed unconditionally by the [Sovereign Constitution](Docs/constitution.md).