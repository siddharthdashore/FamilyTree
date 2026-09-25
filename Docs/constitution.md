# VanshaSetu (वन्शसेतु) — Project Constitution & Governance Bylaws
## Sovereign Architectural Invariants, Zero-Trust Mandates & Non-Negotiable Engineering Rules

> **Status:** ACTIVE & BINDING  
> **Classification:** Sovereign Digital Public Infrastructure (DPI) Constitution  
> **Effective Date:** 2026-09-24  
> **Compliance Alignment:** Digital Personal Data Protection Act (DPDP) 2023 • HIPAA Title II § 164.312 • ABDM (Ayushman Bharat Digital Mission) • DISHA • ISO/IEC 7810 ID-1  
> **Scope:** Entire Repository (Database, Backend Middleware, Frontend Client, DevOps, Documentation)

---

## Preamble

We, the architects, engineers, and maintainers of **VanshaSetu (वन्शसेतु)**, establishing a sovereign Digital Public Infrastructure (DPI) for kinship governance, demographic lineage verification, and civil registry deduplication, enact this **Constitution** as the supreme set of operational and technical laws governing this codebase.

Every pull request, architectural design, database migration, and cryptographic workflow MUST conform unconditionally to the articles set forth herein. Any modification that violates these constitutional tenets is considered an immediate security breach and shall be rejected by continuous integration automation.

---

## Article I: Sovereign Identity & The 12-Digit VUID Standard

### Section 1.1: Numeric 12-Digit Invariant
1. The Vansha Unique Identifier (**VUID**) is the exclusive, canonical primary identifier of any citizen entity across the platform.
2. The VUID MUST strictly consist of exactly **twelve (12) decimal digits** bounded within the inclusive numerical interval:
   $$\text{VUID} \in [100000000000, 999999999999]$$
3. Alphanumeric IDs, UUIDs, UUIDv4 tokens, or auto-incrementing sequential integers are strictly prohibited from serving as citizen identity references.
4. Database tables MUST enforce this via declarative CHECK constraints:
   ```sql
   CONSTRAINT chk_vuid_12_digits CHECK (vuid REGEXP '^[0-9]{12}$')
   ```

### Section 1.2: Cryptographic Generation
1. VUID generation MUST use a cryptographically secure pseudorandom number generator (CSPRNG via Node.js `crypto.randomInt` or native OS entropy).
2. Math.random() or non-cryptographic RNGs are strictly prohibited.
3. Every generation routine MUST implement collision detection with exponential backoff retry capped at five (5) iterations.

### Section 1.3: User Presentation Formatting
1. When displayed to users on screens, cards, or PDFs, the VUID MUST be formatted into three groups of four digits separated by single spaces:
   $$\text{XXXX XXXX XXXX}$$
2. Monospaced typography MUST be utilized for rendered VUIDs to guarantee optical scannability and accessibility.

---

## Article II: Zero-Knowledge Document Vault & Data Minimization

### Section 2.1: Ban on Plaintext Government Credential Storage
1. Raw government identification numbers (Aadhaar, PAN, Voter ID / EPIC, Passport, Driving License, Ration Card) MUST **NEVER** be persisted in plaintext to disk, database tables, cache layers, or persistent message queues.
2. Raw government identification numbers MUST **NEVER** be written to application logs, audit logs, debug outputs, or error traces.

### Section 2.2: Deterministic Salted SHA-256 Hashing
1. For cross-tree deduplication, incoming document credentials MUST be sanitized (strip whitespace and uppercase alphanumeric characters) and transformed into a 64-character hexadecimal SHA-256 hash using a server-side cryptographic secret salt (`HASH_SALT`):
   $$\text{doc\_hash} = \text{SHA-256}(\text{SanitizedDoc} \parallel \text{HASH\_SALT})$$
2. The raw document number MUST be cleared from memory buffers immediately following hash generation.

### Section 2.3: Visual Masking Invariant
1. Only the non-sensitive portion of a document may be stored or displayed to users:
   - For 12-digit Aadhaar / Numeric IDs: Mask all except the trailing four digits (`XXXXXXXX9012`).
   - For 10-character PAN: Mask middle six characters (`ABCDE****F`).
2. Raw unmasked numbers must never appear in API responses or UI view states.

---

## Article III: Healthcare & ePHI Protection Mandates (HIPAA § 164.312 & ABDM)

### Section 3.1: Field-Level AES-256-GCM Encryption
1. All Electronic Protected Health Information (**ePHI**) and sensitive somatic attributes—including height, weight, medical conditions, and detailed street coordinates—MUST be encrypted at the application layer prior to database insertion.
2. Field-level encryption MUST use **AES-256-GCM** (Galois/Counter Mode).
3. Every encrypted record MUST generate a unique, non-repeating 96-bit (12-byte) Initialization Vector (IV) and a 128-bit (16-byte) Authentication Tag (`auth_tag`).
4. Any decryption operation with a mismatched or tampered authentication tag MUST fail immediately and trigger a security incident.

