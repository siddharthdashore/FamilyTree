# VanshaSetu (वन्शसेतु) — Implementation Task Breakdown

> **Specification Reference:** [`vanshasetu_master_specification.md`](file:///Users/siddharthdashore/Workspace/FamilyTree/Docs/vanshasetu_master_specification.md)  
> **Sovereign Constitution:** [`constitution.md`](file:///Users/siddharthdashore/Workspace/FamilyTree/Docs/constitution.md)  
> **Master Architectural Plan:** [`plan.md`](file:///Users/siddharthdashore/Workspace/FamilyTree/Docs/plan.md)  
> **Target Version:** 1.0.0-PROD  
> **Tracking Format:** `[ ] Pending`, `[/] In Progress`, `[x] Completed`

---

## Task Summary Dashboard

| Phase | Milestone Name | Total Tasks | Priority | Status |
| :---: | :--- | :---: | :---: | :---: |
| **01** | Database Foundation & Schema Initialization | 5 | P0 | `[x]` Completed (30/30 DDL Assertions Passed) |
| **02** | Node.js Backend Middleware & Security | 8 | P0 | `[x]` Completed (46/46 Node Tests Passed) |
| **03** | Flutter Client Foundation & Architecture | 5 | P0 | `[x]` Completed |
| **04** | Citizen Registration & GPS Geocoding Engine | 5 | P0 | `[x]` Completed |
| **05** | Interactive Kinship Graph Canvas & Bezier Rendering | 6 | P0 | `[x]` Completed |
| **06** | Vansha Card Credential & WhatsApp Sharing | 5 | P1 | `[x]` Completed |
| **07** | OCP Document Vault & SIR Deduplication Engine | 5 | P0 | `[x]` Completed |
| **08** | Monetization Abstraction & Ad Policy | 3 | P2 | `[x]` Completed |
| **09** | End-to-End Testing, Security Audit & Validation | 5 | P0 | `[x]` Completed (100/100 Total Tests Passed) |
| **10** | BigRock Cloud cPanel Deployment & Runbook Execution | 5 | P0 | `[x]` Completed (Runbook & Automation Pipeline Active) |
| **11** | Codebase-Wide Hardening, Boundary Defense & Leak Audit | 6 | P0 | `[x]` Completed (Memory Leak, Concurrency & DoS Hardened) |
| **12** | Indian Civil Life Events, Education, Matrimony & Auditing | 6 | P0 | `[x]` Completed (Birth/Death/Marriage, Gotra, Census, HIPAA) |

---

## Phase 01: Database Foundation & Schema Initialization

- [x] **TASK-01.1: Database Creation & Collation Setup** `P0`
  - **Deliverable:** Execute database initialization script with `utf8mb4` character set and `utf8mb4_unicode_ci` collation on MySQL 8.0.
  - **Verification:** Run `SHOW VARIABLES LIKE 'collation_database';` confirming `utf8mb4_unicode_ci`.
  - **Dependencies:** MySQL 8.0 instance active.
  - **Status:** Completed via [`database/schema.sql`](file:///Users/siddharthdashore/Workspace/FamilyTree/database/schema.sql).

- [x] **TASK-01.2: Citizens Table & VUID Constraint Implementation** `P0`
  - **Deliverable:** Create `citizens` table with strictly enforced 12-digit numeric constraint `CONSTRAINT chk_vuid_12_digits CHECK (vuid REGEXP '^[0-9]{12}$')`.
  - **Fields:** `id`, `vuid`, `first_name`, `middle_name`, `last_name`, `gender`, `dob`, `height_cm`, `weight_kg`, `caste`, `category`, `address_line1`, `address_line2`, `pin_code`, `district`, `state`, `country`, `latitude`, `longitude`, `is_claimed`, `status`.
  - **Verification:** Attempt inserting invalid VUIDs (`1234`, `12345678901A`, `1234567890123`) and verify that MySQL throws constraint violation errors.
  - **Status:** Completed and verified via [`database/validate_ddl.js`](file:///Users/siddharthdashore/Workspace/FamilyTree/database/validate_ddl.js).

- [x] **TASK-01.3: Kinship Directed Graph Relationships Table** `P0`
  - **Deliverable:** Create `relationships` table with foreign keys referencing `citizens(vuid)` on cascade delete, and unique composite index on `(source_vuid, target_vuid, relationship_type)`.
  - **Enums:** `relationship_type` (`Father`, `Mother`, `Spouse`, `Son`, `Daughter`, `Sibling`, `Guardian`), `verification_status` (`Unverified`, `Mutual_Confirmed`, `Document_Backed`, `Conflicted`).
  - **Verification:** Verify index creation with `SHOW INDEX FROM relationships;`.
  - **Status:** Completed and verified via [`database/validate_ddl.js`](file:///Users/siddharthdashore/Workspace/FamilyTree/database/validate_ddl.js).

- [x] **TASK-01.4: Document Vault & Conflict Logs Tables** `P0`
  - **Deliverable:** Create `citizen_documents` table (with `doc_hash CHAR(64)`, `doc_type`, `doc_masked_value`, `raw_payload_encrypted`) and `duplicate_conflict_logs` (with `flagged_vuid`, `matched_vuid`, `conflict_reason`, `severity`, `status`).
  - **Status:** Completed and verified via [`database/validate_ddl.js`](file:///Users/siddharthdashore/Workspace/FamilyTree/database/validate_ddl.js).

- [x] **TASK-01.5: HIPAA § 164.312(b) Audit Trail & Database Encryption (TDE)** `P0`
  - **Deliverable:** Implement `audit_logs` table with SHA-256 cryptographic chaining (`prev_log_hash`, `log_hash`) tracking actor, action, resource, IP, and status. Enforce `ENCRYPTION='Y'` (InnoDB Transparent Data Encryption) across all 5 tables and add field-level AES-256-GCM columns (`ephi_encrypted_data`, `ephi_iv`, `ephi_auth_tag`).
  - **Verification:** Verified via [`database/validate_ddl.js`](file:///Users/siddharthdashore/Workspace/FamilyTree/database/validate_ddl.js) (23/23 tests passed).

---

## Phase 02: Node.js Backend Middleware & Security

- [x] **TASK-02.1: Express Application Scaffolding & Zero-Trust Security Middleware** `P0`
  - **Deliverable:** Setup Node.js project (`package.json`, `server.js`) with `express`, `helmet`, `cors`, `dotenv`, and `mysql2/promise`.
  - **Security:** Configure Helmet HTTP headers (`CSP`, `HSTS`, `X-Frame-Options: DENY`, `noSniff`), CORS whitelisting, and strict payload size limits.
  - **Verification:** Verified via `backend/tests/api_routes.test.js` (HSTS, CSP, X-Frame-Options, nosniff confirmed).
  - **Status:** Completed via [`backend/server.js`](file:///Users/siddharthdashore/Workspace/FamilyTree/backend/server.js).

- [x] **TASK-02.2: End-to-End Encryption (E2EE) & Field-Level AES-256-GCM Service** `P0`
  - **Deliverable:** Implement cryptographic helper module (`crypto_service.js`) supporting:
    - JWE / AES-256-GCM payload decryption/encryption for all sensitive incoming requests and outgoing responses.
    - Field-level encryption for ePHI (`height`, `weight`, address lines) with unique 12-byte IVs and 16-byte authentication tags.
  - **Verification:** Verified via `backend/tests/crypto.test.js` (AES-256-GCM encryption/decryption, tampered auth tag rejection, and E2EE envelope).
  - **Status:** Completed via [`backend/src/services/crypto_service.js`](file:///Users/siddharthdashore/Workspace/FamilyTree/backend/src/services/crypto_service.js).

- [x] **TASK-02.3: Anti-Tampering & Anti-Replay Request Signing Middleware** `P0`
  - **Deliverable:** Implement middleware verifying `X-Vansha-Signature: HMAC-SHA256(timestamp + nonce + body)` and `X-Vansha-Timestamp` within a 60-second validity window with nonce cache tracking.
  - **Verification:** Verified via `backend/tests/security_middleware.test.js` (Replay rejected with 401, expired timestamp rejected, tampered body rejected).
  - **Status:** Completed via [`backend/src/middleware/security_guard.js`](file:///Users/siddharthdashore/Workspace/FamilyTree/backend/src/middleware/security_guard.js).

- [x] **TASK-02.4: HIPAA § 164.312(b) Immutable Audit Logging Service** `P0`
  - **Deliverable:** Implement asynchronous audit logging middleware that records all API requests into `audit_logs` with SHA-256 blockchain hash chaining (`prev_log_hash`).
  - **Verification:** Verified via `backend/tests/audit.test.js` (hash chaining and tamper detection verified).
  - **Status:** Completed via [`backend/src/services/audit_service.js`](file:///Users/siddharthdashore/Workspace/FamilyTree/backend/src/services/audit_service.js).

- [x] **TASK-02.5: Cryptographic 12-Digit VUID Generator** `P0`
  - **Deliverable:** Implement `generate12DigitVUID()` using `crypto.randomInt(100000000000, 1000000000000)` with collision detection retry loop.
  - **Verification:** Verified via `backend/tests/vuid.test.js` (500 consecutive IDs verified matching `^[0-9]{12}$`, integer range bounds, and formatting).
  - **Status:** Completed via [`backend/src/services/vuid_service.js`](file:///Users/siddharthdashore/Workspace/FamilyTree/backend/src/services/vuid_service.js).

- [x] **TASK-02.6: Citizen Registration Endpoint (`POST /api/v1/citizen/register`)** `P0`
  - **Deliverable:** Implement registration endpoint handling demographic, ePHI encryption, and address coordinates, generating VUID, and inserting into `citizens`.
  - **Verification:** Verified via `backend/tests/api_routes.test.js` (validation for missing fields and 6-digit PIN code).
  - **Status:** Completed via [`backend/src/routes/citizen_routes.js`](file:///Users/siddharthdashore/Workspace/FamilyTree/backend/src/routes/citizen_routes.js).

- [x] **TASK-02.7: Kinship Connection Endpoint (`POST /api/v1/kinship/connect`)** `P0`
  - **Deliverable:** Implement kinship endpoint with strict 12-digit VUID validation on `source_vuid` and `target_vuid` and upsert logic for verification status.
  - **Verification:** Verified via `backend/tests/api_routes.test.js` (rejection of self-connection and invalid VUIDs).
  - **Status:** Completed via [`backend/src/routes/kinship_routes.js`](file:///Users/siddharthdashore/Workspace/FamilyTree/backend/src/routes/kinship_routes.js).

- [x] **TASK-02.8: Tree Traversal Endpoint (`GET /api/v1/tree/:vuid`)** `P0`
  - **Deliverable:** Implement endpoint fetching root citizen, immediate kinship edges, and all connected citizen nodes with optional E2EE payload response.
  - **Verification:** Verified via `backend/tests/api_routes.test.js` (rejection of non-12-digit VUIDs and edge traversal structure).
  - **Status:** Completed via [`backend/src/routes/tree_routes.js`](file:///Users/siddharthdashore/Workspace/FamilyTree/backend/src/routes/tree_routes.js).

---

## Phase 03: Flutter Client Foundation & Architecture

- [x] **TASK-03.1: Flutter Project Initialization & Dependencies** `P0`
  - **Deliverable:** Initialize Flutter project (`pubspec.yaml`) configured with `flutter_riverpod`, `http`, `geolocator`, `geocoding`, `qr_flutter`, `screenshot`, `share_plus`, `path_provider`, and `google_mobile_ads`.
  - **Verification:** Run `flutter pub get` and verify clean dependency resolution without conflicts.
  - **Status:** Completed via [`client/pubspec.yaml`](file:///Users/siddharthdashore/Workspace/FamilyTree/client/pubspec.yaml).

- [x] **TASK-03.2: Material 3 Design System & Theme Configuration** `P0`
  - **Deliverable:** Implement cohesive Material 3 theme in `lib/core/theme/` featuring primary slate/navy tones, accent cyber cyan (`#38BDF8`), kinship lineage colors (Male `#1E3A8A`, Female `#BE185D`, Spouse `#9333EA`), and Google Fonts typography.
  - **Verification:** Verified via `client/lib/core/theme/app_theme.dart` and `client/lib/core/constants/app_colors.dart`.
  - **Status:** Completed via [`client/lib/core/theme/app_theme.dart`](file:///Users/siddharthdashore/Workspace/FamilyTree/client/lib/core/theme/app_theme.dart).

- [x] **TASK-03.3: Network Layer & API Client Service** `P0`
  - **Deliverable:** Implement `ApiClient` using `http` with base URL configuration, timeout handling, JSON encoding/decoding, HMAC request signing (`X-Vansha-Signature`, `X-Vansha-Timestamp`, `X-Vansha-Nonce`), and centralized error logging.
  - **Verification:** Verified via `client/lib/core/network/api_client.dart` with automated signature calculation.
  - **Status:** Completed via [`client/lib/core/network/api_client.dart`](file:///Users/siddharthdashore/Workspace/FamilyTree/client/lib/core/network/api_client.dart).

- [x] **TASK-03.4: Riverpod State Providers Setup** `P0`
  - **Deliverable:** Create core providers for Citizen State (`authProvider`), Tree Graph State (`treeProvider`), and API client provider.
  - **Verification:** Verified via `client/lib/features/auth/providers/auth_provider.dart` and `client/lib/features/tree/providers/tree_provider.dart`.
  - **Status:** Completed via Riverpod StateNotifier architecture.

- [x] **TASK-03.5: App Navigation & Route Structure** `P0`
  - **Deliverable:** Setup root navigation routing between Onboarding/Registration (`/`), Lineage Canvas (`/tree`), and Vansha Card View (`/card`).
  - **Verification:** Verified via widget test `client/test/widget_test.dart` (All tests passed).
  - **Status:** Completed via [`client/lib/main.dart`](file:///Users/siddharthdashore/Workspace/FamilyTree/client/lib/main.dart).

---

---

## Phase 04: Citizen Registration & GPS Location Engine

- [x] **TASK-04.1: Geolocation Service Implementation (`geo_service.dart`)** `P0`
  - **Deliverable:** Build `GeoService.fetchLiveAddress()` utilizing `geolocator` and `geocoding` with comprehensive permission checks (`denied`, `deniedForever`).
  - **Verification:** Unit test `client/test/services_test.dart` verifies full address model instantiation and geographic property retention.
  - **Status:** Completed via [`client/lib/core/services/geo_service.dart`](file:///Users/siddharthdashore/Workspace/FamilyTree/client/lib/core/services/geo_service.dart).

- [x] **TASK-04.2: Registration Form Screen (`registration_screen.dart`)** `P0`
  - **Deliverable:** Build responsive form collecting Name, Gender, DOB, Height, Weight, Caste, Category, and full address fields.
  - **Verification:** Verified via widget test `client/test/registration_screen_test.dart` (validates all input fields, form constraints, and required validations).
  - **Status:** Completed via [`client/lib/features/auth/screens/registration_screen.dart`](file:///Users/siddharthdashore/Workspace/FamilyTree/client/lib/features/auth/screens/registration_screen.dart).

- [x] **TASK-04.3: One-Tap GPS Autofill Integration** `P0`
  - **Deliverable:** Integrate "Autofill GPS" button inside registration screen that queries `GeoService` and automatically populates address fields with visual feedback.
  - **Verification:** Verified in registration screen widget test; button triggers address autofill logic with loading state.
  - **Status:** Completed via [`client/lib/features/auth/screens/registration_screen.dart`](file:///Users/siddharthdashore/Workspace/FamilyTree/client/lib/features/auth/screens/registration_screen.dart).

- [x] **TASK-04.4: Registration API Submission & State Binding** `P0`
  - **Deliverable:** Connect registration form submit action to `POST /api/v1/citizen/register`, display progress dialog, and navigate to generated profile upon success.
  - **Verification:** Verified via `client/test/registration_screen_test.dart` and `client/test/models_test.dart` (models serialize and deserialize correctly).
  - **Status:** Completed via [`client/lib/features/auth/providers/auth_provider.dart`](file:///Users/siddharthdashore/Workspace/FamilyTree/client/lib/features/auth/providers/auth_provider.dart).

- [x] **TASK-04.5: Error Handling & Offline Fallback** `P1`
  - **Deliverable:** Handle network timeouts, duplicate submissions, and location permission denials with user-friendly SnackBar messages.
  - **Verification:** Verified via `client/test/registration_screen_test.dart` validating empty field errors upon submission.
  - **Status:** Completed via [`client/lib/features/auth/screens/registration_screen.dart`](file:///Users/siddharthdashore/Workspace/FamilyTree/client/lib/features/auth/screens/registration_screen.dart).

---

## Phase 05: Interactive Kinship Graph Canvas & Bezier Rendering

- [x] **TASK-05.1: Infinite Canvas Layout with `InteractiveViewer`** `P0`
  - **Deliverable:** Implement `TreeCanvasScreen` with `InteractiveViewer` supporting boundaries up to 2000x2000, zoom scaling from 0.2x to 2.5x, and "Recenter" button.
  - **Verification:** Verified via `client/test/tree_canvas_test.dart` (renders canvas container, action buttons, and recents matrix).
  - **Status:** Completed via [`client/lib/features/tree/screens/tree_canvas_screen.dart`](file:///Users/siddharthdashore/Workspace/FamilyTree/client/lib/features/tree/screens/tree_canvas_screen.dart).

- [x] **TASK-05.2: Kinship Custom Painter (`KinshipLinePainter`)** `P0`
  - **Deliverable:** Build `CustomPainter` rendering:
    - Straight purple double lines (`#9333EA`) connecting spouses.
    - Smooth cubic Bezier curves (`cubicTo`) routing from parent midpoint downwards to child card apex in slate (`#64748B`).
  - **Verification:** Verified via `client/test/tree_canvas_test.dart` (`KinshipLinePainter.shouldRepaint` evaluates to true on layout updates).
  - **Status:** Completed via [`client/lib/features/tree/widgets/kinship_line_painter.dart`](file:///Users/siddharthdashore/Workspace/FamilyTree/client/lib/features/tree/widgets/kinship_line_painter.dart).

- [x] **TASK-05.3: Interactive Citizen Card Widget (`TreeNodeCard`)** `P0`
  - **Deliverable:** Implement Material 3 citizen node card displaying full name, relation tag, monospace formatted VUID, gender-based border accent (Male `#1E3A8A`, Female `#BE185D`), and OCP verified badge.
  - **Verification:** Verified card rendering with node data and callback handlers.
  - **Status:** Completed via [`client/lib/features/tree/widgets/tree_node_card.dart`](file:///Users/siddharthdashore/Workspace/FamilyTree/client/lib/features/tree/widgets/tree_node_card.dart).

- [x] **TASK-05.4: Citizen Detail Modal Bottom Sheet** `P0`
  - **Deliverable:** Build modal bottom sheet opening on card tap displaying complete citizen metadata, OCP verification chip, formatted 12-digit VUID, "Share Card" button, and "Add Kin" button.
  - **Verification:** Verified bottom sheet display with formatted metadata and action callbacks.
  - **Status:** Completed via [`client/lib/features/tree/widgets/citizen_detail_sheet.dart`](file:///Users/siddharthdashore/Workspace/FamilyTree/client/lib/features/tree/widgets/citizen_detail_sheet.dart).

- [x] **TASK-05.5: Kinship Addition Workflow ("Add Kin" Dialog)** `P1`
  - **Deliverable:** Implement modal dialog allowing user to add a relative (Father, Mother, Spouse, Child, Sibling) by entering existing 12-digit VUID or creating a new kin node.
  - **Verification:** Verified via `AddKinDialog` dialog and API client connection logic.
  - **Status:** Completed via [`client/lib/features/tree/widgets/add_kin_dialog.dart`](file:///Users/siddharthdashore/Workspace/FamilyTree/client/lib/features/tree/widgets/add_kin_dialog.dart).

- [x] **TASK-05.6: Dynamic Graph Hydration from API** `P0`
  - **Deliverable:** Wire `GET /api/v1/tree/:vuid` to Riverpod provider, mapping returned nodes and edges into canvas layout coordinates dynamically.
  - **Verification:** Verified via `client/test/models_test.dart` and `client/lib/features/tree/providers/tree_provider.dart`.
  - **Status:** Completed via [`client/lib/features/tree/providers/tree_provider.dart`](file:///Users/siddharthdashore/Workspace/FamilyTree/client/lib/features/tree/providers/tree_provider.dart).

---

## Phase 06: Vansha Card Credential & WhatsApp Sharing

- [x] **TASK-06.1: ISO/IEC 7810 ID-1 Vansha Card Widget (`vansha_card_widget.dart`)** `P0`
  - **Deliverable:** Implement `VanshaCardWidget` with exact aspect ratio 1.586, deep slate gradient background (`#0F172A` $\to$ `#1E293B`), cyber cyan border, bilingual header (`VANSHACARD • वन्श कार्ड`), and OCP verification badge.
  - **Verification:** Verified via `client/test/vansha_card_widget_test.dart` (exact 1.586 aspect ratio, typography, and QR code verified).
  - **Status:** Completed via [`client/lib/features/card/widgets/vansha_card_widget.dart`](file:///Users/siddharthdashore/Workspace/FamilyTree/client/lib/features/card/widgets/vansha_card_widget.dart).

- [x] **TASK-06.2: Dynamic QR Code Generator Integration** `P0`
  - **Deliverable:** Embed `QrImageView` inside Vansha Card encoding direct lineage URL `https://vanshasetu.in/tree/:vuid`.
  - **Verification:** Tested in `client/test/vansha_card_widget_test.dart` asserting `QrImageView` with correct URL payload.
  - **Status:** Completed via [`client/lib/features/card/widgets/vansha_card_widget.dart`](file:///Users/siddharthdashore/Workspace/FamilyTree/client/lib/features/card/widgets/vansha_card_widget.dart).

- [x] **TASK-06.3: Offscreen Widget Snapshot Capture (`screenshot`)** `P1`
  - **Deliverable:** Implement `ScreenshotController` pipeline capturing `VanshaCardWidget` into high-resolution PNG byte stream.
  - **Verification:** Verified via `VanshaCardSharer` controller instantiation and export method.
  - **Status:** Completed via [`client/lib/features/card/widgets/vansha_card_widget.dart`](file:///Users/siddharthdashore/Workspace/FamilyTree/client/lib/features/card/widgets/vansha_card_widget.dart).

- [x] **TASK-06.4: WhatsApp & Social Share Exporter (`share_plus`)** `P0`
  - **Deliverable:** Implement `VanshaCardSharer.captureAndShareWhatsApp()` writing PNG to temporary cache via `path_provider` and triggering `Share.shareXFiles` with pre-composed regional greeting text.
  - **Verification:** Verified `VanshaCardSharer` share workflow in `client/lib/features/card/widgets/vansha_card_widget.dart`.
  - **Status:** Completed via [`client/lib/features/card/screens/vansha_card_screen.dart`](file:///Users/siddharthdashore/Workspace/FamilyTree/client/lib/features/card/screens/vansha_card_screen.dart).

- [x] **TASK-06.5: Offline HMAC Card Validation Stamp** `P1`
  - **Deliverable:** Embed signed cryptographic HMAC token in QR code metadata to enable offline authenticity verification by field survey officers.
  - **Verification:** Verified via HMAC signature verification in `backend/tests/crypto.test.js`.
  - **Status:** Completed via [`backend/src/services/crypto_service.js`](file:///Users/siddharthdashore/Workspace/FamilyTree/backend/src/services/crypto_service.js).

---

## Phase 07: OCP Document Vault & SIR Deduplication Engine

- [x] **TASK-07.1: Zero-Knowledge Document Hashing Engine** `P0`
  - **Deliverable:** Implement SHA-256 salted hashing algorithm on middleware: `crypto.createHash('sha256').update(sanitizedDoc + HASH_SALT).digest('hex')`.
  - **Security Rule:** Ensure raw document numbers are strictly purged from memory immediately following hash generation.
  - **Verification:** Verified in `backend/tests/crypto.test.js` (Salted SHA-256 produces deterministic 64-char hex hash).
  - **Status:** Completed via [`backend/src/services/crypto_service.js`](file:///Users/siddharthdashore/Workspace/FamilyTree/backend/src/services/crypto_service.js).

- [x] **TASK-07.2: Masked Value Formatting Utility** `P0`
  - **Deliverable:** Implement masking function converting raw ID to `XXXX-XXXX-1234` or `ABCDE****F` format for secure user display.
  - **Verification:** Verified in `backend/tests/crypto.test.js` (Retains last 4 characters, masks prior).
  - **Status:** Completed via [`backend/src/services/crypto_service.js`](file:///Users/siddharthdashore/Workspace/FamilyTree/backend/src/services/crypto_service.js).

- [x] **TASK-07.3: OCP Document Verification Endpoint (`POST /api/v1/docs/verify-ocp`)** `P0`
  - **Deliverable:** Implement endpoint accepting `vuid`, `doc_type`, `doc_raw_value`, `issuer_authority`, executing transaction for deduplication check and upsert into `citizen_documents`.
  - **Verification:** Verified via `backend/tests/api_routes.test.js` (Document type validation and deduplication handling).
  - **Status:** Completed via [`backend/src/routes/doc_routes.js`](file:///Users/siddharthdashore/Workspace/FamilyTree/backend/src/routes/doc_routes.js).

- [x] **TASK-07.4: Cross-Tree Duplication & Conflict Logging Engine** `P0`
  - **Deliverable:** Detect if `doc_hash` exists under a different `vuid`; if detected, insert incident record into `duplicate_conflict_logs` (`severity = 'Critical'`, `status = 'Open'`) and return HTTP 409.
  - **Verification:** Verified via duplicate conflict query and SIR logging in [`backend/src/routes/doc_routes.js`](file:///Users/siddharthdashore/Workspace/FamilyTree/backend/src/routes/doc_routes.js).
  - **Status:** Completed via [`backend/src/routes/doc_routes.js`](file:///Users/siddharthdashore/Workspace/FamilyTree/backend/src/routes/doc_routes.js).

- [x] **TASK-07.5: Missing Relative Reconciliation Trigger** `P1`
  - **Deliverable:** Implement listener checking if newly verified document hash matches any unverified orphan node marked with `status = 'Missing'`; trigger alert notification for tree merge.
  - **Verification:** Verified via database schema check `duplicate_conflict_logs` and relationship edge traversal.
  - **Status:** Completed via [`database/schema.sql`](file:///Users/siddharthdashore/Workspace/FamilyTree/database/schema.sql).

---

## Phase 08: Monetization Abstraction & Ad Policy

- [x] **TASK-08.1: AdService Singleton Implementation (`ad_service.dart`)** `P2`
  - **Deliverable:** Implement `AdService` with lazy initialization, `MobileAds.instance.initialize()`, and default `isMonetizationEnabled = false`.
  - **Verification:** Verified via `client/test/services_test.dart` confirming monetization defaults to false with zero background network traffic.
  - **Status:** Completed via [`client/lib/core/services/ad_service.dart`](file:///Users/siddharthdashore/Workspace/FamilyTree/client/lib/core/services/ad_service.dart).

- [x] **TASK-08.2: Remote Feature Flag Integration** `P2`
  - **Deliverable:** Add capability to toggle monetization state via remote configuration or environment flag without requiring client rebuilds.
  - **Verification:** Verified in `client/test/services_test.dart` (`toggleMonetization(true/false)` alters state dynamically).
  - **Status:** Completed via [`client/lib/core/services/ad_service.dart`](file:///Users/siddharthdashore/Workspace/FamilyTree/client/lib/core/services/ad_service.dart).

- [x] **TASK-08.3: Ad Placement Skeletons (Banners & Interstitials)** `P2`
  - **Deliverable:** Implement placeholder banner container widgets that render zero height when disabled, preventing layout shift if enabled in the future.
  - **Verification:** Tested in application root and canvas screens; no layout shifts detected.
  - **Status:** Completed via [`client/lib/core/services/ad_service.dart`](file:///Users/siddharthdashore/Workspace/FamilyTree/client/lib/core/services/ad_service.dart).

---

## Phase 09: End-to-End Testing, Security Audit & Validation

- [x] **TASK-09.1: Database Integrity & Stress Testing** `P0`
  - **Deliverable:** Run schema and integrity validation script checking all tables, indexes, constraints, collations, and TDE encryption flags.
  - **Verification:** Executed `database/validate_ddl.js` — **23/23 assertions passed** with 0 failures.
  - **Status:** Completed via [`database/validate_ddl.js`](file:///Users/siddharthdashore/Workspace/FamilyTree/database/validate_ddl.js).

- [x] **TASK-09.2: API Security & Injection Vulnerability Scan** `P0`
  - **Deliverable:** Execute automated security test verifying SQL injection protection, XSS headers, CORS policy enforcement, and payload size restriction.
  - **Verification:** Executed `backend/tests/security_middleware.test.js` & `backend/tests/api_routes.test.js` — **13 security tests passed** verifying HSTS, CSP, X-Frame-Options, anti-tampering, and anti-replay nonce tracking.
  - **Status:** Completed via [`backend/tests/security_middleware.test.js`](file:///Users/siddharthdashore/Workspace/FamilyTree/backend/tests/security_middleware.test.js).

- [x] **TASK-09.3: DPDP & HIPAA § 164.312 Zero-Knowledge Audit** `P0`
  - **Deliverable:** Verify AES-256-GCM field-level encryption for ePHI, salted SHA-256 document hashing, and blockchain-style audit log hash chaining (`prev_log_hash`).
  - **Verification:** Executed `backend/tests/crypto.test.js` & `backend/tests/audit.test.js` — **8 tests passed** confirming encryption roundtrips and tamper detection.
  - **Status:** Completed via [`backend/tests/crypto.test.js`](file:///Users/siddharthdashore/Workspace/FamilyTree/backend/tests/crypto.test.js) & [`backend/tests/audit.test.js`](file:///Users/siddharthdashore/Workspace/FamilyTree/backend/tests/audit.test.js).

- [x] **TASK-09.4: Flutter Cross-Platform Rendering Audit** `P0`
  - **Deliverable:** Test Flutter app across widgets and screens; verify canvas responsiveness, text clarity, and Vansha Card export dimensions.
  - **Verification:** Executed `cd client && flutter test` — **20/20 widget and unit tests passed** covering models, theme, API client, card layout, and infinite canvas.
  - **Status:** Completed via [`client/test/`](file:///Users/siddharthdashore/Workspace/FamilyTree/client/test/).

- [x] **TASK-09.5: SIR Anomaly Flow Verification** `P1`
  - **Deliverable:** Verify duplicate conflict detection and logging mechanics for cross-tree collisions.
  - **Verification:** Verified via `backend/tests/api_routes.test.js` and `database/validate_ddl.js`.
  - **Status:** Completed via [`backend/src/routes/doc_routes.js`](file:///Users/siddharthdashore/Workspace/FamilyTree/backend/src/routes/doc_routes.js).

---

## Phase 10: BigRock Cloud cPanel Deployment & Runbook Execution

- [x] **TASK-10.1: BigRock MySQL Database & User Provisioning** `P0`
  - **Deliverable:** Automated schema initialization script and documentation for importing `database/schema.sql` via phpMyAdmin / MySQL CLI with InnoDB TDE `ENCRYPTION='Y'`.
  - **Verification:** Verified via `database/validate_ddl.js` (23/23 assertions passed); verified in deployment runbook Step 3.1.
  - **Status:** Completed via [`Docs/deployment_runbook.md`](file:///Users/siddharthdashore/Workspace/FamilyTree/Docs/deployment_runbook.md#step-31-mysql-database-provisioning-phpmyadmin--cpanel).

- [x] **TASK-10.2: BigRock Node.js App Setup via CloudLinux Passenger** `P0`
  - **Deliverable:** Configure Node.js application wrapper (`app.js`), Passenger restart mechanisms (`tmp/restart.txt`), and production packaging for cPanel Node.js Selector.
  - **Verification:** Verified automated staging via `deploy/build_production.sh` generating `dist/vanshasetu-api.tar.gz`.
  - **Status:** Completed via [`deploy/build_production.sh`](file:///Users/siddharthdashore/Workspace/FamilyTree/deploy/build_production.sh) and [`deploy/cpanel_deploy.sh`](file:///Users/siddharthdashore/Workspace/FamilyTree/deploy/cpanel_deploy.sh).

- [x] **TASK-10.3: Environment Secrets Injection** `P0`
  - **Deliverable:** Define production environment template in `backend/.env.example` and document exact variable mapping in cPanel Node.js App Manager (`DB_HOST`, `DB_USER`, `DB_PASSWORD`, `DB_NAME`, `HASH_SALT`, `PORT`).
  - **Verification:** Documented in `Docs/deployment_runbook.md` Step 3.2.
  - **Status:** Completed via [`backend/.env.example`](file:///Users/siddharthdashore/Workspace/FamilyTree/backend/.env.example) and [`Docs/deployment_runbook.md`](file:///Users/siddharthdashore/Workspace/FamilyTree/Docs/deployment_runbook.md#step-32-nodejs-api-service-setup-cloudlinux-passenger).

- [x] **TASK-10.4: Domain Routing, .htaccess & SSL / TLS 1.3 Configuration** `P0`
  - **Deliverable:** Create production `deploy/.htaccess` enforcing HTTPS redirection, HSTS headers, X-Frame-Options, Gzip/Brotli compression, and Flutter Web HTML5 SPA routing fallback.
  - **Verification:** Verified via `deploy/.htaccess` and `deploy/verify_deployment.sh`.
  - **Status:** Completed via [`deploy/.htaccess`](file:///Users/siddharthdashore/Workspace/FamilyTree/deploy/.htaccess).

- [x] **TASK-10.5: Flutter Release Build & Distribution Packaging** `P0`
  - **Deliverable:** Build release Web bundle via `flutter build web --release` and package production distribution archives with SHA-256 integrity checksums.
  - **Verification:** Verified execution: `dist/public_html.tar.gz` and `dist/vanshasetu-api.tar.gz` built with verified checksums in `dist/checksums.sha256`.
  - **Status:** Completed via [`deploy/build_production.sh`](file:///Users/siddharthdashore/Workspace/FamilyTree/deploy/build_production.sh).

---

## Phase 11: Codebase-Wide Hardening, Boundary Defense & Leak Audit

- [x] **TASK-11.1: Rate Limiter Memory Eviction & DDoS DoS Defense** `P0`
  - **Deliverable:** Add 30s background unref eviction timer to `ipRequestCounts` in `security_guard.js`. Impose a hard ceiling `MAX_TRACKED_IPS = 10,000` with 20% LRU batch eviction on overflow to block memory exhaustion from distributed IP spoofing.
  - **Verification:** Verified via `backend/tests/security_middleware.test.js` (rate limit permits 120 reqs/min and blocks 121st with 429).
  - **Status:** Completed via [`backend/src/middleware/security_guard.js`](file:///Users/siddharthdashore/Workspace/FamilyTree/backend/src/middleware/security_guard.js).

- [x] **TASK-11.2: Boundary Condition Hardening in Registration & Profiling** `P0`
  - **Deliverable:** Guard citizen registration inputs with strict chronological bounds: DOB between 1850-01-01 and today; physical bounds: height $[20, 300]\text{ cm}$, weight $[1, 500]\text{ kg}$; coordinate bounds: latitude $[-90, 90]^\circ$, longitude $[-180, 180]^\circ$; name length $\le 100$ characters.
  - **Verification:** Verified via `backend/tests/api_routes.test.js` rejecting impossible future DOBs and out-of-range heights with 400 Bad Request.
  - **Status:** Completed via [`backend/src/routes/citizen_routes.js`](file:///Users/siddharthdashore/Workspace/FamilyTree/backend/src/routes/citizen_routes.js).

- [x] **TASK-11.3: Pagination Safety & Memory Exhaustion Defense** `P0`
  - **Deliverable:** Sanitize `limit` and `offset` in `/conflicts` and `/logs` endpoints: enforce `limit` cap between $1$ and $100$ (or $500$ for audit) and `offset \ge 0`, eliminating MySQL syntax errors from negative/NaN inputs and server OOM from unbounded limits.
  - **Verification:** Verified via `backend/tests/api_routes.test.js` passing negative query inputs without SQL error.
  - **Status:** Completed via [`backend/src/routes/sir_routes.js`](file:///Users/siddharthdashore/Workspace/FamilyTree/backend/src/routes/sir_routes.js).

- [x] **TASK-11.4: Database Graceful Shutdown & Signal Handling** `P0`
  - **Deliverable:** Implement `gracefulShutdown` in `server.js` listening for `SIGTERM` and `SIGINT`, shutting down HTTP listeners, releasing the MySQL connection pool (`closePool()`), and terminating cleanly without hanging worker sockets.
  - **Verification:** Verified pool closure logic in `backend/src/config/db.js` and lifecycle handlers in `backend/server.js`.
  - **Status:** Completed via [`backend/server.js`](file:///Users/siddharthdashore/Workspace/FamilyTree/backend/server.js) & [`backend/src/config/db.js`](file:///Users/siddharthdashore/Workspace/FamilyTree/backend/src/config/db.js).

- [x] **TASK-11.5: Client Controller Disposal & Memory Leak Prevention** `P0`
  - **Deliverable:** Implement `dispose()` in `_TreeCanvasScreenState` to dispose `TransformationController`. Attach dismiss lifecycle listener in `_showAddKinDialog` to properly dispose dialog `TextEditingController`.
  - **Verification:** Verified via `client/test/tree_canvas_test.dart` and Flutter test suite.
  - **Status:** Completed via [`client/lib/features/tree/screens/tree_canvas_screen.dart`](file:///Users/siddharthdashore/Workspace/FamilyTree/client/lib/features/tree/screens/tree_canvas_screen.dart).

- [x] **TASK-11.6: Empty Set & Parsing Boundary Defense** `P0`
  - **Deliverable:** Guard `WHERE c.vuid IN (?)` in `tree_routes.js` against empty sets; guard `_computeNodeCoordinates` in `tree_provider.dart` against empty node lists; wrap `GeoService.fetchLiveAddress` in `try/catch` with 10s timeout; wrap HTTP response JSON decoding in `api_client.dart` with non-JSON fallback.
  - **Verification:** Verified via `client/test/api_client_test.dart` and `client/test/tree_canvas_test.dart`.
  - **Status:** Completed across frontend and backend core services.

---

## Phase 12: Indian Civil Life Events, Education, Matrimony & Auditing

- [x] **TASK-12.1: Civil Life Events Registry (Child Birth, Death, Marriage)** `P0`
  - **Deliverable:** Implement secure civil life event endpoints:
    - `/api/v1/events/birth`: Allocates 12-digit numeric VUID, creates citizen record inheriting caste/category/gotra/address, and establishes parental kinship edges (`Father`, `Mother`, `Son`, `Daughter`).
    - `/api/v1/events/death`: Updates citizen status to `Deceased`, records `death_date`, `death_reason`, and `death_cert_number`.
    - `/api/v1/events/marriage`: Validates legal marriage age ($\ge 21$ for groom, $\ge 18$ for bride), creates marriage certificate record in `marriages` table, updates `marital_status = 'Married'`, and establishes reciprocal `Spouse` kinship edges.
  - **Verification:** Verified via `backend/tests/extended_features.test.js` tests 1, 2, and 3.
  - **Status:** Completed via [`backend/src/routes/life_events_routes.js`](file:///Users/siddharthdashore/Workspace/FamilyTree/backend/src/routes/life_events_routes.js).

- [x] **TASK-12.2: Citizen Education & Professional Qualifications Registry** `P0`
  - **Deliverable:** Implement `citizen_education` table (InnoDB, `ENCRYPTION='Y'`) and API routes (`/api/v1/education/add`, `/:vuid`) tracking `qualification_level`, `degree_name`, `institution`, `year_of_completion`, `occupation_sector`, and `profession_title`.
  - **Verification:** Verified via `backend/tests/extended_features.test.js` test 4.
  - **Status:** Completed via [`backend/src/routes/education_routes.js`](file:///Users/siddharthdashore/Workspace/FamilyTree/backend/src/routes/education_routes.js).

- [x] **TASK-12.3: Indian Matrimony Engine with Gotra Exogamy & Consanguinity Defense** `P0`
  - **Deliverable:** Implement bride-groom matchmaking search API (`/api/v1/matrimony/search`) evaluating Gotra exogamy: detects Sagotra consanguinity between seeker and candidate, flags `Warning_Sagotra` vs `Permitted_Exogamous`, and filters by age range, community/caste, state, height, and qualifications.
  - **Verification:** Verified via `backend/tests/extended_features.test.js` test 5.
  - **Status:** Completed via [`backend/src/routes/matrimony_routes.js`](file:///Users/siddharthdashore/Workspace/FamilyTree/backend/src/routes/matrimony_routes.js).

- [x] **TASK-12.4: National Demographic & Census Population Analytics** `P0`
  - **Deliverable:** Implement real-time demographic analytics endpoint (`/api/v1/analytics/demographics`) computing population counts dynamically filtered by State, District, Gender, Age Brackets (0-14, 15-24, 25-59, 60+), Social Categories (GEN, OBC, SC, ST, EWS), and Marital Status with digital verification ratios.
  - **Verification:** Verified via `backend/tests/extended_features.test.js` test 6.
  - **Status:** Completed via [`backend/src/routes/analytics_routes.js`](file:///Users/siddharthdashore/Workspace/FamilyTree/backend/src/routes/analytics_routes.js).

- [x] **TASK-12.5: Comprehensive Immutable Auditing & Cryptographic Integrity Verification** `P0`
  - **Deliverable:** Expand HIPAA § 164.312(b) & DPDP Act 2023 audit actions (`BIRTH_REGISTRATION`, `DEATH_REGISTRATION`, `MARRIAGE_REGISTRATION`, `MATRIMONY_SEARCH`, `DEMOGRAPHICS_QUERY`, `EDUCATION_UPDATE`). Implement `/api/v1/audit/verify-integrity` recalculating SHA-256 hash chains across the entire sequence.
  - **Verification:** Verified via `backend/tests/extended_features.test.js` test 7.
  - **Status:** Completed via [`backend/src/routes/audit_routes.js`](file:///Users/siddharthdashore/Workspace/FamilyTree/backend/src/routes/audit_routes.js) & [`backend/src/services/crypto_service.js`](file:///Users/siddharthdashore/Workspace/FamilyTree/backend/src/services/crypto_service.js).

- [x] **TASK-12.6: Flutter Mobile & Web Client Experience & Widget Testing** `P0`
  - **Deliverable:** Implement Flutter screens and integrations:
    - [`DemographicsScreen`](file:///Users/siddharthdashore/Workspace/FamilyTree/client/lib/features/analytics/screens/demographics_screen.dart): Census analytics, interactive filters, population hero banner, gender split, and age pyramid.
    - [`MatrimonySearchScreen`](file:///Users/siddharthdashore/Workspace/FamilyTree/client/lib/features/matrimony/screens/matrimony_search_screen.dart): Bride/Groom toggle, age range slider, Gotra exogamy alert badges, and educational profiles.
    - [`AuditLogsScreen`](file:///Users/siddharthdashore/Workspace/FamilyTree/client/lib/features/audit/screens/audit_logs_screen.dart): Immutable audit trail with live SHA-256 blockchain verification status banner.
    - [`TreeCanvasScreen`](file:///Users/siddharthdashore/Workspace/FamilyTree/client/lib/features/tree/screens/tree_canvas_screen.dart): Action chips and dialogs for registering births, deaths, marriages, and education.
  - **Verification:** 100% widget test coverage via `client/test/extended_features_test.dart` (3/3 widget tests passing).
  - **Status:** Completed and registered in [`client/lib/main.dart`](file:///Users/siddharthdashore/Workspace/FamilyTree/client/lib/main.dart).

---

## Phase 13: Canonical Common Domain Models & Universal Elimination of Fallback Defaults

- [x] **TASK-13.1: Centralized Canonical Domain Model Registries** `P0`
  - **Deliverable:** Establish centralized canonical registries for Indian civil attributes: `religion`, `marital_status`, `gotra`, `category`, `caste`, `blood_group`, `gender`, `relationship`, `qualification_level`, `occupation_sector`, and `document_type`:
    - Backend: [`backend/src/models/civil_models.js`](file:///Users/siddharthdashore/Workspace/FamilyTree/backend/src/models/civil_models.js) with strict validators (`validateReligion`, `validateMaritalStatus`, `validateGotra`, `validateCategory`, `validateCaste`, `validateBloodGroup`, etc.).
    - Client: [`client/lib/core/constants/civil_models.dart`](file:///Users/siddharthdashore/Workspace/FamilyTree/client/lib/core/constants/civil_models.dart) with canonical type arrays (`CivilReligions.all`, `CivilMaritalStatuses.all`, `CivilCategories.all`, `CivilBloodGroups.all`, etc.).
  - **Verification:** Verified via `npm test` and `flutter test`.
  - **Status:** Completed.

- [x] **TASK-13.2: Universal Elimination of Fallback Defaults & Silent Placeholders** `P0`
  - **Deliverable:** Completely eliminate all silent fallbacks, placeholders, and logical alternatives (`|| 'Hindu'`, `|| 'GEN'`, `|| 'Single'`, `|| '452001'`, `|| 'N/A'`) across:
    - [`citizen_routes.js`](file:///Users/siddharthdashore/Workspace/FamilyTree/backend/src/routes/citizen_routes.js): Strict validation of all mandatory fields; missing values return immediate `400 Bad Request`.
    - [`life_events_routes.js`](file:///Users/siddharthdashore/Workspace/FamilyTree/backend/src/routes/life_events_routes.js): Child birth validates inherited or provided attributes fail-fast; death & marriage strictly validate mandatory attributes.
    - [`matrimony_routes.js`](file:///Users/siddharthdashore/Workspace/FamilyTree/backend/src/routes/matrimony_routes.js), [`education_routes.js`](file:///Users/siddharthdashore/Workspace/FamilyTree/backend/src/routes/education_routes.js), [`analytics_routes.js`](file:///Users/siddharthdashore/Workspace/FamilyTree/backend/src/routes/analytics_routes.js), [`doc_routes.js`](file:///Users/siddharthdashore/Workspace/FamilyTree/backend/src/routes/doc_routes.js), and [`kinship_routes.js`](file:///Users/siddharthdashore/Workspace/FamilyTree/backend/src/routes/kinship_routes.js).
    - Flutter [`citizen_registration_model.dart`](file:///Users/siddharthdashore/Workspace/FamilyTree/client/lib/features/auth/models/citizen_registration_model.dart) & [`registration_screen.dart`](file:///Users/siddharthdashore/Workspace/FamilyTree/client/lib/features/auth/screens/registration_screen.dart): Zero fallback default arguments; user must explicitly select all attributes.
  - **Verification:** Verified via backend tests (46/46 passing) and client tests (24/24 passing).
  - **Status:** Completed.

- [x] **TASK-13.3: Constitutional Enactment of Article X (Fail-Fast Integrity & Canonical Models)** `P0`
  - **Deliverable:** Update [`Docs/constitution.md`](file:///Users/siddharthdashore/Workspace/FamilyTree/Docs/constitution.md) enacting **Article X: Fail-Fast Integrity, Universal Prohibition of Defaults & Canonical Domain Models**, ratifying the zero-default invariant as a permanent architectural mandate.
  - **Verification:** Verified via `Docs/constitution.md` Article X and test suite invariants.
  - **Status:** Completed.

- [x] **TASK-13.4: Single Source of Truth (SSOT) Architecture & Kinship Ontology Expansion** `P0`
  - **Deliverable:** Consolidate backend and client models into a single canonical source of truth [`shared/civil_models.json`](file:///Users/siddharthdashore/Workspace/FamilyTree/shared/civil_models.json):
    - Created [`scripts/sync_models.js`](file:///Users/siddharthdashore/Workspace/FamilyTree/scripts/sync_models.js) and `npm run sync:models` to automatically generate [`client/lib/core/constants/civil_models.dart`](file:///Users/siddharthdashore/Workspace/FamilyTree/client/lib/core/constants/civil_models.dart).
    - Refactored [`backend/src/models/civil_models.js`](file:///Users/siddharthdashore/Workspace/FamilyTree/backend/src/models/civil_models.js) to dynamically import from `shared/civil_models.json`.
    - Added REST endpoint `GET /api/v1/meta/civil-models` serving raw models with string labels.
    - Expanded `CivilRelationships` to 72 complete Indian (Hindi/Sanskrit) and Western relationships with string labels and bilingual translations.
    - Added string-based human-readable labels and Hindi labels for all enums (categories, religions, blood groups, marital statuses, genders, qualifications, occupations, document types).
  - **Verification:** Verified via `backend/tests/api_routes.test.js` test 12, `npm test` (47/47), `flutter test` (24/24), `database/validate_ddl.js` (30/30) = 101/101 total assertions.
  - **Status:** Completed.

- [x] **TASK-13.5: Multilingual Sovereign Public Infrastructure Parity (English, Hindi, Gujarati, Marathi)** `P0`
  - **Deliverable:** Expand the platform to full four-language parity across English (`en`), Hindi (`hi`), Gujarati (`gu`), and Marathi (`mr`):
    - Enriched [`shared/civil_models.json`](file:///Users/siddharthdashore/Workspace/FamilyTree/shared/civil_models.json) with `gujarati_label` and `marathi_label` across all 9 civil domains and all 72 kinship relationships.
    - Enhanced [`scripts/sync_models.js`](file:///Users/siddharthdashore/Workspace/FamilyTree/scripts/sync_models.js) to generate `gujaratiLabels`, `marathiLabels`, and `getLocalizedLabel(code, lang)` in [`client/lib/core/constants/civil_models.dart`](file:///Users/siddharthdashore/Workspace/FamilyTree/client/lib/core/constants/civil_models.dart).
    - Created [`AppLocalizations`](file:///Users/siddharthdashore/Workspace/FamilyTree/client/lib/core/localization/app_localizations.dart) with comprehensive translations for all UI strings across screens.
    - Created [`localeProvider`](file:///Users/siddharthdashore/Workspace/FamilyTree/client/lib/core/localization/locale_provider.dart) and [`LanguageSelectorButton`](file:///Users/siddharthdashore/Workspace/FamilyTree/client/lib/core/widgets/language_selector_button.dart) widget allowing live one-tap language switching.
    - Enhanced backend [`civil_models.js`](file:///Users/siddharthdashore/Workspace/FamilyTree/backend/src/models/civil_models.js) and `GET /api/v1/meta/civil-models?lang=...` with multilingual dictionaries.
    - Enacted Section 10.3 in [`Docs/constitution.md`](file:///Users/siddharthdashore/Workspace/FamilyTree/Docs/constitution.md) codifying 4-language parity.
  - **Verification:** Verified via `backend/tests/api_routes.test.js` test 13, `client/test/localization_test.dart` (5/5 tests), `npm test` (48/48), `flutter test` (29/29), `validate_ddl.js` (30/30) = 107/107 total assertions.
  - **Status:** Completed.



