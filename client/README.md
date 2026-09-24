# VanshaSetu (वन्शसेतु) — Flutter Client Application

> **A Minimalist, Material 3 Digital Public Infrastructure (DPI) Kinship Client for Android, iOS, macOS, and Web.**

[![Flutter](https://img.shields.io/badge/Flutter-3.20%2B-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.2%2B-0175C2?logo=dart)](https://dart.dev)
[![Architecture](https://img.shields.io/badge/State-Riverpod%202.5-blueviolet)](https://riverpod.dev)
[![Tests](https://img.shields.io/badge/Flutter%20Tests-24%2F24%20Passed-brightgreen)](file:///Users/siddharthdashore/Workspace/FamilyTree/client/test/)

---

## 1. Overview & Architectural Principles

The **VanshaSetu Client** provides a high-performance, cross-platform interface for multi-generational lineage exploration, Indian civil registry management, ISO/IEC 7810 ID-1 Vansha Card generation, and demographic census analysis.

### Core Architectural Pillars
1. **Material 3 Design System**: Clean cyber slate theme with deep navy tones (`#0F172A`), electric cyan accents (`#38BDF8`), and gender-coded kinship palettes (Male `#1E3A8A`, Female `#BE185D`, Spouse `#9333EA`).
2. **State Management with Riverpod**: Reactive providers (`authProvider`, `treeProvider`, `demographicsProvider`, `matrimonyProvider`, `auditProvider`) ensuring decoupled business logic, efficient rebuilds, and testability.
3. **Infinite Kinship Canvas**: Custom virtualized 2D canvas leveraging `InteractiveViewer` (scale 0.2x to 2.5x) and a custom cubic Bezier rendering pipeline (`KinshipLinePainter`).
4. **Canonical Civil Models & Zero-Default Policy**: All dropdowns and domain fields are strictly validated against [`client/lib/core/constants/civil_models.dart`](file:///Users/siddharthdashore/Workspace/FamilyTree/client/lib/core/constants/civil_models.dart). Form fields require explicit user selection without silent fallback defaults, enforcing [Constitution Article X](file:///Users/siddharthdashore/Workspace/FamilyTree/Docs/constitution.md#article-x-fail-fast-integrity-universal-prohibition-of-defaults--canonical-domain-models).

---

## 2. Feature & Screen Directory

### 2.1 Interactive Lineage Canvas ([`tree_canvas_screen.dart`](file:///Users/siddharthdashore/Workspace/FamilyTree/client/lib/features/tree/screens/tree_canvas_screen.dart))
- Infinite 2D pan/zoom canvas displaying multi-generational kinship graphs.
- Smooth cubic Bezier curves (`cubicTo`) routing from parent nodes to children; purple horizontal double lines joining spouses.
- Interactive citizen nodes (`TreeNodeCard`) displaying monospace 12-digit VUID, OCP verification badges, and relationship tags.
- One-tap action chips for civil lifecycle events:
  - **Add Kin Dialog** ([`add_kin_dialog.dart`](file:///Users/siddharthdashore/Workspace/FamilyTree/client/lib/features/tree/widgets/add_kin_dialog.dart))
  - **Child Birth Registration Dialog**
  - **Civil Marriage Registration Dialog**
  - **Civil Death Registration Dialog**
  - **Education Credential Dialog**

### 2.2 Vansha Card Credential & WhatsApp Sharing ([`vansha_card_widget.dart`](file:///Users/siddharthdashore/Workspace/FamilyTree/client/lib/features/card/widgets/vansha_card_widget.dart))
- Proportional to **ISO/IEC 7810 ID-1 standard aspect ratio (1.586)**.
- Encodes dynamic HMAC-signed QR code linking directly to the citizen's family tree node.
- High-resolution off-screen PNG capture via `ScreenshotController` and instant native WhatsApp sharing via `share_plus`.

### 2.3 Indian Matrimony Engine & Gotra Exogamy ([`matrimony_search_screen.dart`](file:///Users/siddharthdashore/Workspace/FamilyTree/client/lib/features/matrimony/screens/matrimony_search_screen.dart))
- Bride / Groom candidate search with Gotra consanguinity detection.
- Real-time display of **Sagotra Alert Badges** (`⚠️ Sagotra Alert (सगोत्र)`) versus certified exogamous matches (`✅ Exogamous Match (विवाह योग्य)`).
- Multi-criteria filtering by age range, community/caste, state/district, height, and minimum qualification level.

### 2.4 Demographic & Census Analytics Dashboard ([`demographics_screen.dart`](file:///Users/siddharthdashore/Workspace/FamilyTree/client/lib/features/analytics/screens/demographics_screen.dart))
- Dynamic population count banner with real-time state and district filters.
- Five-tier age distribution pyramid (Children 0-14, Youth 15-24, Working Age 25-59, Seniors 60+).
- Gender split statistics and digital adoption rates (% Claimed and OCP Verified).

### 2.5 Immutable Audit Logs Inspector ([`audit_logs_screen.dart`](file:///Users/siddharthdashore/Workspace/FamilyTree/client/lib/features/audit/screens/audit_logs_screen.dart))
- Real-time HIPAA § 164.312(b) and DPDP Act 2023 audit ledger.
- Displays chronological SHA-256 blockchain hash link verification with one-tap integrity re-check against `/api/v1/audit/verify-integrity`.

### 2.6 Citizen Registration with Live GPS Autofill ([`registration_screen.dart`](file:///Users/siddharthdashore/Workspace/FamilyTree/client/lib/features/auth/screens/registration_screen.dart))
- One-tap live GPS geolocation via `geolocator` and `geocoding` populating PIN code, district, state, and coordinates.
- Dropdown selectors populated directly from canonical model registries (Gender, Category, Gotra, Religion, Marital Status, Blood Group).

---

## 3. Canonical Domain Model Constants

Located in [`client/lib/core/constants/civil_models.dart`](file:///Users/siddharthdashore/Workspace/FamilyTree/client/lib/core/constants/civil_models.dart):

```dart
// Canonical Indian Civil Constants
CivilReligions.all       // Hindu, Muslim, Christian, Sikh, Buddhist, Jain, Parsi, Jewish, Other...
CivilMaritalStatuses.all // Single, Married, Divorced, Widowed, Separated
CivilCategories.all      // GEN, OBC, SC, ST, EWS
CivilBloodGroups.all     // A+, A-, B+, B-, AB+, AB-, O+, O-
CivilGenders.all         // Male, Female, Other
CivilRelationships.all   // Father, Mother, Spouse, Son, Daughter, Sibling, Guardian
CivilQualifications.all  // Primary, Secondary, Higher Secondary, Diploma, Undergraduate...
CivilOccupations.all     // Government_CivilServices, Defense_Police, Private_IT_Corporate...
CivilDocumentTypes.all   // Aadhaar, PAN, VoterID, Passport, DrivingLicense, RationCard
```

---

## 4. Running the Client Locally

```bash
# Launch on Google Chrome (Web SPA)
flutter run -d chrome

# Launch on connected Android device or Emulator
flutter run -d android

# Launch on iOS Simulator
flutter run -d ios

# Launch as macOS Desktop application
flutter run -d macos
```

---

## 5. Automated Testing Suite

The Flutter client contains comprehensive unit, model, and widget tests:

```bash
flutter test
```

### Verified Test Suite (24/24 Tests Passing):
- **`extended_features_test.dart`**: Demographics analytics dashboard, Matrimony search with Gotra exogamy alerts, Audit logs with blockchain verification.
- **`models_test.dart`**: Citizen registration serialization, tree node/edge parsing, OCP flags.
- **`registration_screen_test.dart`**: Complete field rendering, mandatory field error assertions.
- **`tree_canvas_test.dart`**: Canvas container, app bar actions, `KinshipLinePainter.shouldRepaint` evaluation.
- **`vansha_card_widget_test.dart`**: ISO/IEC 7810 ID-1 ratio (1.586), QR code generation, typography.
- **`theme_test.dart`**: Material 3 dark/light palettes, hexadecimal color definitions.
- **`api_client_test.dart`**: HMAC request headers, non-JSON response fallback handling.
- **`services_test.dart`**: Clean DPI monetization policies, geographic autofill result structures.
- **`widget_test.dart`**: Full app bootstrap smoke test.