### Section 3.2: Transparent Data Encryption (TDE)
1. Every table defined in the MySQL database MUST explicitly enforce InnoDB Transparent Data Encryption at rest:
   ```sql
   ENCRYPTION = 'Y'
   ```
2. Unencrypted tables are unconstitutional and rejected by automated DDL validators.

### Section 3.3: Immutable Cryptographic Audit Trails (HIPAA § 164.312(b))
1. Every read of sensitive ePHI, citizen registration, kinship mutation, or document verification MUST be recorded in the `audit_logs` table.
2. Every audit log entry MUST be cryptographically linked to the preceding entry using SHA-256 hash chaining:
   $$\text{log\_hash}_i = \text{SHA-256}(\text{log\_hash}_{i-1} \parallel \text{actor\_vuid} \parallel \text{action} \parallel \text{resource} \parallel \text{timestamp})$$
3. Modification or deletion of audit log entries is strictly forbidden; tables must be configured with append-only privileges for the application user.

---

## Article IV: Zero-Trust API & Network Security Laws

### Section 4.1: End-to-End Encryption (E2EE) Payload Transport
1. Sensitive API interactions (registration, ePHI retrieval, document submission) MUST support JWE / AES-256-GCM encrypted payload envelopes.
2. Payloads must be encrypted on the client device before network transmission and decrypted only within the protected server memory context.

### Section 4.2: Anti-Tampering & Anti-Replay Request Signing
1. Every mutating API request (`POST`, `PUT`, `DELETE`) MUST provide the following mandatory cryptographic headers:
   - `X-Vansha-Signature`: $\text{HMAC-SHA256}(\text{Timestamp} \parallel \text{Nonce} \parallel \text{Body}, \text{SharedSecret})$
   - `X-Vansha-Timestamp`: Unix epoch milliseconds.
   - `X-Vansha-Nonce`: Cryptographically random UUID/token.
2. The middleware MUST reject any request where:
   - The timestamp differs from server time by more than sixty (60) seconds ($|\Delta t| > 60\text{s}$).
   - The nonce has already been processed within the freshness window (replay attack).
   - The computed HMAC signature does not match the received signature in constant time.

### Section 4.3: Network Perimeter & Port Isolation
1. The MySQL database port (`3306`) MUST be bound exclusively to `127.0.0.1` (localhost) or Unix domain sockets.
2. Port 3306 MUST never be routed to public interfaces or exposed through Docker container port forwardings.
3. TLS 1.3 encryption is mandatory for all inbound HTTPS connections.

### Section 4.4: Defensive HTTP Headers
1. All HTTP responses MUST include strict security headers via Helmet or reverse proxy:
   - `Strict-Transport-Security: max-age=31536000; includeSubDomains; preload`
   - `Content-Security-Policy: default-src 'self' ...`
   - `X-Frame-Options: DENY`
   - `X-Content-Type-Options: nosniff`
   - `X-Permitted-Cross-Domain-Policies: none`

### Section 4.5: Sliding-Window Rate Limiting & Memory Bounded DoS Defense
1. All public API endpoints MUST enforce sliding-window rate limiting (maximum 120 requests/minute per client IP).
2. Rate-limiter tracking structures (`ipRequestCounts`) and replay-cache maps (`seenNonces`) MUST be bounded by active eviction timers running via non-blocking `.unref()` background intervals.
3. In-memory tracking structures MUST enforce a hard size ceiling (`MAX_TRACKED_IPS = 10,000`, `MAX_SEEN_NONCES = 50,000`). Upon reaching capacity, an automated batch LRU purge (evicting the oldest 20% of entries) MUST execute immediately to prevent memory exhaustion and Denial-of-Service (DoS) crashes from distributed IP spoofing.
4. Client IP extraction MUST sanitize `X-Forwarded-For` proxy chains by parsing only the primary client IP and normalizing IPv4-mapped IPv6 formats.

### Section 4.6: Resource Lifecycle & Graceful Server Shutdown
1. The server runtime MUST listen for OS termination signals (`SIGTERM`, `SIGINT`).
2. Upon signal reception, the runtime MUST halt inbound connection acceptance, drain and close active HTTP sockets, release the MySQL database connection pool (`closePool()`), and terminate cleanly.
3. An unref forced shutdown timer ($\le 5\text{ seconds}$) MUST guard against socket hanging during cloud redeployments.

---

## Article V: Kinship Graph Invariants, Boundary Defenses & Fraud Prevention (SIR)

