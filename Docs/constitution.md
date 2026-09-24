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

---

## Article V: Kinship Graph Invariants & Fraud Prevention (SIR)

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

---

## Article VI: Physical & Digital Credential Standards (ISO/IEC 7810 ID-1)

### Section 6.1: Physical Card Geometry
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

---

## Article VII: Code Quality, Testing & Continuous Assurance

### Section 7.1: The 100% Test Pass Mandate
1. **No commit or merge is permitted without a 100% test pass rate.**
2. The entire test suite across all subsystems MUST execute cleanly with zero errors, zero uncaught exceptions, and zero skipped core assertions:
   - **Database DDL Validator:** 23/23 assertions passed.
   - **Backend API & Crypto Suite:** 24/24 tests passed across 5 suites.
   - **Client Unit & Widget Suite:** 20/20 tests passed.
3. Total workspace testing is enforced via:
   ```bash
   npm run test:all
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

## Article IX: Ratification & Enforcement Hierarchy

1. In the event of any contradiction between this **Constitution**, architectural documentation, or code comments:
   $$\text{Constitution.md} > \text{vanshasetu\_master\_specification.md} > \text{plan.md} > \text{tasks.md} > \text{Code Implementation}$$
2. Every engineer and automated agent contributing to VanshaSetu accepts this Constitution as an inviolable contract of software stewardship.

---
*Enacted by the VanshaSetu Core Governance Board • Version 1.0.0-PROD*