### Section 5.1: Graph Topology Rules
1. A citizen cannot be connected to themselves in the kinship graph ($\text{source\_vuid} \neq \text{target\_vuid}$).
2. Every kinship edge MUST declare a recognized relationship ontology:
   $$\text{Type} \in \{\text{'Father'}, \text{'Mother'}, \text{'Spouse'}, \text{'Son'}, \text{'Daughter'}, \text{'Sibling'}, \text{'Guardian'}\}$$
3. Biological lineage edges must strictly honor temporal causality ($\text{DOB}_{\text{Parent}} < \text{DOB}_{\text{Child}}$).

### Section 5.2: Social Investigation Report (SIR) Duplication Policy
1. When a document verification request produces a `doc_hash` that already exists under a distinct `vuid`:
   - The middleware MUST NOT overwrite or mutate the existing record.
   - The middleware MUST immediately return an **HTTP 409 Conflict** error.
   - The middleware MUST record an immutable fraud event in `duplicate_conflict_logs` with `severity = 'Critical'` and `status = 'Open'`.
   - The existing tree and the new claimant node MUST be flagged for Social Investigation review.

### Section 5.3: Strict Chronological, Physical & Geographic Bounds
1. All citizen input attributes MUST be strictly validated against invariant physical and chronological boundaries:
   - **Date of Birth (DOB):** Must be a valid date strictly bounded by $\text{1850-01-01} \le \text{DOB} \le \text{Today}$. Future birth dates and antiquity dates preceding 1850 are strictly rejected.
   - **Somatic Attributes:** If supplied, height must satisfy $20\text{ cm} \le \text{height} \le 300\text{ cm}$, and weight must satisfy $1\text{ kg} \le \text{weight} \le 500\text{ kg}$.
   - **Geographic Coordinates:** If supplied, latitude must satisfy $-90^\circ \le \text{lat} \le 90^\circ$, and longitude must satisfy $-180^\circ \le \text{lon} \le 180^\circ$.
   - **String Field Caps:** First and last names MUST be capped at $\le 100$ characters. Address lines MUST be capped at $\le 255$ characters. Unbounded string ingestion is unconstitutional.

### Section 5.4: Defensive Pagination & Collection Safeguards
1. All listing and log-retrieval endpoints (`/conflicts`, `/logs`) MUST enforce strict pagination parameter sanitization:
   $$\text{safeLimit} = \min(\max(\text{parseInt}(\text{limit}) \lor 50, 1), 100)$$
   $$\text{safeOffset} = \max(\text{parseInt}(\text{offset}) \lor 0, 0)$$
   Negative offsets, `NaN` parameters, or unbounded limits causing memory exhaustion are strictly prohibited.
2. Dynamic SQL queries utilizing `IN (?)` clauses MUST verify that collection size is greater than zero prior to dispatch. If a collection is empty, the application MUST return an empty result set immediately, preventing SQL syntax exceptions (`IN ()`).

---

## Article VI: Physical & Digital Credential Standards & Client Engineering

### Section 6.1: Physical Card Geometry (ISO/IEC 7810 ID-1)
1. The digital and physical VanshaCard credential MUST adhere precisely to the **ISO/IEC 7810 ID-1 standard aspect ratio**:
   $$\text{Aspect Ratio} = \frac{85.60\text{ mm}}{53.98\text{ mm}} \approx 1.58577... \implies 1.586$$
2. UI widgets and rendering pipelines MUST maintain this exact ratio across all screen resolutions and densities without stretching, clipping, or letterboxing.

### Section 6.2: Bilingual Typography & Accessibility
1. Official headers MUST feature bilingual representation in English and Hindi (Devanagari):
   $$\text{VANSHACARD • वन्श कार्ड}$$
2. Color contrast ratios between text and background gradients MUST exceed WCAG AAA standards (minimum 7:1 for normal text).

### Section 6.3: High-Resolution Offline Export
1. Card image capture pipelines (via `ScreenshotController`) MUST render at double-density ($2.0\times$ pixel ratio) or higher to guarantee crisp raster reproduction on physical PVC card printers.
2. The embedded QR code MUST resolve directly to the sovereign lineage URI:
   $$\text{https://vanshasetu.in/tree/:vuid}$$

### Section 6.4: Client Resource Lifecycle & Controller Disposal Mandate
1. In Flutter and all UI components, every stateful controller (`TextEditingController`, `TransformationController`, `ScrollController`, animation listeners) MUST be explicitly disposed during widget disposal (`dispose()`) or dialog termination (`.then((_) => controller.dispose())`). Leaking stateful controllers or listeners across navigation is unconstitutional.

### Section 6.5: Canvas Rendering, Leaf Node Architecture & Chromatic Invariants
1. Custom painters (`CustomPainter`) MUST implement semantic equality checks in `shouldRepaint` (`oldDelegate.nodes != nodes || oldDelegate.edges != edges`) rather than unconditional `true`, preventing GPU and CPU thrashing on idle frames.
2. **Genealogical Leaf Node Hierarchy:**
   - Every node on the kinship lineage canvas MUST be structured with a distinct two-tier visual hierarchy:
     1. **Top Tier (Round Circular Leaf):** A circular avatar container with an image portrait and a prominent 3.5px chromatic border.
     2. **Bottom Tier (Rectangular Details Card):** Positioned directly beneath the circular avatar, containing citizen full name, verified credentials, demographic category, and 12-digit formatted VUID.
3. **Chromatic Invariants for Leaf Nodes:**
   - **Gray (`#6B7280`):** Strict priority for citizens with `Deceased` status (preserving respectful ancestral memory).
   - **Blue (`#2563EB`):** Citizens with `Male` gender.
   - **Pink (`#EC4899`):** Citizens with `Female` gender.
   - **Purple (`#A855F7`):** All other civil genders (`Non-Binary`, `Transgender`, `Other`).

### Section 6.6: Fault-Tolerant Platform & Network Ingestion
1. External hardware/sensor integrations (e.g. GPS geolocation) MUST be wrapped in defensive `try/catch` blocks with explicit timeouts ($\le 10\text{s}$) and safe fallbacks to manual input.
2. Network response decoders MUST safely handle non-JSON responses (HTML error pages, gateway timeouts) with graceful fallbacks, preventing unhandled `FormatException` crashes.

---

## Article VII: Code Quality, Testing & Continuous Assurance

### Section 7.1: The 100% Test Pass Mandate
1. **No commit or merge is permitted without a 100% test pass rate.**
2. The entire test suite across all subsystems MUST execute cleanly with zero errors, zero uncaught exceptions, and zero skipped core assertions:
   - **Database DDL & Schema Validator:** 30/30 assertions passed.
   - **Backend API, Crypto, Security & E2E Suites:** 48/48 tests passed across 7 suites.
   - **Client Unit & Widget Suite:** 31/31 tests passed across 10 suites.
   - **Total Sovereign Test Suite:** **109/109 assertions passed (100% pass rate)**.
3. Total workspace testing is enforced via:
   ```bash
   npm run test:all && node database/validate_ddl.js
   ```

### Section 7.2: Regression Invariants
1. Any bug reported in production MUST have an accompanying reproduction test committed before any fix is applied.
2. Dead code, commented-out dead blocks, and unvalidated stub endpoints are strictly unconstitutional and prohibited from the `main` branch.

---

## Article VIII: Monetization Ethics & Sovereign Governance

### Section 8.1: Clean DPI Rollout Mandate
1. VanshaSetu is a sovereign civil utility. Monetization through third-party advertisement networks MUST be **disabled by default** (`isMonetizationEnabled = false`).
2. The application MUST boot cleanly with zero ad network SDK network queries, zero device fingerprinting, and zero external ad tracking.

### Section 8.2: Ban on Telemetry Brokering
1. Citizen data, lineage records, demographic stats, or ePHI MUST NEVER be sold, shared, or brokered to commercial ad networks, data brokers, or non-sovereign entities.
2. Diagnostic telemetry must be strictly self-hosted and anonymized.

### Section 8.3: Data Residency
1. All production databases, caches, and API replicas MUST reside on servers geographically located within the borders of India, in strict accordance with the DPDP Act 2023.

---

## Article IX: Civil Life Events, Education, Matrimony & Demographic Intelligence

### Section 9.1: Civil Life Events Invariants (Birth, Death, Marriage)
1. **Child Birth Registration:**
   - Registration of a child MUST allocate a valid 12-digit numeric VUID within $[10^{11}, 10^{12}-1]$.
   - The child record MUST inherit community metadata (`caste`, `category`, `gotra`) and residential geography from the parents unless explicitly overridden by civil court order.
   - Reciprocal kinship edges (`Father`, `Mother`, `Son`, `Daughter`) MUST be atomically committed alongside the citizen record.
2. **Civil Death Registration:**
   - Recording a death MUST mutate the citizen status to `Deceased` and persist the `death_date`, verified civil `death_reason`, and official municipal `death_cert_number`.
   - A deceased citizen's historical kinship edges, document hashes, and audit trail entries remain immutable for lineage tracing and hereditary probate rights.
3. **Civil Marriage Registration:**
   - Both parties MUST satisfy legal marriage age ($\ge 21$ years for the groom, $\ge 18$ years for the bride).
   - Reciprocal `Spouse` kinship edges MUST be verified, and both spouses' `marital_status` MUST be transitioned to `Married`.
   - A unique municipal registration certificate number (`MAR-YYYY-XXXX`) MUST be issued and stored in the encrypted `marriages` ledger.

### Section 9.2: Citizen Education & Professional Qualifications Registry
1. Every educational credential entered into `citizen_education` MUST specify a recognized `qualification_level` (`Primary`, `Secondary`, `Higher Secondary`, `Diploma`, `Undergraduate`, `Postgraduate`, `Doctorate`, `Vocational`).
2. Professional sectors (`occupation_sector`) and official titles (`profession_title`) MUST be indexed to support national skill mapping and demographic census analytics.
3. All educational records MUST reside in encrypted storage (`ENCRYPTION='Y'`).

### Section 9.3: Indian Matrimony Engine & Gotra Exogamy Protocol
1. **Gotra Exogamy Rule:** To prevent consanguinity and conform with classical Indian civil lineage jurisprudence, matrimony matchmaking MUST evaluate Gotra exogamy:
   - When the seeker's Gotra matches the candidate's Gotra, the engine MUST prominently flag the profile with `Warning_Sagotra` (`⚠️ Sagotra Alert (सगोत्र)`).
   - Non-matching Gotras MUST be verified and certified as `Permitted_Exogamous` (`✅ Exogamous Match (विवाह योग्य)`).
2. **Multi-Dimensional Matching:** Matchmaking criteria MUST support simultaneous filtering across age bounds, community/category (`GEN`, `OBC`, `SC`, `ST`, `EWS`), home state/district, physical height, and minimum qualification levels.
3. **Consanguinity & Privacy Safeguards:** Raw contact numbers and exact residential street addresses MUST NEVER be exposed in public matrimony search responses; only verified VUID credentials, lineage trees, and community parameters may be presented.

### Section 9.4: Dynamic Demographic & Census Analytics
1. The platform MUST expose a real-time demographic analytics engine (`/api/v1/analytics/demographics`) capable of aggregating population numbers dynamically by State, District, Category, Gender, and Marital Status.
2. The engine MUST compute:
   - Five-tier age distribution pyramids: Children (0-14 yrs), Youth (15-24 yrs), Working Age (25-59 yrs), and Seniors (60+ yrs).
   - Gender ratios (Male, Female, Other).
   - Verified digital adoption rates (% Claimed and OCP Verified).
3. Demographic aggregation queries MUST strictly return anonymized cohort counts and percentage distributions; individual citizen identities or raw PII MUST NEVER be returned through the analytics endpoint.

### Section 9.5: Comprehensive Tamper-Proof Auditing (HIPAA § 164.312(b) & DPDP Act 2023)
1. **Full Lifecycle Auditing:** Every civil event (`BIRTH_REGISTRATION`, `DEATH_REGISTRATION`, `MARRIAGE_REGISTRATION`), education modification (`EDUCATION_UPDATE`), matrimony search (`MATRIMONY_SEARCH`), and demographic query (`DEMOGRAPHICS_QUERY`) MUST be recorded in the `audit_logs` table.
2. **Cryptographic Blockchain Chaining:** Each audit log entry MUST compute its SHA-256 hash using the previous entry's hash as a salt:
   $$\text{log\_hash}_i = \text{SHA-256}\left(\text{log\_hash}_{i-1} \parallel \text{actor} \parallel \text{action} \parallel \text{resource\_type} \parallel \text{resource\_id} \parallel \text{timestamp}\right)$$
3. **Integrity Verification:** The system MUST provide an automated verification endpoint (`/api/v1/audit/verify-integrity`) that recalculates the entire blockchain sequence from the genesis block, ensuring 100% tamper-detection and legal non-repudiation.

---

## Article X: Fail-Fast Integrity, Universal Prohibition of Defaults & Canonical Domain Models

### Section 10.1: Universal Prohibition of Default Values, Placeholders & Silent Fallbacks
1. **Strict Zero-Default Invariant:** The entire codebase—across database definitions, backend APIs, middleware, and client applications—MUST **NEVER** use default values, fallback placeholders, or silent alternatives for domain attributes.
2. **Fail-Fast Operational Mandate:** Every operation MUST strictly succeed with valid, explicitly passed values or **fail immediately and loudly** (`HTTP 400 Bad Request` or compile/runtime validation errors).
3. **Prohibited Patterns:**
   - Logical fallback operators on domain fields are unconstitutional:
     - ❌ `religion || 'Hindu'`
     - ❌ `category || 'GEN'`
     - ❌ `marital_status || 'Single'`
     - ❌ `caste || 'Open'`
     - ❌ `gotra || 'Kashyap'`
     - ❌ `pin_code || '452001'`
     - ❌ `death_reason || 'Natural'`
     - ❌ `death_cert_number || 'N/A'`
     - ❌ `country || 'India'`
   - Form fields MUST NOT silently pre-select arbitrary default values. Users and calling clients MUST explicitly select and pass all mandatory attributes.
   - Any API request omitting a required domain attribute MUST be rejected with a clear, deterministic validation error message identifying the exact missing or invalid property.

### Section 10.2: Common Canonical Models, Single Source of Truth & Dual-Ontology Kinship
1. **The Single Source of Truth (SSOT) Invariant:**
   - To eliminate divergence, redundancy, and maintenance hazards, all civil, demographic, and kinship models MUST be defined in **exactly ONE canonical file**:
     $$\text{SSOT File:} \quad \text{shared/civil_models.json}$$
   - Maintaining separate manual, hand-maintained definition lists in [`backend/src/models/civil_models.js`](file:///Users/siddharthdashore/Workspace/FamilyTree/backend/src/models/civil_models.js) and [`client/lib/core/constants/civil_models.dart`](file:///Users/siddharthdashore/Workspace/FamilyTree/client/lib/core/constants/civil_models.dart) is **strictly unconstitutional**.
   - **Backend Ingestion:** The Node.js API core directly imports [`shared/civil_models.json`](file:///Users/siddharthdashore/Workspace/FamilyTree/shared/civil_models.json) and dynamically constructs validator closures and lookup maps.
   - **Client Synchronization:** The Flutter client constants [`client/lib/core/constants/civil_models.dart`](file:///Users/siddharthdashore/Workspace/FamilyTree/client/lib/core/constants/civil_models.dart) are automatically synchronized from [`shared/civil_models.json`](file:///Users/siddharthdashore/Workspace/FamilyTree/shared/civil_models.json) via `node scripts/sync_models.js`, which is chained into all test and build lifecycle pipelines (`npm test`, `npm run build:prod`).
   - **Public Metadata Reflection:** The middleware MUST expose `GET /api/v1/meta/civil-models` serving the raw canonical models to client applications, audit tools, and third-party sovereign integrators.

2. **String-Based Value & Label Specification for All Enum Items:**
   - Every domain enum item across all models MUST declare both a compact machine code AND an explicit, human-readable string value/label in both English and Hindi:
     - **`CivilCategories`:**
       - `GEN` $\to$ `General` (सामान्य)
       - `OBC` $\to$ `Other Backward Class` (अन्य पिछड़ा वर्ग)
       - `SC` $\to$ `Scheduled Caste` (अनुसूचित जाति)
       - `ST` $\to$ `Scheduled Tribe` (अनुसूचित जनजाति)
       - `EWS` $\to$ `Economically Weaker Section` (आर्थिक रूप से कमजोर वर्ग)
       - `Other` $\to$ `Other Category` (अन्य वर्ग)
     - **`CivilReligions`:** `Hindu` $\to$ `Hinduism`, `Muslim` $\to$ `Islam`, `Christian` $\to$ `Christianity`, `Sikh` $\to$ `Sikhism`, `Jain` $\to$ `Jainism`, `Buddhist` $\to$ `Buddhism`, `Parsi` $\to$ `Zoroastrianism / Parsi`, `Jewish` $\to$ `Judaism`, `Other` $\to$ `Other Religion`.
     - **`CivilMaritalStatuses`:** `Single` $\to$ `Single / Unmarried`, `Married` $\to$ `Married`, `Widowed` $\to$ `Widowed`, `Divorced` $\to$ `Divorced`, `Separated` $\to$ `Separated`.
     - **`CivilBloodGroups`:** `A+` $\to$ `A Positive (A+)`, `A-` $\to$ `A Negative (A-)`, `B+` $\to$ `B Positive (B+)`, `B-` $\to$ `B Negative (B-)`, `AB+` $\to$ `AB Positive (AB+)`, `AB-` $\to$ `AB Negative (AB-)`, `O+` $\to$ `O Positive (O+)`, `O-` $\to$ `O Negative (O-)`.
     - **`CivilGenders`:** `Male` $\to$ `Male`, `Female` $\to$ `Female`, `Non-Binary` $\to$ `Non-Binary`, `Transgender` $\to$ `Transgender`, `Other` $\to$ `Other`.
     - **`CivilQualifications`:** `Primary` $\to$ `Primary School (Class 1-5)`, `Secondary_10th` $\to$ `Secondary School (10th / Matric)`, `HigherSecondary_12th` $\to$ `Higher Secondary (12th / Intermediate)`, `Diploma` $\to$ `Vocational / Technical Diploma`, `Bachelors` $\to$ `Bachelor's Degree (Undergraduate)`, `Masters` $\to$ `Master's Degree (Postgraduate)`, `Doctorate` $\to$ `Doctorate / Ph.D.`, `Professional_CA_CS` $\to$ `Professional Certification (CA, CS, ICWA)`, `Other` $\to$ `Other Qualification`.
     - **`CivilOccupations`:** `Government` $\to$ `Government & Civil Services`, `Private_IT_Corporate` $\to$ `Private Sector, IT & Corporate`, `Healthcare` $\to$ `Healthcare, Medicine & Doctors`, `Banking_Finance` $\to$ `Banking & Financial Services`, `Defense_Police` $\to$ `Armed Forces, Defense & Police`, `Education_Research` $\to$ `Education, Teaching & Research`, `Business_SelfEmployed` $\to$ `Business, Trade & Self Employed`, `Agriculture` $\to$ `Agriculture, Farming & Agro-Business`, `Student` $\to$ `Student / Scholar`, `Homemaker` $\to$ `Homemaker / Domestic Manager`, `Other` $\to$ `Other Occupation`.
     - **`CivilDocumentTypes`:** `AADHAAR` $\to$ `Aadhaar Card (UIDAI)`, `PAN` $\to$ `Permanent Account Number (PAN)`, `VOTER_ID` $\to$ `Voter ID Card (EPIC)`, `DRIVING_LICENSE` $\to$ `Motor Vehicle Driving License`, `PASSPORT` $\to$ `Indian Passport`, `RATION_CARD` $\to$ `Public Distribution Ration Card`, `BIRTH_CERTIFICATE` $\to$ `Municipal Birth Certificate`, `BIOMETRIC` $\to$ `Biometric Verification Record`.

3. **Complete Indian & Western Kinship Ontology (`CivilRelationships`):**
   - The kinship graph MUST support the complete, canonical Indian and Western relationship taxonomy across 72 formal designations:
     - **Nuclear:** `Father` (पिता), `Mother` (माता), `Son` (पुत्र/बेटा), `Daughter` (पुत्री/बेटी), `Brother` (भाई), `Sister` (बहन), `Sibling` (सहोदर), `Spouse` (जीवनसाथी), `Husband` (पति), `Wife` (पत्नी).
     - **Ancestral:** `Paternal_Grandfather` (दादा), `Paternal_Grandmother` (दादी), `Maternal_Grandfather` (नाना), `Maternal_Grandmother` (नानी), `Great_Grandfather` (परदादा/परनाना), `Great_Grandmother` (परदादी/परनानी).
     - **Descendant:** `Grandson` (पोता/नाती), `Granddaughter` (पोती/नातिन), `Great_Grandson` (परपोता), `Great_Granddaughter` (परपोती).
     - **Paternal Extended (पितृ पक्ष):** `Paternal_Uncle_Elder` (ताऊ), `Paternal_Aunt_Elder` (ताई), `Paternal_Uncle_Younger` (चाचा), `Paternal_Aunt_Younger` (चाची), `Paternal_Aunt` (बुआ/फूफी), `Paternal_Aunt_Husband` (फूफा).
     - **Maternal Extended (मातृ पक्ष):** `Maternal_Uncle` (मामा), `Maternal_Uncle_Wife` (मामी), `Maternal_Aunt` (मौसी), `Maternal_Aunt_Husband` (मौसा).
     - **General Extended:** `Uncle` (चाचा/मामा), `Aunt` (चाची/मौसी/बुआ), `Cousin_Brother` (चचेरा/ममेरा भाई), `Cousin_Sister` (चचेरी/ममेरी बहन), `Cousin` (कजिन).
     - **Descendant Extended:** `Nephew_Brother_Son` (भतीजा), `Niece_Brother_Daughter` (भतीजी), `Nephew_Sister_Son` (भांजा), `Niece_Sister_Daughter` (भांजी), `Nephew` (भतीजा/भांजा), `Niece` (भतीजी/भांजी).
     - **Affinal / In-Laws (ससुराल पक्ष):** `Father_In_Law` (ससुर), `Mother_In_Law` (सास), `Son_In_Law` (दामाद/जंवाई), `Daughter_In_Law` (बहू/पुत्रवधू), `Brother_In_Law_Wife_Brother` (साला), `Sister_In_Law_Wife_Sister` (साली), `Brother_In_Law_Husband_Elder` (जेठ), `Sister_In_Law_Husband_Elder_Wife` (जेठानी), `Brother_In_Law_Husband_Younger` (देवर), `Sister_In_Law_Husband_Younger_Wife` (देवराणी), `Sister_In_Law_Husband_Sister` (ननद), `Brother_In_Law_Husband_Sister_Husband` (नंदोई), `Brother_In_Law_Sister_Husband` (जीजा/बहनोई), `Sister_In_Law_Brother_Wife` (भाभी), `Co_Father_In_Law` (समधी), `Co_Mother_In_Law` (समधन), `Brother_In_Law`, `Sister_In_Law`.
     - **Step & Adoptive Relations:** `Step_Father` (सौतेला पिता), `Step_Mother` (सौतेली माता), `Step_Son` (सौतेला बेटा), `Step_Daughter` (सौतेली बेटी), `Step_Brother` (सौतेला भाई), `Step_Sister` (सौतेली बहन), `Adoptive_Father` (दत्तक पिता), `Adoptive_Mother` (दत्तक माता), `Adopted_Son` (दत्तक पुत्र), `Adopted_Daughter` (दत्तक पुत्री).
     - **Guardianship & Other:** `Guardian` (संरक्षक), `Ward` (प्रतिपाल्य), `Other` (अन्य सम्बन्धी).
   - Each relationship edge MUST store the canonical machine code and expose helper accessors for `western`, `indian`, `label`, and `category`.

4. **Ban on Ad-Hoc Enums:** Inline enum arrays or string-matching lists scattered across route handlers, controller classes, or widget trees are strictly unconstitutional. All validations must import and execute the common validation functions exported by the canonical model registries.

### Section 10.3: Sovereign Multilingual Public Infrastructure Parity (English, Hindi, Gujarati, Marathi)
1. **Constitutional Four-Language Parity:**
   - VanshaSetu as a sovereign Digital Public Infrastructure (DPI) platform MUST guarantee first-class linguistic parity across four primary languages:
     - **English (`en`)**
     - **हिन्दी / Hindi (`hi`)**
     - **ગુજરાતી / Gujarati (`gu`)**
     - **मराठी / Marathi (`mr`)**
2. **Canonical Localization Invariants:**
   - Every entry in [`shared/civil_models.json`](file:///Users/siddharthdashore/Workspace/FamilyTree/shared/civil_models.json) MUST provide accurate localized display values: `label` (English), `hindi_label` (हिन्दी), `gujarati_label` (ગુજરાતી), and `marathi_label` (मराठी).
   - All 72 kinship relationships (`CivilRelationships`) MUST provide culturally accurate regional kin terms in Gujarati (e.g. `પિતા`, `માતા`, `કાકા`, `કાકી`, `ફોઈ`, `ફૂવા`, `મોટા પપ્પા`, `સસરા`, `જમાઈ`, `પુત્રવધૂ`) and Marathi (e.g. `वडील`, `आई`, `काका`, `काकू`, `आत्या`, `मामा`, `मोठे काका`, `सासरे`, `जावई`, `सून`).
3. **API & Client Implementation Requirements:**
   - The metadata endpoint `GET /api/v1/meta/civil-models` MUST accept `?lang=en|hi|gu|mr` and return localized dictionaries for categories, relationships, and metadata.
   - The Flutter client MUST incorporate reactive localization via `AppLocalizations`, `localeProvider`, and prominent `LanguageSelectorButton` interactive widgets allowing instant switching between English, Hindi, Gujarati, and Marathi across all screens.
   - Flutter application entry points (`MaterialApp`) MUST declare `GlobalMaterialLocalizations.delegate`, `GlobalWidgetsLocalizations.delegate`, and `GlobalCupertinoLocalizations.delegate` alongside `AppLocalizationsDelegate` to ensure seamless runtime language selection without `No MaterialLocalizations found` crashes across all 4 official languages.

### Section 10.4: Cross-Layer Enforcement Matrix
1. **Database Layer:** MySQL schema enforces strict `CHECK` constraints on all enumerated columns (`gender`, `category`, `religion`, `marital_status`, `blood_group`, `status`, `relationship type`, `document type`).
2. **Backend API Layer:** Validates incoming payloads against the canonical models before initiating database transactions. In child birth registration, community attributes (`caste`, `category`, `gotra`, `religion`, `geography`) are strictly validated; if parent records do not provide them and the payload lacks them, the endpoint rejects immediately with `400 Bad Request`.
3. **Client UI Layer:** Flutter forms validate all dropdowns and text fields against `civil_models.dart`, preventing form submission until all mandatory attributes are explicitly chosen by the user.

---

## Article XI: Ratification & Enforcement Hierarchy

1. In the event of any contradiction between this **Constitution**, architectural documentation, or code comments:
   $$\text{Constitution.md} > \text{vanshasetu\_master\_specification.md} > \text{plan.md} > \text{tasks.md} > \text{Code Implementation}$$
2. Every engineer and automated agent contributing to VanshaSetu accepts this Constitution as an inviolable contract of software stewardship.

---
*Enacted by the VanshaSetu Core Governance Board • Version 1.2.0-PROD*
